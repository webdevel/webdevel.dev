#                                               -*- Autoconf -*-
# Process this file with autoconf to produce a configure script.

AC_PREREQ([2.69])
AC_INIT([webdevel.dev],[0.1.0],[https://github.com/webdevel/webdevel.dev/issues],,[https://github.com/webdevel/webdevel.dev/])
AC_CONFIG_SRCDIR([src/webdevel.dev.c])
AC_CONFIG_HEADERS([src/config.h])

#####################
# Checks for programs
#####################
AC_PROG_AWK
: ${CFLAGS="-g -O3 -Wall -Wextra"}
AC_PROG_CC
AC_PROG_GREP
AC_PROG_LN_S
AC_PROG_MAKE_SET
AC_PROG_SED
AC_LANG(C)

######################
# Checks for libraries
######################
AC_CHECK_LIB(fcgi,FCGI_Accept,,-Wl\\,-lfcgi)

#########################
# Checks for header files
#########################
AC_CHECK_HEADERS([errno.h stdarg.h stdio.h stdlib.h string.h unistd.h fastcgi.h fcgi_stdio.h fcgiapp.h fcgios.h])

#####################
# Checks for typedefs
#####################
AC_TYPE_INT64_T
AC_TYPE_UINT64_T
AC_TYPE_PID_T
AC_TYPE_SIZE_T
AC_TYPE_SSIZE_T
AC_CHECK_TYPES([FCGI_Header],[],[],[[#include <fastcgi.h>]])
AC_CHECK_TYPES([FCGI_BeginRequestBody],[],[],[[#include <fastcgi.h>]])

#######################
# Checks for structures
#######################
AC_CHECK_MEMBERS([struct FCGX_Stream.data],[],[],[[#include <fcgiapp.h>]])

#####################################
# Checks for compiler characteristics
#####################################
AC_C_CONST

##############################
# Checks for library functions
##############################
AC_CHECK_FUNCS([FCGI_Accept FCGI_printf getenv getpid])
AC_FUNC_REALLOC

#######################
# Generate output files
#######################
AC_CONFIG_FILES([tasks/config.mk])
AC_OUTPUT
