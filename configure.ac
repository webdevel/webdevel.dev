#                                               -*- Autoconf -*-
# Process this file with autoconf to produce a configure script.

AC_PREREQ([2.69])
AC_INIT([webdevel.dev],[0.1.0],[https://github.com/webdevel/webdevel.dev/issues],,[https://github.com/webdevel/webdevel.dev/])
AC_CONFIG_SRCDIR([src/main.c])
AC_CONFIG_HEADERS([src/config.h])

#####################
# Checks for programs
#####################
AC_PROG_AWK
AC_PROG_CC
AC_PROG_MAKE_SET
AC_LANG(C)
AC_PATH_PROG(LD,ld)

######################
# Checks for libraries
######################
AC_CHECK_LIB(fcgi​,FCGI_Accept)

#########################
# Checks for header files
#########################
AC_CHECK_HEADERS([stdio.h stdlib.h unistd.h fcgi_stdio.h])

# Checks for typedefs

# Checks for structures

# Checks for compiler characteristics

##############################
# Checks for library functions
##############################
AC_CHECK_FUNCS([FCGI_Accept])
AC_CHECK_FUNCS([getenv])
AC_CHECK_FUNCS([getpid])

#######################
# Generate output files
#######################
AC_CONFIG_FILES([tasks/config.mk])
AC_OUTPUT
