#!/bin/csh
foreach variable (`env | grep '^NCARG_'`)
    set var_name=`echo "$variable" | cut -d= -f1`
    set var_value="`echo -n "$variable" | cut -d= -f2-`"
    eval "setenv OLD_${var_name} '${var_value}'"
    eval "unset ${var_name}"
end

setenv NCARG_ROOT "${CONDA_PREFIX}"
