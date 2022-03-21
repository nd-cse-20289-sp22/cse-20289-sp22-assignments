#!/bin/bash

WORKSPACE=/tmp/grep.$(id -u)
FAILURES=0

error() {
    echo "$@"
    [ -r $WORKSPACE/test ] && (echo; cat $WORKSPACE/test; echo)
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

echo "Checking reading09 grep ..."

printf " %-40s ... " "grep usage (-h)"
if ! ./grep -h |& grep -q -i usage; then
    error "Failure"
else
    echo "Success"
fi

printf " %-40s ... " "grep usage (no arguments)"
if ! ./grep |& grep -q -i usage; then
    error "Failure"
else
    echo "Success"
fi

printf " %-40s ... " "grep root /etc/passwd"
diff -y <(./grep root < /etc/passwd) <(/bin/grep root </etc/passwd) &> $WORKSPACE/test
if [ $? -ne 0 ]; then
    error "Failure"
else
    echo "Success"
fi

printf " %-40s ... " "grep root /etc/passwd (valgrind)"
valgrind --leak-check=full ./grep root < /etc/passwd &> $WORKSPACE/test
if [ $? -ne 0 -o "$(awk '/ERROR SUMMARY/ {print $4}' $WORKSPACE/test)" -ne 0 ]; then
    error "Failure"
else
    echo "Success"
fi

printf " %-40s ... " "grep login /etc/passwd"
diff -y <(./grep login < /etc/passwd) <(/bin/grep login </etc/passwd) &> $WORKSPACE/test
if [ $? -ne 0 ]; then
    error "Failure"
else
    echo "Success"
fi

printf " %-40s ... " "grep login /etc/passwd (valgrind)"
valgrind --leak-check=full ./grep login < /etc/passwd &> $WORKSPACE/test
if [ $? -ne 0 -o "$(awk '/ERROR SUMMARY/ {print $4}' $WORKSPACE/test)" -ne 0 ]; then
    error "Failure"
else
    echo "Success"
fi

printf " %-40s ... " "grep asdf /etc/passwd"
diff -y <(./grep asdf < /etc/passwd) <(/bin/grep asdf </etc/passwd) &> $WORKSPACE/test
if [ $? -ne 0 ]; then
    error "Failure"
else
    echo "Success"
fi

printf " %-40s ... " "grep asdf /etc/passwd (valgrind)"
valgrind --leak-check=full ./grep asdf < /etc/passwd &> $WORKSPACE/test
if [ $? -eq 0 -o "$(awk '/ERROR SUMMARY/ {print $4}' $WORKSPACE/test)" -ne 0 ]; then
    error "Failure"
else
    echo "Success"
fi

TESTS=$(($(grep -c Success $0) - 2))
echo
echo "   Score $(echo "scale=4; ($TESTS - $FAILURES) / $TESTS.0 * 1.0" | bc | awk '{printf "%0.2f\n", $1}') / 1.00"
printf "  Status "
if [ $FAILURES -eq 0 ]; then
    echo "Success"
else
    echo "Failure"
fi
echo
