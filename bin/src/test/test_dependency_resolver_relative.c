//
// Created by Rieon Ke on 2019/10/5.
//


#include "../dependency_resolver.h"
#include <assert.h>
#include <gmodule.h>

int main(int argc, char *argv[]) {

  const char *SHLIB_PATH = getenv("SHLIB_PATH");
  const char *ENTRY_NAME = "/../test/main.sh";
  const char *LIB_NAME = "./demo_lib.sh";

  char *lib = g_malloc0_n(strlen(SHLIB_PATH) + strlen(ENTRY_NAME) + 1, sizeof(char));
  strncat(lib, SHLIB_PATH, strlen(SHLIB_PATH));
  strncat(lib, ENTRY_NAME, strlen(ENTRY_NAME));
  strncat(lib, "\0", 1);

  char *out;
  bool result = sl_resolve_lib_real_path(LIB_NAME, lib, NULL, &out);

  assert(result == true);
  assert(out != NULL);

  printf("%s\n", out);

  free(out);

  return 0;
}