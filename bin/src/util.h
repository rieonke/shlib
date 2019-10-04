//
// Created by Rieon Ke on 2019/10/5.
//

#ifndef SHLIB_BIN_SRC_UTIL_H_
#define SHLIB_BIN_SRC_UTIL_H_

#include <glib.h>
#define FREE_SAFER(pointer) if (pointer != NULL) free(pointer)
#define STR_APPEND(dest, str) if ( dest != NULL) { \
                                dest = realloc(dest, (strlen(str) + strlen(dest)) * sizeof(char)); \
                                strncat(dest,str,strlen(str)); \
                              }
#define STR_APPEND_END(dest) STR_APPEND(dest, "\0")

void expand_absolute_path(const char *path, char **out);

#endif //SHLIB_BIN_SRC_UTIL_H_
