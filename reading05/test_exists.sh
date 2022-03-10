#!/bin/bash

SCRIPT=exists.py
WORKSPACE=/tmp/$SCRIPT.$(id -u)
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

echo "Checking reading05 $SCRIPT ..."

printf " %-40s ... " "exists.py"
./$SCRIPT * > /dev/null
if [ $? -ne 0 ]; then
    error "Failure"
else
    echo "Success"
fi

printf " %-40s ... " "exists.py *"
./$SCRIPT * > /dev/null
if [ $? -ne 0 ]; then
    error "Failure"
else
    echo "Success"
fi

printf " %-40s ... " "exists.py * ASDF"
./$SCRIPT * ASDF > /dev/null
if [ $? -ne 1 ]; then
    error "Failure"
else
    echo "Success"
fi

printf " %-40s ... " "exists.py /lib/*"
./$SCRIPT /lib/* > /dev/null
if [ $? -ne 0 ]; then
    error "Failure"
else
    echo "Success"
fi

TESTS=$(($(grep -c Success $0) - 2))
echo "   Score $(echo "scale=4; ($TESTS - $FAILURES) / $TESTS.0 * 1.0" | bc | awk '{printf "%0.2f\n", $1}') / 1.00"
printf "  Status "
if [ $FAILURES -eq 0 ]; then
    echo "Success"
else
    echo "Failure"
fi
echo
