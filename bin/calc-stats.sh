#!/bin/sh

########################################################################
# Determine the average, minimum and maximum values of a list of numbers
# from stdin.
#
sort -n | awk -v label="${1:-Not specified}" '
  BEGIN {
    c = 0;
    sum = 0;
  }
  $1 ~ /^(\-)?[0-9]*(\.[0-9]*)?$/ {
    a[c++] = $1;
    sum += $1;
  }
  END {
    ave = sum / c;
    printf "# Label: %s\n", label ;
    printf "%-7s %6s %6s %6s\n", "# Count", "Avg", "Min", "Max" ;
    printf "%7d %6.1f %6.1f %6.1f\n", c, ave, a[0], a[c-1];
  }
'
