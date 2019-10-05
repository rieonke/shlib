//
// Created by Rieon Ke on 2019/10/5.
//


#include "../dependency_resolver.h"
#include <assert.h>
#include <gmodule.h>

int main(int argc, char *argv[]) {

  const char *SHLIB_PATH = getenv("SHLIB_PATH");
  const char *LIB_NAME = "/core/string.sh";

  char *lib = g_malloc0_n(strlen(SHLIB_PATH) + strlen(LIB_NAME) + 1, sizeof(char));
  strncat(lib, SHLIB_PATH, strlen(SHLIB_PATH));
  strncat(lib, LIB_NAME, strlen(LIB_NAME));
  strncat(lib, "\0", 1);

  char *out;
  bool result = sl_resolve_lib_real_path(lib, NULL, NULL, &out);

  assert(result == true);
  assert(out != NULL);

  printf("%s\n", out);

  free(out);
  free(lib);

  return 0;
}