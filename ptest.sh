#!/bin/bash

function what_was_passed_to_this_script() {
  if [ -d "${PASSED}" ]; then
    echo "directory";
  else
    if [ -f "${PASSED}" ]; then
      echo "file"
    else
      exit 1;
    fi
  fi
}

function list_all_files() {

}

function compile_all_java_files() {
  find -name "*.java" > sources.txt
  javac @sources.txt
}

function run_all_java_programs() {
  for i in *.class; do
    subdircount="$(find . -maxdepth 1 -type d | wc -l)"
    if [ $subdircount -lt 1]; then
      echo "no input data";
      exit 1;
    fi
    local file=${i%.class}
    for dir in ./data/$i; do
      run_on_input_files ${file} ${dir}
    done
  done
}

function run_on_input_files() {
  echo "$1 is the filename and $2 is the directory"
  local file=$1
  local dir=$2
  java $javafile > output$file.txt 2> /dev/null
  execution_val=$?
  if [[ $execution_val != 0 ]]; then
    echo "** fail ** (program crashed)";
    continue;
  fi

  diff output$file.txt $dir/$file.out
}