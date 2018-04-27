#!/bin/sh

set -e # exit on errors
test_dir=testdir.$$

exit_cleanup() {
    echo "please wait while the default configuration is rebuilt"
    ./configure >/dev/null 2>/dev/null
    make >/dev/null 2>/dev/null
}

exit_success() {
    exit_cleanup
    echo
    echo "success!"
}

exit_failure() {
    cd ..
    exit_cleanup
    echo
    echo "$0 failed with $this_test"
    echo "results in $test_dir"
}

testone() {
    this_test=$1
    mkdir "$test_dir"
    cd "$test_dir"
    trap exit_failure EXIT
    ../configure $this_test
    make check
    cd ..
    trap exit_cleanup EXIT
    rm -rf "$test_dir"
}

test ! -f Makefile || make distclean

for model in pthread fork ucontext; do
    testone "--with-threads=$model"
done

for ssl_dir in /opt/openssl-[0-9]* /usr/local/ssl-[0-9]*; do
    test ! -d "$ssl_dir" || LD_LIBRARY_PATH="$ssl_dir/lib" testone "--with-ssl=$ssl_dir"
done

trap exit_success EXIT
