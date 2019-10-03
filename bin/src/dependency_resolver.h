//
// Created by Rieon Ke on 2019/9/30.
//

#ifndef SHLIB_BIN_SRC_DEPENDENCY_RESOLVER_H_
#define SHLIB_BIN_SRC_DEPENDENCY_RESOLVER_H_

#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>
#include <gmodule.h>

typedef struct _sl_resolve_options {
  char *global_search_path;
} sl_resolve_options;

/**
 * parse config file
 * @param config_path config file path
 * @param out options
 * @return parsed or not
 */
bool sl_parse_config_opts(const char *config_path, sl_resolve_options **out);

/**
 * free config options
 * @param opts  config options
 * @return  freed or not
 */
bool sl_free_config_opts(sl_resolve_options *opts);

/**
 * resolve lib real path
 * @param lib_name the lib name , absolute or relative path, named lib, computed lib
 * @param ref_path the dependent
 * @param opts resolve options
 * @param out_path output the real path, should be freed manually
 * @return resolved of not
 */
bool sl_resolve_lib_real_path(const char *lib_name,
                              const char *ref_path,
                              const sl_resolve_options *opts,
                              char **out_path);

/**
 * build the dependencies tree of entry_path
 * @param entry_path the entry path could be any type of lib of script, could be resolved by sl_resolve_lib_real_path
 * @param ref_path the dependent
 * @param opts resolve options
 * @param out_tree output the dependencies tree, should be freed manually
 * @return resolved of not
 */
bool sl_build_dependencies_tree(const char *entry_path,
                                const char *ref_path,
                                const sl_resolve_options *opts,
                                GNode *parent,
                                bool expand,
                                GNode **out_tree);

/**
 * build dependencies list from tree
 * @param dependencies_tree dependencies tree
 * @param expanded expanded path or not
 * @param ref_path  null if expanded
 * @param opts null if expanded
 * @param out lib file list
 * @return resolved of not
*/
bool sl_build_dependencies_flat(GNode *dependencies_tree,
                                bool expanded,
                                const char *ref_path,
                                const sl_resolve_options *opts,
                                GList **out);

/**
 * scan the dependencies of current entry
 * @param entry_path the dependent
 * @param out_list out dependencies list
 * @return resolved of not
 */
bool sl_scan_dependencies(const char *entry_path, GList **out_list);

/**
 * free the dependencies tree
 * @param tree  the tree
 * @return freed or not
 */
bool sl_free_dependencies_tree(GNode *tree);

#endif //SHLIB_BIN_SRC_DEPENDENCY_RESOLVER_H_
