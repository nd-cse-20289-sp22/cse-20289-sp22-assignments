#!/bin/bash

# Configuration

SCRIPT=demographics.py
WORKSPACE=/tmp/$SCRIPT.$(id -u)
FAILURES=0

# Functions

error() {
    echo "$@"
    [ -r $WORKSPACE/log ] && cat $WORKSPACE/log
    FAILURES=$((FAILURES + 1))
}

cleanup() {
    STATUS=${1:-$FAILURES}
    rm -fr $WORKSPACE
    exit $STATUS
}

default_output() {
    cat <<EOF
        2013    2014    2015    2016    2017    2018    2019    2020    2021    2022    2023    2024
========================================================================================================
   M      49      44      58      60      65     101      96      92      89     124     119     115
   F      14      12      16      19      26      45      54      43      46      41      47      58
--------------------------------------------------------------------------------------------------------
   B       3       2       4       1       5       3       3       4       6       4       1       4
   C      43      43      47      53      60     107      96      92      87     106      99     108
   N       1       1       1       7       5       5      13      14      13      14      17       8
   O       7       5       9       9      12      10      13       7       8      14      13      19
   S       7       4      10       9       3      13      10      10      11      17      26      20
   T       2       1       1       0       6       8      15       7       9       8       8      10
   U       0       0       2       0       0       0       0       1       1       1       2       4
--------------------------------------------------------------------------------------------------------
EOF
}

default_y2013_output() {
    cat <<EOF
        2013
================
   M      49
   F      14
----------------
   B       3
   C      43
   N       1
   O       7
   S       7
   T       2
   U       0
----------------
EOF
}

default_y2024_output() {
    cat <<EOF
        2024
================
   M     115
   F      58
----------------
   B       4
   C     108
   N       8
   O      19
   S      20
   T      10
   U       4
----------------
EOF
}

default_y2017_2019_2021_2023_output() {
    cat <<EOF
        2017    2019    2021    2023
========================================
   M      65      96      89     119
   F      26      54      46      47
----------------------------------------
   B       5       3       6       1
   C      60      96      87      99
   N       5      13      13      17
   O      12      13       8      13
   S       3      10      11      26
   T       6      15       9       8
   U       0       0       1       2
----------------------------------------
EOF
}

default_p_output() {
    cat <<EOF
        2013    2014    2015    2016    2017    2018    2019    2020    2021    2022    2023    2024
========================================================================================================
   M   77.8%   78.6%   78.4%   75.9%   71.4%   69.2%   64.0%   68.1%   65.9%   75.2%   71.7%   66.5%
   F   22.2%   21.4%   21.6%   24.1%   28.6%   30.8%   36.0%   31.9%   34.1%   24.8%   28.3%   33.5%
--------------------------------------------------------------------------------------------------------
   B    4.8%    3.6%    5.4%    1.3%    5.5%    2.1%    2.0%    3.0%    4.4%    2.4%    0.6%    2.3%
   C   68.3%   76.8%   63.5%   67.1%   65.9%   73.3%   64.0%   68.1%   64.4%   64.2%   59.6%   62.4%
   N    1.6%    1.8%    1.4%    8.9%    5.5%    3.4%    8.7%   10.4%    9.6%    8.5%   10.2%    4.6%
   O   11.1%    8.9%   12.2%   11.4%   13.2%    6.8%    8.7%    5.2%    5.9%    8.5%    7.8%   11.0%
   S   11.1%    7.1%   13.5%   11.4%    3.3%    8.9%    6.7%    7.4%    8.1%   10.3%   15.7%   11.6%
   T    3.2%    1.8%    1.4%    0.0%    6.6%    5.5%   10.0%    5.2%    6.7%    4.8%    4.8%    5.8%
   U    0.0%    0.0%    2.7%    0.0%    0.0%    0.0%    0.0%    0.7%    0.7%    0.6%    1.2%    2.3%
--------------------------------------------------------------------------------------------------------
EOF
}

default_G_output() {
    cat <<EOF
        2013    2014    2015    2016    2017    2018    2019    2020    2021    2022    2023    2024
========================================================================================================
   B       3       2       4       1       5       3       3       4       6       4       1       4
   C      43      43      47      53      60     107      96      92      87     106      99     108
   N       1       1       1       7       5       5      13      14      13      14      17       8
   O       7       5       9       9      12      10      13       7       8      14      13      19
   S       7       4      10       9       3      13      10      10      11      17      26      20
   T       2       1       1       0       6       8      15       7       9       8       8      10
   U       0       0       2       0       0       0       0       1       1       1       2       4
--------------------------------------------------------------------------------------------------------
EOF
}

default_E_output() {
    cat <<EOF
        2013    2014    2015    2016    2017    2018    2019    2020    2021    2022    2023    2024
========================================================================================================
   M      49      44      58      60      65     101      96      92      89     124     119     115
   F      14      12      16      19      26      45      54      43      46      41      47      58
--------------------------------------------------------------------------------------------------------
EOF
}

equality_output() {
    cat <<EOF
        2013    2014    2015    2016    2017    2018    2019
================================================================
   M       1       1       1       1       1       1       1
   F       1       1       1       1       1       1       1
----------------------------------------------------------------
   B       2       0       0       0       0       0       0
   C       0       2       0       0       0       0       0
   N       0       0       2       0       0       0       0
   O       0       0       0       2       0       0       0
   S       0       0       0       0       2       0       0
   T       0       0       0       0       0       2       0
   U       0       0       0       0       0       0       2
----------------------------------------------------------------
EOF
}

equality_y2016_p_output() {
    cat <<EOF
        2016
================
   M   50.0%
   F   50.0%
----------------
   B    0.0%
   C    0.0%
   N    0.0%
   O  100.0%
   S    0.0%
   T    0.0%
   U    0.0%
----------------
EOF
}

equality_y2016_p_E_output() {
    cat <<EOF
        2016
================
   M   50.0%
   F   50.0%
----------------
EOF
}

equality_y2016_p_E_G_output() {
    cat <<EOF
        2016
================
EOF
}

# Setup

mkdir $WORKSPACE

trap "cleanup" EXIT
trap "cleanup 1" INT TERM

# Tests

echo "Testing $SCRIPT ..."

printf "   %-40s ... " "Doctests"
grep -q '>>> load_demo_data' $SCRIPT
if [ $? -ne 0 ]; then
    UNITS=0
    echo "MISSING"
else
    python3 -m doctest -v $SCRIPT 2> /dev/null > $WORKSPACE/test
    TOTAL=$(grep 'tests.*items' $WORKSPACE/test | awk '{print $1}')
    PASSED=$(grep 'passed.*failed' $WORKSPACE/test | awk '{print $1}')
    UNITS=$(echo "scale=2; ($PASSED / $TOTAL) * 1.0" | bc)
    echo "$UNITS / 1.00"
fi

printf "   %-40s ... " "Bad arguments"
./$SCRIPT -bad &> /dev/null
if [ $? -eq 0 ]; then
    error "Failure"
else
    echo  "Success"
fi

printf "   %-40s ... " "-h"
./$SCRIPT -h 2>&1 | grep -i usage &> /dev/null
if [ $? -ne 0 ]; then
    error "Failure"
else
    echo  "Success"
fi

printf "   %-40s ... " "No arguments"
diff -W 220 -y <(./$SCRIPT) <(default_output) &> $WORKSPACE/log
if [ $? -ne 0 ]; then
    error "Failure"
else
    echo  "Success"
fi

printf "   %-40s ... " "fIRK"
diff -W 220 -y <(./$SCRIPT https://yld.me/raw/fIRK) <(default_output) &> $WORKSPACE/log
if [ $? -ne 0 ]; then
    error "Failure"
else
    echo  "Success"
fi

printf "   %-40s ... " "fIRK -y 2013"
diff -W 220 -y <(./$SCRIPT -y 2013) <(default_y2013_output) &> $WORKSPACE/log
if [ $? -ne 0 ]; then
    error "Failure"
else
    echo  "Success"
fi

printf "   %-40s ... " "fIRK -y 2024"
diff -W 220 -y <(./$SCRIPT -y 2024) <(default_y2024_output) &> $WORKSPACE/log
if [ $? -ne 0 ]; then
    error "Failure"
else
    echo  "Success"
fi

printf "   %-40s ... " "fIRK -y 2017,2021,2019,2023"
diff -W 220 -y <(./$SCRIPT -y 2017,2021,2019,2023) <(default_y2017_2019_2021_2023_output) &> $WORKSPACE/log
if [ $? -ne 0 ]; then
    error "Failure"
else
    echo  "Success"
fi

printf "   %-40s ... " "fIRK -p"
diff -W 220 -y <(./$SCRIPT -p) <(default_p_output) &> $WORKSPACE/log
if [ $? -ne 0 ]; then
    error "Failure"
else
    echo  "Success"
fi

printf "   %-40s ... " "fIRK -G"
diff -W 220 -y <(./$SCRIPT -G) <(default_G_output) &> $WORKSPACE/log
if [ $? -ne 0 ]; then
    error "Failure"
else
    echo  "Success"
fi

printf "   %-40s ... " "fIRK -E"
diff -W 220 -y <(./$SCRIPT -E) <(default_E_output) &> $WORKSPACE/log
if [ $? -ne 0 ]; then
    error "Failure"
else
    echo  "Success"
fi

printf "   %-40s ... " "ilG"
diff -W 220 -y <(./$SCRIPT https://yld.me/raw/ilG) <(equality_output) &> $WORKSPACE/log
if [ $? -ne 0 ]; then
    error "Failure"
else
    echo  "Success"
fi

printf "   %-40s ... " "ilG -y 2016 -p"
diff -W 220 -y <(./$SCRIPT -y 2016 -p https://yld.me/raw/ilG) <(equality_y2016_p_output) &> $WORKSPACE/log
if [ $? -ne 0 ]; then
    error "Failure"
else
    echo  "Success"
fi

printf "   %-40s ... " "ilG -y 2016 -p -E"
diff -W 220 -y <(./$SCRIPT -y 2016 -p -E https://yld.me/raw/ilG) <(equality_y2016_p_E_output) &> $WORKSPACE/log
if [ $? -ne 0 ]; then
    error "Failure"
else
    echo  "Success"
fi

printf "   %-40s ... " "ilG -y 2016 -p -E -G"
diff -W 220 -y <(./$SCRIPT -y 2016 -p -E -G https://yld.me/raw/ilG) <(equality_y2016_p_E_G_output) &> $WORKSPACE/log
if [ $? -ne 0 ]; then
    error "Failure"
else
    echo  "Success"
fi

TESTS=$(($(grep -c Success $0) - 2))

echo
echo "   Score $(echo "scale=4; $UNITS + ($TESTS - $FAILURES) / $TESTS.0 * 5.0" | bc | awk '{printf "%0.2f\n", $1}') / 6.00"
printf "  Status "

if [ $UNITS != "1.00" -o $FAILURES -gt 0 ]; then
    FAILURES=1
    echo "Failure"
else
    echo "Success"
fi
echo
