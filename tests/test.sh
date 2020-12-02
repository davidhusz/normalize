#!/usr/bin/env bash
# Usage:
# ./test.sh [DIRS]
# Test all .txt files in each directory DIR. If DIRS is not provided, use all
# directories in the tests directory.
#
# This script runs textEnhance with three different example input files (each of
# which is a typical text file as you would find it on a Linux, Windows or MacOS
# system, respectively). The actual content of the files ("what the user sees",
# i.e. ignoring encoding etc.) is the same for all three, which is why this
# script then asserts that that the files are identical after Processing. If
# they're not, the script aborts.

set -euo pipefail  # strict mode

exec_dir=$PWD
repo_dir=$(realpath "$(dirname "$0")/..")
test $# = 0 && set "$repo_dir/"tests/*/
errors=0

for dir in "$@"; do
    cd "$exec_dir/$dir" 2> /dev/null || cd "$dir"  # hacky, could be improved
    mkdir -p processed
    for file in *.txt; do
        "$repo_dir/"normalize -v "$file" -o "processed/$file"
    done
    
    errors_in_this_dir=0
    for file in *.txt; do
        if ! diff "$repo_dir/tests/goldstandard.txt" \
                   "processed/$file" > /dev/null; then
            errors=1
            errors_in_this_dir=1
            echo "$file did not generate the expected output."
        fi
    done
    
    if [ $errors_in_this_dir = 0 ]; then
        rm -r processed
    fi
    
    echo  # empty line for visual separation
done

cd ..
if [ $errors = 0 ]; then
    echo "All files identical. Test successful."
else
    echo "Errors occured. See the following folders: $(ls -d */processed)"
    exit 1
fi
