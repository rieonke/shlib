//
// Created by Rieon Ke on 2019/10/5.
//

#include "util.h"
#include <glib.h>

void expand_absolute_path(const char *path, char **out) {
  if (g_path_is_absolute(path)) {
    *out = strdup(path);
  } else if (path[0] == '~') {
    const char *home = g_get_home_dir();

    char *contents = strdup(path);
    memmove(contents, contents + 1, strlen(contents));

    *out = g_malloc0_n(strlen(path) + strlen(home), sizeof(char));
    strncpy(*out, home, strlen(home));
    strncat(*out, contents, strlen(contents));
    free(contents);

  } else {
    *out = realpath(path, NULL);
  }
}
