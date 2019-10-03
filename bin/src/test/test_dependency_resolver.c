//
// Created by Rieon Ke on 2019/9/30.
//

#include "../dependency_resolver.h"
#include <assert.h>

#include <gmodule.h>

#define ABSOLUTE_LIB "/Users/rieon/Projects/rieon/shlib/lib/string.sh"
#define RELATIVE_LIB "./demo_lib.sh"
#define RELATIVE_LIB_REF "/Users/rieon/Projects/rieon/shlib/test/test.sh"

gboolean test_visit_tree(GNode *node, gpointer data);
gboolean test_visit_tree_dep(GNode *node, gpointer data);

int main() {

  char *out;
  bool result = sl_resolve_lib_real_path(ABSOLUTE_LIB, ".", NULL, &out);

  assert(result == true);
  assert(out != NULL);

  printf("%s\n", out);

  free(out);

  result = sl_resolve_lib_real_path(RELATIVE_LIB, RELATIVE_LIB_REF, NULL, &out);
  assert(result == true);
  assert(out != NULL);

  printf("%s\n", out);

  free(out);

  sl_resolve_options opts = {
      .global_search_path = "/Users/rieon/Projects/rieon/shlib/lib"
  };

  result = sl_resolve_lib_real_path("string.contains", NULL, &opts, &out);
  assert(result == true);
  assert(out != NULL);

  printf("%s\n", out);

  free(out);

  result = sl_resolve_lib_real_path("$(pwd)/string.sh", NULL, &opts, &out);
  assert(result == true);
  assert(out != NULL);

  printf("%s\n", out);

  free(out);


  // tree
  GNode *root;
  int root_val = 0;
  root = g_node_new(&root_val);

  GNode *l1_1;
  int l1_1_val = 1;
  l1_1 = g_node_new(&l1_1_val);

  GNode *l1_2;
  int l1_2_val = 2;
  l1_2 = g_node_new(&l1_2_val);

  g_node_insert(root, -1, l1_1);
  g_node_insert(root, -2, l1_2);

  GNode *l2_1;
  int l2_1_val = 3;
  l2_1 = g_node_new(&l2_1_val);

  GNode *l2_2;
  int l2_2_val = 4;
  l2_2 = g_node_new(&l2_2_val);

  GNode *l2_3;
  int l2_3_val = 5;
  l2_3 = g_node_new(&l2_3_val);

  g_node_insert(l1_1, -1, l2_1);
  g_node_insert(l1_1, -1, l2_2);
  g_node_insert(l1_1, -1, l2_3);

  g_node_traverse(root, G_POST_ORDER, G_TRAVERSE_ALL, -1, test_visit_tree, NULL);

  g_node_destroy(root);

  // deps tree

  GNode *tree_root = NULL;
  sl_build_dependencies_tree(RELATIVE_LIB_REF, NULL, &opts, NULL, true, &tree_root);

  int p = 1;

  g_node_traverse(tree_root, G_PRE_ORDER, G_TRAVERSE_ALL, -1, test_visit_tree_dep, &p);
  p = 0;
  g_node_traverse(tree_root, G_POST_ORDER, G_TRAVERSE_ALL, -1, test_visit_tree_dep, &p);

  GList *flat_list = NULL;
  if (sl_build_dependencies_flat(tree_root, true, NULL, NULL, &flat_list)) {

    for (size_t i = 0; i < g_list_length(flat_list); ++i) {
      gpointer path = g_list_nth_data(flat_list, i);
      printf("\t%s\n", path);
      free(path);
    }
  }

  sl_free_dependencies_tree(tree_root);


  //parse config file
  sl_resolve_options *options = NULL;
  sl_parse_config_opts("../src/shlib.ini", &options);

  printf("search path: %s\n", options->global_search_path);

  free(options->global_search_path);
  free(options);

}

gboolean test_visit_tree_dep(GNode *node, gpointer data) {

  if (*(int *) data == 1) {

    printf("node_%p [label=\"%s\"]\n", node, node->data);
  } else {

    if (node->parent != NULL) {
      printf("node_%p -> node_%p \n", node->parent, node);
//  } else {
//    printf("%s -> %s \n", node->parent->data, node->data);
    }
  }

  return false;

}

gboolean test_visit_tree(GNode *node, gpointer data) {

  printf("%d\n", *(int *) node->data);
  return false;

}
