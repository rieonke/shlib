//
// Created by Rieon Ke on 2019/9/30.
//

#include "dependency_resolver.h"
#include "lib/ini.h"
#include <glib.h>

#include <errno.h>
#include <string.h>

struct result {
  bool status;
  bool expanded;
  const char *ref_path;
  const sl_resolve_options *opts;
  GList **list;
};

bool sl_resolve_lib_real_path(const char *lib_name,
                              const char *ref_path,
                              const sl_resolve_options *opts,
                              char **out_path) {
  /*
   * 1. computed lib => contains $ or `
   * 2. absolute lib => starts with / and should be exist
   * 3. relative lib => starts with . or not, should be exist in the same dir of ref_path
   * 4. named lib => such as array.print, expanded as ${global_search_dir}/array/print
   */

  // 0. computed name
  if (strchr(lib_name, '$') - lib_name >= 0 || strchr(lib_name, '`') - lib_name >= 0) {

    char buf[1050];
    sprintf(buf, "eval \" printf %s \"", lib_name);

    FILE *fp;
    char path[1024];

    /* Open the command for reading. */
    fp = popen(buf, "r");
    if (fp == NULL) {
      fprintf(stderr, "Failed to run command\n");
      return false;
    }

    /* Read the output a line at a time - output it. */
    if (fgets(path, sizeof(path) - 1, fp) != NULL) { //todo support multiple line path if => while
//      printf("%s", path);
    }

    gchar *cmd_path = g_malloc0_n(strlen(path), sizeof(char));
    strcpy(cmd_path, path);

    /* close */
    pclose(fp);
    *out_path = cmd_path;

    return true;
  }

  // 1. absolute path
  if (g_path_is_absolute(lib_name)) {

    if (g_file_test(lib_name, G_FILE_TEST_EXISTS | G_FILE_TEST_IS_REGULAR | G_FILE_TEST_IS_SYMLINK)) {
      size_t len = strlen(lib_name);
      *out_path = g_try_malloc0_n(len, sizeof(char));
      if (*out_path == NULL) {
        fprintf(stderr, "error: malloc memory failed\n");
        return false;
      }

      strcpy(*out_path, lib_name);
      return true; //end here

    } else {
      fprintf(stderr, "error: [%s] not found, file %s does not exist\n", lib_name, lib_name);
      return false; //end here
    }

  }

  // 2. relative path
  if (lib_name[0] == '.') { //todo enhancement
    char *parent_dir = g_path_get_dirname(ref_path);
    char *lib_path = g_build_filename(parent_dir, lib_name, NULL);
    free(parent_dir);

    if (g_file_test(lib_path, G_FILE_TEST_EXISTS | G_FILE_TEST_IS_SYMLINK | G_FILE_TEST_IS_REGULAR)) {
      *out_path = lib_path;
      return true;
    } else {
      fprintf(stderr, "error: [%s] not found, file %s does not exist\n", lib_name, lib_path);
      free(lib_path);
      return false;
    }
  }

  // 3. named path
  {
    // 1. split by .
//    char **path_segments = g_strsplit(lib_name, ".", -1);
    size_t lib_name_len = strlen(lib_name);

    char *path_with_ext = g_malloc0_n(lib_name_len + 4, sizeof(char));

    for (size_t i = 0; i < lib_name_len; ++i) {
      if (lib_name[i] == '.') {
        path_with_ext[i] = '/';
      } else {
        path_with_ext[i] = lib_name[i];
      }
    }

//    strncpy(path_with_ext, lib_name, lib_name_len);
    strncat(path_with_ext, ".sh\0", 4);

    char *lib_path = g_build_filename(opts->global_search_path, path_with_ext, NULL);
    free(path_with_ext);

    if (g_file_test(lib_path, G_FILE_TEST_EXISTS | G_FILE_TEST_IS_SYMLINK | G_FILE_TEST_IS_REGULAR)) {
      *out_path = lib_path;
      return true;
    } else {
      fprintf(stderr, "error: [%s] not found, file %s does not exist\n", lib_name, lib_path);
      free(lib_path);
      return false;
    }

  }

  return false;
}

bool _sl_build_dependencies_tree_check_cycle(GNode *parent, char *val, char **path) {

  GNode *p = parent;
  bool found = false;
  bool to_free = false;
  size_t path_len = strlen(val);
  if (*path == NULL) {
    to_free = true;
    *path = g_malloc0_n(path_len, sizeof(char));
    strncpy(*path, val, path_len);
  }

  while (p != NULL) {

    // append path
    if (p->data != NULL && val != NULL) {
      path_len += strlen(p->data) + 4;
      *path = g_realloc_n(*path, path_len, sizeof(char));
      strncat(*path, " <= ", 4);
      strncat(*path, p->data, strlen(p->data));
    }

    if (p->data != NULL && val != NULL && g_strcmp0(p->data, val) == 0) {
      found = true;
    }

    p = p->parent;
  }

  if (!found && to_free) {
    free(*path);
  }

  return found;
}

bool sl_build_dependencies_tree(const char *entry_path,
                                const char *ref_path,
                                const sl_resolve_options *opts,
                                GNode *parent,
                                bool expand,
                                GNode **out_tree) {

  char *real_path;
  if (!sl_resolve_lib_real_path(entry_path, ref_path, opts, &real_path)) {
    return false;
  }

  char *new_entry_path;
  new_entry_path = g_malloc0_n(strlen(entry_path) + 1, sizeof(char));
  strncpy(new_entry_path, entry_path, strlen(entry_path));

  char *cycle_path = NULL;
  if (_sl_build_dependencies_tree_check_cycle(parent, expand ? real_path : new_entry_path, &cycle_path)) {
    fprintf(stderr, "error: cycle dependencies, path [ %s ]\n", cycle_path);
    free(new_entry_path);
    free(cycle_path);
    free(real_path);
    return false;
  }

  GNode *node;

  if (expand) {
    node = g_node_new(real_path);
  } else {
    node = g_node_new(new_entry_path);
  }

  // check cycle dependencies

  if (*out_tree == NULL) {
    *out_tree = node;
  } else {
    // 1. create tree node
    g_node_insert(parent, -1, node);
  }


  //printf("add: %s\n", node->data);

  // 2. get deps of current entry point
  GList *list = NULL;
  if (sl_scan_dependencies(real_path, &list) && list != NULL) {
    size_t list_len = g_list_length(list);
    if (list_len > 0) { // has dependencies

      for (size_t i = 0; i < list_len; ++i) {
        char *dep = (char *) g_list_nth_data(list, i);
        sl_build_dependencies_tree(dep, real_path, opts, node, expand, out_tree); //todo error handling
        free(dep);
      }

      g_list_free(list);
    }
  }

  if (expand) {
    free(new_entry_path);
  } else {
    free(real_path);
  }

  return true;
}

bool sl_scan_dependencies(const char *entry_path, GList **out_list) {

  // 1. check file
  if (!g_file_test(entry_path, G_FILE_TEST_IS_REGULAR | G_FILE_TEST_IS_SYMLINK)) {
    return false;
  }

  char *buf;
  GError *err;
  if (!g_file_get_contents(entry_path, &buf, 0, &err)) {
    fprintf(stderr, "error: %s\n", err->message);
    g_error_free(err);
    return false;
  }

  // 2. match the she-bang
  GRegex *regex;
  GMatchInfo *match_info;

  regex = g_regex_new("(#!([[:space:]]?)+require)[[:space:]]+([a-zA-Z.\\/\\_`0-9]+)", 0, 0, NULL);
  g_regex_match(regex, buf, 0, &match_info);
  while (g_match_info_matches(match_info)) {
    gchar *word = g_match_info_fetch(match_info, 3);
    (*out_list) = g_list_prepend(*out_list, word);
    g_match_info_next(match_info, NULL);
  }
  g_match_info_free(match_info);
  g_regex_unref(regex);

  g_free(buf);

  return true;
}

gboolean _sl_free_dependencies_tree(GNode *node, gpointer data) {
  free(node->data);
  return false;
}

bool sl_free_dependencies_tree(GNode *tree) {

  if (tree != NULL) {

    g_node_traverse(tree, G_POST_ORDER, G_TRAVERSE_ALL, -1, _sl_free_dependencies_tree, NULL);

    g_node_destroy(tree);
  }
  return true;

}

gint _sl_compare_str(gconstpointer a, gconstpointer b) {

  if (g_strcmp0(a, b) == 0) {
    return 0;
  }

  return -1;
}

gboolean _sl_build_dependencies_flat(GNode *node, gpointer data) {

  struct result *res = data;

  char *path;

  if (res->expanded) {
    path = g_malloc0_n(strlen(node->data) + 1, sizeof(char));
    strncpy(path, node->data, strlen(node->data));
  } else {
    if (sl_resolve_lib_real_path(node->data, res->ref_path, res->opts, &path)) {
    } else {
      res->status = false;
      return true;
    }
  }

  // if already parsed
  GList *el = g_list_find_custom(*res->list, path, _sl_compare_str);
  if (el == NULL || el->data == NULL) {
    *(res->list) = g_list_append(*(res->list), path);
  } else {
    free(path);
  }

  return false;
}

bool sl_build_dependencies_flat(GNode *dependencies_tree,
                                bool expanded,
                                const char *ref_path,
                                const sl_resolve_options *opts,
                                GList **out) {
  struct result result = {
      .status = true,
      .expanded = expanded,
      .ref_path = ref_path,
      .opts = opts,
      .list = out
  };

  g_node_traverse(dependencies_tree, G_POST_ORDER, G_TRAVERSE_ALL, -1, _sl_build_dependencies_flat, &result);
  if (result.status == true) {
    return true;
  } else {
    return false;
  }

}

static int handler(void *opts, const char *section, const char *name, const char *value) {

  sl_resolve_options **pconfig = opts;

#define MATCH(s, n) strcmp(section, s) == 0 && strcmp(name, n) == 0

  if (MATCH("lib", "global_search_dir")) {
    (*pconfig)->global_search_path = strdup(value);
  } else {
    return 0;
  }
  return 1;

}

bool sl_parse_config_opts(const char *config_path, sl_resolve_options **out) {

  *out = g_malloc0(sizeof(sl_resolve_options));

  if (ini_parse(config_path, handler, out) < 0) {
    fprintf(stderr, "error: cannot load config file %s \n", config_path);
    return false;
  }
  return true;
}

bool sl_free_config_opts(sl_resolve_options *opts) {

  free(opts->global_search_path);
  free(opts);

  return true;
}
