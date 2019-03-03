#!/bin/bash

function what_was_passed_to_this_script() {
  passed=$1
  if [[ -d $passed ]]; then
    run_all_java_programs $passed
  elif [[ -f $passed ]]; then
    run_java_program $passed
    return 0
  else
    return 1
  fi
}

function run_all_java_programs() {
  for java_source_code in *.java; do
    local file=$java_source_code
    run_java_program $file
  done
}

function run_java_program() {
  java_file=$1
  echo -n "Running ${java_file}..."

	javac $java_file 2> /dev/null
	compile_val=$?
	if [[ $compile_val != 0 ]]; then
		echo "** fail ** (failed to compile)"
    return 1
	fi

  subdircount="$(find . -maxdepth 1 -type d | wc -l)"
  if [[ $subdircount -lt 1 ]]; then
    echo "no input data"
    return 1
  fi

  local file=${java_file%.*}
  for program in data/$file; do
    for case in $program/*/; do
      run_on_input_files ${file} ${case}
    done
  done
  return 0
}

function run_on_input_files() {
  local file=$1
  local dir=$2

  local result=${file}Output.txt
  touch $result
  echo -n "$(java $file)" > $result 2> /dev/null
  execution_val=$?
  if [[ $execution_val != 0 ]]; then
    echo "** fail ** (program crashed)";
    return 1 
  fi

  diff $result $dir/$file.out> /dev/null
	diff_val=$?
	
	if  [[ $diff_val != 0 ]]; then
		echo "** fail ** (output does not match)"
	else
		echo "PASS!"
		PASS_CNT=`expr $PASS_CNT + 1`
	fi
  return 0
}

function clean_up() {
  rm -f *.class
  rm -f *.txt
}


echo ""
echo "================================================================"
echo "Running Test Cases"
echo "================================================================"
echo ""
what_was_passed_to_this_script $1
clean_up

printf "X \u2717\n"
printf "X \u2718\n"
printf "Checkmark \u2713\n"
printf "Heavy Checkmark \u2714\n"