#!/bin/bash

WORKSPACE=/tmp/translations.$(id -u)
FAILURES=0

error() {
    echo "$@"
    echo
    [ -r $WORKSPACE/test ] && cat $WORKSPACE/test
    echo
    FAILURES=$((FAILURES + 1))
}

cleanup() {
    STATUS=${1:-$FAILURES}
    rm -fr $WORKSPACE
    exit $STATUS
}

mkdir $WORKSPACE

trap "cleanup" EXIT
trap "cleanup 1" INT TERM

echo "Checking reading08 translations ..."

printf " %-40s ... " "translate1.py"
./translate1.py | diff -y - <(grep -Po ':1\d*0:' /etc/passwd | wc -l) > $WORKSPACE/test
if [ $? -ne 0 ]; then
    error "Failure"
else
    echo "Success"
fi

printf " %-40s ... " "translate2.py"
./translate2.py | diff -y - <(/bin/ls -ld /etc/* | awk '{print $4}' | sort | uniq) > $WORKSPACE/test
if [ $? -ne 0 ]; then
    error "Failure"
else
    echo "Success"
fi


printf " %-40s ... " "translate3.py"
./translate3.py | diff -y - <(curl -sLk http://yld.me/raw/fDIO | cut -d , -f 4 | grep -Eo '^M.*' | sort) > $WORKSPACE/test
if [ $? -ne 0 ]; then
    error "Failure"
else
    echo "Success"
fi

printf " %-40s ... " "translate4.py"
./translate4.py | diff -y - <(cat /etc/passwd | cut -d : -f 7 | sort | uniq -c | sort -srn) > $WORKSPACE/test
if [ $? -ne 0 ]; then
    error "Failure"
else
    echo "Success"
fi


TESTS=$(($(grep -c Success $0) - 2))
echo
echo "   Score $(echo "scale=4; ($TESTS - $FAILURES) / $TESTS.0 * 2.0" | bc | awk '{printf "%0.2f\n", $1}') / 2.00"
printf "  Status "
if [ $FAILURES -eq 0 ]; then
    echo "Success"
else
    echo "Failure"
fi
echo
