#!/bin/bash

# Configuration

SCRIPT=reddit.py
WORKSPACE=/tmp/$SCRIPT.$(id -u)
FAILURES=0

export PYTHONIOENCODING=utf-8 # Work around Unicode Shenanigans on GitLab-CI

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

las_test() {
    ./$SCRIPT linuxactionshow > $WORKSPACE/output || return 1
    [ $(wc -l < $WORKSPACE/output) -eq 29 ] || return 1
    grep -q Matrix $WORKSPACE/output || return 1
    grep -q LAS $WORKSPACE/output || return 1
    grep -q FCC $WORKSPACE/output || return 1
}

las_test_limit() {
    ./$SCRIPT -n 1 linuxactionshow | sed -E 's/Score: [0-9]+/Score: 0/' > $WORKSPACE/output || return 1
    [ $(wc -l < $WORKSPACE/output) -eq 2 ] || return 1
    diff -W 220 -y $WORKSPACE/output <(las_test_limit_output) > $WORKSPACE/log
}

las_test_limit_output() {
    cat <<EOF
   1.	Matrix.org | An open network for secure, decentralized commu (Score: 0)
	https://matrix.org/
EOF
}

las_test_orderby() {
    ./$SCRIPT -o url linuxactionshow > $WORKSPACE/output || return 1
    [ $(wc -l < $WORKSPACE/output) -eq 29 ] || return 1
    [ "$(cat $WORKSPACE/output | head -n 2 | tail -n 1 | sed -E 's/^[[:space:]]+//')" = "http://101.opensuse.org/" ]
}

las_test_titlelen() {
    ./$SCRIPT -t 10 linuxactionshow > $WORKSPACE/output || return 1
    [ $(wc -l < $WORKSPACE/output) -eq 29 ] || return 1
    [ "$(cat $WORKSPACE/output | grep -v http | wc -c)" -eq 303 ]
}

las_test_shorten() {
    ./$SCRIPT -s linuxactionshow > $WORKSPACE/output || return 1
    [ $(wc -l < $WORKSPACE/output) -eq 29 ] || return 1
    grep -q 'yCjytQ' $WORKSPACE/output || return 1
    grep -q 'jNJAHF' $WORKSPACE/output || return 1
    grep -q 'VClyLU' $WORKSPACE/output || return 1
}

pop_output() {
    cat <<EOF
   1.	Gaming on Pop; and desktop responsiveness for low end system (Score: 188)
	https://www.reddit.com/r/pop_os/comments/sh4zdr/gaming_on_pop_and_desktop_responsiveness_for_low/

   2.	ThinkPad battery always fully charging/not actually charging (Score: 75)
	https://www.reddit.com/gallery/srmru9

   3.	Pop collaboration with Relm4 / Writing GTK applications for  (Score: 67)
	https://www.reddit.com/r/pop_os/comments/sh6syh/pop_collaboration_with_relm4_writing_gtk/

   4.	grateful i joined this rabbit hole called Linux thanks pop_o (Score: 49)
	https://www.reddit.com/r/pop_os/comments/ss69nt/grateful_i_joined_this_rabbit_hole_called_linux/

   5.	Can i run pop!_os on a macbookair7,2? (Score: 32)
	https://www.reddit.com/r/pop_os/comments/srhqp9/can_i_run_pop_os_on_a_macbookair72/

   6.	Is there a way to remove or change these default folders in  (Score: 29)
	https://i.redd.it/nj3gn3r91nh81.png

   7.	Help pls stuck on here on pop os installation I have tried a (Score: 17)
	https://i.redd.it/5ovrv34jinh81.jpg

   8.	Can my laptop run POP_OS or at least, a distro that's simila (Score: 10)
	https://www.reddit.com/r/pop_os/comments/ss6qpx/can_my_laptop_run_pop_os_or_at_least_a_distro/

   9.	Gaming experiments on Pop OS (Score: 8)
	https://www.reddit.com/r/pop_os/comments/srw3mn/gaming_experiments_on_pop_os/

  10.	What tiling window manager does Pop!_OS use? (Score: 8)
	https://www.reddit.com/r/pop_os/comments/srqhy2/what_tiling_window_manager_does_pop_os_use/
EOF
}

pop_limit_output() {
    cat <<EOF
   1.	Gaming on Pop; and desktop responsiveness for low end system (Score: 188)
	https://www.reddit.com/r/pop_os/comments/sh4zdr/gaming_on_pop_and_desktop_responsiveness_for_low/

   2.	ThinkPad battery always fully charging/not actually charging (Score: 75)
	https://www.reddit.com/gallery/srmru9

   3.	Pop collaboration with Relm4 / Writing GTK applications for  (Score: 67)
	https://www.reddit.com/r/pop_os/comments/sh6syh/pop_collaboration_with_relm4_writing_gtk/

   4.	grateful i joined this rabbit hole called Linux thanks pop_o (Score: 49)
	https://www.reddit.com/r/pop_os/comments/ss69nt/grateful_i_joined_this_rabbit_hole_called_linux/

   5.	Can i run pop!_os on a macbookair7,2? (Score: 32)
	https://www.reddit.com/r/pop_os/comments/srhqp9/can_i_run_pop_os_on_a_macbookair72/
EOF
}

pop_limit_orderby_output() {
    cat <<EOF
   1.	20.04LTS abandoned early? (Score: 3)
	https://www.reddit.com/r/pop_os/comments/srw2q6/2004lts_abandoned_early/

   2.	A few questions - Pop!_OS beginner here. (Score: 3)
	https://www.reddit.com/r/pop_os/comments/srsrq9/a_few_questions_pop_os_beginner_here/

   3.	Asus N53SM nvidia driver problems (Score: 1)
	https://www.reddit.com/r/pop_os/comments/ssc77p/asus_n53sm_nvidia_driver_problems/

   4.	Can i run pop!_os on a macbookair7,2? (Score: 32)
	https://www.reddit.com/r/pop_os/comments/srhqp9/can_i_run_pop_os_on_a_macbookair72/

   5.	Can my laptop run POP_OS or at least, a distro that's simila (Score: 10)
	https://www.reddit.com/r/pop_os/comments/ss6qpx/can_my_laptop_run_pop_os_or_at_least_a_distro/
EOF
}

pop_limit_orderby_titlelen_output() {
    cat <<EOF
   1.	Help pls stuck on he (Score: 17)
	https://i.redd.it/5ovrv34jinh81.jpg

   2.	I got this problem s (Score: 2)
	https://i.redd.it/60irokeqegh61.jpg

   3.	I got this problem s (Score: 2)
	https://i.redd.it/60irokeqegh61.jpg

   4.	What does this error (Score: 3)
	https://i.redd.it/97say08htsh81.jpg

   5.	How to focus on the  (Score: 5)
	https://i.redd.it/g5r3pbl7jqh81.jpg
EOF
}

pop_limit_orderby_titlelen_shorten_output() {
    cat <<EOF
   1.	Gaming on Pop; and desktop responsivenes (Score: 188)
	https://is.gd/IXfOFX

   2.	ThinkPad battery always fully charging/n (Score: 75)
	https://is.gd/vYzBbi
EOF
}

# Setup

mkdir $WORKSPACE

trap "cleanup" EXIT
trap "cleanup 1" INT TERM

# Tests

echo "Testing $SCRIPT ..."

printf "   %-40s ... " "Doctests"
grep -q '>>> load_reddit_data' $SCRIPT
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
./$SCRIPT 2>&1 | grep -i usage &> /dev/null
if [ $? -ne 0 ]; then
    error "Failure"
else
    echo  "Success"
fi


printf "   %-40s ... " "linuxactionshow"
if ! las_test; then
    error "Failure"
else
    echo  "Success"
fi

rm -f $WORKSPACE/log
printf "   %-40s ... " "linuxactionshow (-n 1)"
if ! las_test_limit ; then
    [ ! -r $WORKSPACE/log ] || mv $WORKSPACE/output $WORKSPACE/log
    error "Failure"
else
    echo  "Success"
fi

printf "   %-40s ... " "linuxactionshow (-o url)"
if ! las_test_orderby ; then
    mv $WORKSPACE/output $WORKSPACE/log
    error "Failure"
else
    echo  "Success"
fi

printf "   %-40s ... " "linuxactionshow (-t 10)"
if ! las_test_titlelen ; then
    mv $WORKSPACE/output $WORKSPACE/log
    error "Failure"
else
    echo  "Success"
fi

printf "   %-40s ... " "linuxactionshow (-s)"
if ! las_test_shorten ; then
    mv $WORKSPACE/output $WORKSPACE/log
    error "Failure"
else
    echo  "Success"
fi

printf "   %-40s ... " "pop-os"
diff -W 220 -y <(./$SCRIPT https://yld.me/raw/cIdb) <(pop_output) > $WORKSPACE/log
if [ $? -ne 0 ]; then
    error "Failure"
else
    echo  "Success"
fi

printf "   %-40s ... " "pop-os (-n 5)"
diff -W 220 -y <(./$SCRIPT -n 5 https://yld.me/raw/cIdb) <(pop_limit_output) > $WORKSPACE/log
if [ $? -ne 0 ]; then
    error "Failure"
else
    echo  "Success"
fi

printf "   %-40s ... " "pop-os (-n 5 -o title)"
diff -W 220 -y <(./$SCRIPT -n 5 -o title https://yld.me/raw/cIdb) <(pop_limit_orderby_output) > $WORKSPACE/log
if [ $? -ne 0 ]; then
    error "Failure"
else
    echo  "Success"
fi

printf "   %-40s ... " "pop-os (-n 5 -o url -t 20)"
diff -W 220 -y <(./$SCRIPT -n 5 -o url -t 20 https://yld.me/raw/cIdb) <(pop_limit_orderby_titlelen_output) > $WORKSPACE/log
if [ $? -ne 0 ]; then
    error "Failure"
else
    echo  "Success"
fi

printf "   %-40s ... " "pop-os (-n 2 -o score -t 40 -s)"
diff -W 220 -y <(./$SCRIPT -n 2 -o score -t 40 -s https://yld.me/raw/cIdb) <(pop_limit_orderby_titlelen_shorten_output) > $WORKSPACE/log
if [ $? -ne 0 ]; then
    error "Failure"
else
    echo  "Success"
fi

TESTS=$(($(grep -c Success $0) - 2))

echo
echo "   Score $(echo "scale=4; $UNITS + ($TESTS - $FAILURES) / $TESTS.0 * 4.0" | bc | awk '{printf "%0.2f\n", $1}') / 5.00"
printf "  Status "
if [ $UNITS != "1.00" -o $FAILURES -gt 0 ]; then
    FAILURES=1
    echo "Failure"
else
    echo "Success"
fi
echo
