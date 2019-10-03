//
// Created by Rieon Ke on 2019/9/29.
//

#include <stdio.h>
#include <stdlib.h>
#include <glib.h>
#include "lib/argtable3.h"
#include "dependency_resolver.h"

#define APP_VERSION "0.1-Alpha"

struct arg_lit *verb, *help, *version, *lib;
struct arg_int *optimize;
struct arg_file *out, *file, *config;
struct arg_end *end;

int main(int argc, char *argv[]) {

  void *argtable[] = {
      help = arg_lit0("h", "help", "display this help and exit"),
      lib = arg_lit0("l", "lib", "print required lib only"),
      version = arg_lit0(NULL, "version", "display version info and exit"),
      optimize = arg_int0("O", "optimize", "<n>", "optimize level [ 0 - 1 ], default 0"),
      verb = arg_lit0("v", "verbose", "verbose output"),
      config = arg_file0("C", "config", "config file", "configure file"),
      out = arg_file0("o", "out", "output file", "compiled output file, default: build.out.sh"),
      file = arg_file0(NULL, NULL, "<file>", "input entry point file"),
      end = arg_end(20),
  };

  int nerrors;
  nerrors = arg_parse(argc, argv, argtable);

  int exitcode = 0;
  char *progname = argv[0];

  /* special case: '--help' takes precedence over error reporting */
  if (help->count > 0) {
    printf("Usage: %s", progname);
    arg_print_syntax(stdout, argtable, "\n");
    printf("shlib build tool \n\n");
    arg_print_glossary(stdout, argtable, "  %-25s %s\n");
    exitcode = 0;
    goto exit;
  }

  if (version->count > 0) {
    printf("Version: %s\n", APP_VERSION);
    exitcode = 0;
    goto exit;
  }

  if (nerrors > 0) {
    arg_print_errors(stdout, end, progname);
    printf("Try '%s --help' for more information.\n", progname);
    exitcode = 1;
    goto exit;
  }

  bool lib_only = false;
  if (lib->count > 0) {
    lib_only = true;
  }

  const char *entry_path = "";
  if (file->count > 0) {
    const char **entry_paths = file->filename;
    entry_path = entry_paths[0];
  } else {
    fprintf(stderr, "error: missing input file");
    exitcode = 1;
    goto exit;
  }

  const char *config_path = "./shlib.ini";
  if (config->count > 0) {
    const char **config_paths = config->filename;
    config_path = config_paths[0];
  }

  const char *out_path = "./build.out.sh";
  if (out->count > 0) {
    out_path = out->filename[0];
  }

  int optimize_level = 0;

  if (optimize->count > 0) {
    optimize_level = *optimize->ival;
  }

  GList *list = NULL;

  // 1. parse options
  sl_resolve_options *opts = NULL;
  if (!sl_parse_config_opts(config_path, &opts)) {
    fprintf(stderr, "error: parse config file error\n");
    exitcode = 1;
    goto exit;
  }


  // 2. get file content
  if (entry_path == NULL || strlen(entry_path) == 0) {
    exitcode = 1;
    goto exit;
  }

  if (!g_file_test(entry_path, G_FILE_TEST_IS_REGULAR | G_FILE_TEST_IS_SYMLINK)) {
    fprintf(stderr, "error: file %s does not exists!", entry_path);
    exitcode = 1;
    goto exit;
  }

  GNode *tree = NULL;
  if (!sl_build_dependencies_tree(entry_path, NULL, opts, NULL, true, &tree)) {
    fprintf(stderr, "error: parse dependencies failed");
    exitcode = 1;
    goto exit;
  }

  if (!sl_build_dependencies_flat(tree, true, NULL, NULL, &list)) {
    fprintf(stderr, "error: build flat dependencies list failed");
    exitcode = 1;
    goto exit;
  }

  sl_free_dependencies_tree(tree);

  // merge file
  if (lib_only) {

    for (size_t i = 0; i < g_list_length(list); ++i) {

      char *data = g_list_nth_data(list, i);
      if (g_strcmp0(data, entry_path) != 0) {
        printf("%s\n", data);
      }

      free(data);
    }

  } else {

    FILE *out_file = fopen(out_path, "w+");
    if (out_file == NULL) {
      fprintf(stderr, "error: open file %s failed\n", out_path);
    }

    fprintf(out_file, "declare -r SHLIB_RELEASE=1\n");
    for (size_t i = 0; i < g_list_length(list); ++i) {

      char *data = g_list_nth_data(list, i);
      if (g_strcmp0(data, entry_path) != 0) {

        char *buf;
        GError *err;
        if (g_file_get_contents(data, &buf, NULL, &err)) {
          fprintf(out_file, "### start @%s\n", data);
          fprintf(out_file, "%s\n", buf);
          fprintf(out_file, "### end @%s\n\n", data);
          free(buf);
        } else {
          fprintf(stderr, "%s\n", err->message);
        }
      }

      free(data);
    }

    char *entry_buf = NULL;
    GError *err;
    if (g_file_get_contents(entry_path, &entry_buf, NULL, &err)) {
      fprintf(out_file, "%s\n", entry_buf);
    } else {
      fprintf(stderr, "error: %s\n", err->message);
    }
    printf("Compiled\n");
  }

  exit:
  if (opts != NULL) {
    sl_free_config_opts(opts);
  }

  arg_freetable(argtable,
                sizeof(argtable) / sizeof(argtable[0]));
  return
      exitcode;
}