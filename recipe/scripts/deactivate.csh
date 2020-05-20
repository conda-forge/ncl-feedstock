#!/bin/csh
unsetenv NCARG_ROOT

foreach variable (`env | grep '^OLD_NCARG_'`)
    set var_name=`echo "$variable" | cut -d= -f1`
    set var_value="`echo -n "$variable" | cut -d= -f2-`"
    eval "setenv `echo ${var_name} | cut -c 5-` '${var_value}'"
    eval "unsetenv ${var_name}"
end
