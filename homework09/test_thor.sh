#!/bin/bash

PROGRAM=${1:-bin/thor}
WORKSPACE=/tmp/thor.$(id -u)
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

check_contents() {
    python3 <<EOF
import sys

stdout_curl = sorted(open('$WORKSPACE/stdout.curl', 'rb').read())
stdout_thor = sorted(open('$WORKSPACE/stdout.thor', 'rb').read())

sys.exit(0 if stdout_curl == stdout_thor else 1)
EOF
}

compute_metrics() {
    rm -f "$WORKSPACE/stdout.curl"
    python3 <<EOF
import concurrent.futures
import os
import requests
import time

def wget(url):
    start_time  = time.time()
    url         = 'http://' + url if not url.startswith('http://') else url
    response    = requests.get(url, allow_redirects=False)
    path        = "$WORKSPACE/stdout.curl"
    with open(path, 'ab') as fs:
        fs.write(response.content)
    return (len(response.content), time.time() - start_time)

with concurrent.futures.ProcessPoolExecutor($HAMMERS) as executor:
    data = list(executor.map(wget, ["$URL"]*$HAMMERS))

bytes        = sum(b for b, t in data)
elapsed_time = sum(t for b, t in data)
bandwidth    = bytes / (1<<20) / elapsed_time
print(f'ELAPSED_TIME_MIN={elapsed_time * 0.10}')
print(f'ELAPSED_TIME_MAX={elapsed_time * 2.50}')
print(f'BANDWIDTH_MIN={bandwidth * 0.10}')
print(f'BANDWIDTH_MAX={bandwidth * 2.50}')
EOF
}

check_metrics() {
    python3 > $WORKSPACE/test <<EOF
import re
import sys

bandwidth    = []
elapsed_time = None
for line in open('$WORKSPACE/stderr.thor'):
    match = re.findall(r'Bandwidth: ([0-9\\.]+) MB/s', line)
    if match:
        bandwidth.append(float(match[0]))
    elif line.startswith('Elapsed'):
        elapsed_time = float(line.split()[2])

if len(bandwidth) == $HAMMERS \\
   and ($BANDWIDTH_MIN <= sum(bandwidth)/len(bandwidth) <= $BANDWIDTH_MAX) \\
   and ($ELAPSED_TIME_MIN <= elapsed_time <= $ELAPSED_TIME_MAX):
    sys.exit(0)
else:
    print(f'ELAPSED_TIME_MIN=$ELAPSED_TIME_MIN')
    print(f'ELAPSED_TIME_MAX=$ELAPSED_TIME_MAX')
    print(f'elapsed_time={elapsed_time}')
    print(f'BANDWIDTH_MIN=$BANDWIDTH_MIN')
    print(f'BANDWIDTH_MAX=$BANDWIDTH_MAX')
    print(f'bandwidth={sum(bandwidth)/len(bandwidth)}')
    sys.exit(1)
EOF
}

check_hammers() {
    python3 <<EOF
import sys

clones = sum(1 for line in open('$WORKSPACE/stderr.thor') if 'CLONE_CHILD' in line)
waits  = sum(1 for line in open('$WORKSPACE/stderr.thor') if 'WEXITSTATUS' in line)
sys.exit(0 if clones == waits == $HAMMERS else 1)
EOF

}

check_concurrency() {
    python3 <<EOF
import sys
clones = 0
for line in open('$WORKSPACE/stderr.thor'):
    if 'CLONE_CHILD' in line:
        clones += 1

    if 'WEXITSTATUS' in line:
        sys.exit(1)

    if clones == $HAMMERS:
        sys.exit(0)

sys.exit(1)
EOF
}

# Tests -----------------------------------------------------------------------

export LD_LIBRARY_PATH=$LD_LIBRRARY_PATH:.

mkdir $WORKSPACE

trap "cleanup" EXIT
trap "cleanup 1" INT TERM

echo "Testing thor..."

if [ ! -x $PROGRAM ]; then
    echo "Failure: $PROGRAM is not executable!"
    exit 1
fi

# Usage -----------------------------------------------------------------------

printf " %-50s ... " "thor"
$PROGRAM &> $WORKSPACE/test
if [ $? -eq 0 ] || ! grep -q -i 'usage' $WORKSPACE/test; then
    error "Failure"
else
    echo "Success"
fi

printf " %-50s ... " "thor -h"
$PROGRAM -h &> $WORKSPACE/test
if [ $? -ne 0 ] || ! grep -q -i 'usage' $WORKSPACE/test; then
    error "Failure"
else
    echo "Success"
fi

printf " %-50s ... " "thor -?"
$PROGRAM -? &> $WORKSPACE/test
if [ $? -eq 0 ] || ! grep -q -i 'usage' $WORKSPACE/test; then
    error "Failure"
else
    echo "Success"
fi

rm -f $WORKSPACE/test

# http://example.com -----------------------------------------------------------

URL=http://example.com
HAMMERS=1
eval $(compute_metrics)

printf " %-50s ... " "thor $URL"
strace -e clone,wait4 $PROGRAM $URL > $WORKSPACE/stdout.thor 2> $WORKSPACE/stderr.thor
if [ $? -ne 0 ] ; then
    error "Failure (Exit Status)"
elif ! check_contents; then
    error "Failure (Contents)"
elif ! check_metrics; then
    error "Failure (Metrics)"
elif ! check_hammers; then
    error "Failure (Hammers)"
elif ! check_concurrency; then
    error "Failure (Concurrency)"
else
    echo "Success"
fi

sleep 1

HAMMERS=2
eval $(compute_metrics)
printf " %-50s ... " "thor -n $HAMMERS $URL"
strace -e clone,wait4 $PROGRAM -n $HAMMERS $URL > $WORKSPACE/stdout.thor 2> $WORKSPACE/stderr.thor
if [ $? -ne 0 ] ; then
    error "Failure (Exit Status)"
elif ! check_contents; then
    error "Failure (Contents)"
elif ! check_metrics; then
    error "Failure (Metrics)"
elif ! check_hammers; then
    error "Failure (Hammers)"
elif ! check_concurrency; then
    error "Failure (Concurrency)"
else
    echo "Success"
fi

# http://nd.edu ---------------------------------------------------------------

URL=http://nd.edu
HAMMERS=1
eval $(compute_metrics)

printf " %-50s ... " "thor $URL"
strace -e clone,wait4 $PROGRAM $URL > $WORKSPACE/stdout.thor 2> $WORKSPACE/stderr.thor
if [ $? -eq 0 ] ; then
    error "Failure (Exit Status)"
elif [ -s $WORKSPACE/stdout.thor ] ; then
    error "Failure (Contents)"
    diff -y $WORKSPACE/stdout.thor $WORKSPACE/stdout.curl
elif ! check_hammers; then
    error "Failure (Hammers)"
elif ! check_concurrency; then
    error "Failure (Concurrency)"
else
    echo "Success"
fi

sleep 1

HAMMERS=2
printf " %-50s ... " "thor -n $HAMMERS $URL"
strace -e clone,wait4 $PROGRAM -n $HAMMERS $URL > $WORKSPACE/stdout.thor 2> $WORKSPACE/stderr.thor
if [ $? -eq 0 ] ; then
    error "Failure (Exit Status)"
elif [ -s $WORKSPACE/stdout.thor ] ; then
    error "Failure (Contents)"
elif ! check_hammers; then
    error "Failure (Hammers)"
elif ! check_concurrency; then
    error "Failure (Concurrency)"
else
    echo "Success"
fi

# h4x0r.space -----------------------------------------------------------------

URL=h4x0r.space
HAMMERS=1
eval $(compute_metrics)

printf " %-50s ... " "thor $URL"
strace -e clone,wait4 $PROGRAM $URL > $WORKSPACE/stdout.thor 2> $WORKSPACE/stderr.thor
if [ $? -ne 0 ] ; then
    error "Failure (Exit Status)"
elif ! check_contents; then
    error "Failure (Contents)"
elif ! check_metrics; then
    error "Failure (Metrics)"
elif ! check_hammers; then
    error "Failure (Hammers)"
elif ! check_concurrency; then
    error "Failure (Concurrency)"
else
    echo "Success"
fi

sleep 1

HAMMERS=4
eval $(compute_metrics)
printf " %-50s ... " "thor -n $HAMMERS $URL"
strace -e clone,wait4 $PROGRAM -n $HAMMERS $URL > $WORKSPACE/stdout.thor 2> $WORKSPACE/stderr.thor
if [ $? -ne 0 ] ; then
    error "Failure (Exit Status)"
elif ! check_contents; then
    error "Failure (Contents)"
elif ! check_metrics; then
    error "Failure (Metrics)"
elif ! check_hammers; then
    error "Failure (Hammers)"
elif ! check_concurrency; then
    error "Failure (Concurrency)"
else
    echo "Success"
fi

# h4x0r.space:9898/walden.txt --------------------------------------------------

URL=h4x0r.space:9898/walden.txt
HAMMERS=1
eval $(compute_metrics)

printf " %-50s ... " "thor $URL"
strace -e clone,wait4 $PROGRAM $URL > $WORKSPACE/stdout.thor 2> $WORKSPACE/stderr.thor
if [ $? -ne 0 ] ; then
    error "Failure (Exit Status)"
elif ! check_contents; then
    error "Failure (Contents)"
elif ! check_metrics; then
    error "Failure (Metrics)"
elif ! check_hammers; then
    error "Failure (Hammers)"
elif ! check_concurrency; then
    error "Failure (Concurrency)"
else
    echo "Success"
fi

sleep 1

HAMMERS=4
eval $(compute_metrics)
printf " %-50s ... " "thor -n $HAMMERS $URL"
strace -e clone,wait4 $PROGRAM -n $HAMMERS $URL > $WORKSPACE/stdout.thor 2> $WORKSPACE/stderr.thor
if [ $? -ne 0 ] ; then
    error "Failure (Exit Status)"
elif ! check_contents; then
    error "Failure (Contents)"
elif ! check_metrics; then
    error "Failure (Metrics)"
elif ! check_hammers; then
    error "Failure (Hammers)"
elif ! check_concurrency; then
    error "Failure (Concurrency)"
else
    echo "Success"
fi

# h4x0r.space:9898/gatsby.txt --------------------------------------------------

URL=h4x0r.space:9898/gatsby.txt
HAMMERS=1
eval $(compute_metrics)

printf " %-50s ... " "thor $URL"
strace -e clone,wait4 $PROGRAM $URL > $WORKSPACE/stdout.thor 2> $WORKSPACE/stderr.thor
if [ $? -ne 0 ] ; then
    error "Failure (Exit Status)"
elif ! check_contents; then
    error "Failure (Contents)"
elif ! check_metrics; then
    error "Failure (Metrics)"
elif ! check_hammers; then
    error "Failure (Hammers)"
elif ! check_concurrency; then
    error "Failure (Concurrency)"
else
    echo "Success"
fi

sleep 1

HAMMERS=5
eval $(compute_metrics)
printf " %-50s ... " "thor -n $HAMMERS $URL"
strace -e clone,wait4 $PROGRAM -n $HAMMERS $URL > $WORKSPACE/stdout.thor 2> $WORKSPACE/stderr.thor
if [ $? -ne 0 ] ; then
    error "Failure (Exit Status)"
elif ! check_contents; then
    error "Failure (Contents)"
elif ! check_metrics; then
    error "Failure (Metrics)"
elif ! check_hammers; then
    error "Failure (Hammers)"
elif ! check_concurrency; then
    error "Failure (Concurrency)"
else
    echo "Success"
fi

# http://h4x0r.space:9898/warandpeace.txt -------------------------------------

URL=http://h4x0r.space:9898/warandpeace.txt
HAMMERS=1
eval $(compute_metrics)

printf " %-50s ... " "thor $URL"
strace -e clone,wait4 $PROGRAM $URL > $WORKSPACE/stdout.thor 2> $WORKSPACE/stderr.thor
if [ $? -ne 0 ] ; then
    error "Failure (Exit Status)"
elif ! check_contents; then
    error "Failure (Contents)"
elif ! check_metrics; then
    error "Failure (Metrics)"
elif ! check_hammers; then
    error "Failure (Hammers)"
elif ! check_concurrency; then
    error "Failure (Concurrency)"
else
    echo "Success"
fi

sleep 1

HAMMERS=3
eval $(compute_metrics)
printf " %-50s ... " "thor -n $HAMMERS $URL"
strace -e clone,wait4 $PROGRAM -n $HAMMERS $URL > $WORKSPACE/stdout.thor 2> $WORKSPACE/stderr.thor
if [ $? -ne 0 ] ; then
    error "Failure (Exit Status)"
elif ! check_contents; then
    error "Failure (Contents)"
elif ! check_metrics; then
    error "Failure (Metrics)"
elif ! check_hammers; then
    error "Failure (Hammers)"
elif ! check_concurrency; then
    error "Failure (Concurrency)"
else
    echo "Success"
fi

# Summary ---------------------------------------------------------------------

TESTS=$(($(grep -c Success $0) - 2))

echo
echo "   Score $(echo "scale=4; ($TESTS - $FAILURES) / $TESTS.0 * 5.0" | bc | awk '{ printf "%0.2f\n", $1 }' ) / 5.00"
printf "  Status "
if [ $FAILURES -eq 0 ]; then
    echo "Success"
else
    echo "Failure"
fi
echo
