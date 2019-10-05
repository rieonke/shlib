//
// Created by Rieon Ke on 2019/10/5.
//


#include "../dependency_resolver.h"
#include <assert.h>
#include <gmodule.h>

int main(int argc, char *argv[]) {

  const char *SHLIB_PATH = getenv("SHLIB_PATH");
  const char *LIB_NAME = "core.string";

  sl_resolve_options opts = {
      .global_search_path= strdup(SHLIB_PATH)
  };

  char *out;
  bool result = sl_resolve_lib_real_path(LIB_NAME, NULL, &opts, &out);

  assert(result == true);
  assert(out != NULL);

  printf("%s\n", out);

  free(out);
  free(opts.global_search_path);

  return 0;
}