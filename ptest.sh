#!/bin/bash
red="\033[0;91m"
nocolor="\033[0m"
green="\033[0;92m"
yellow="\033[0;33m"
blue="\033[38;5;111m"

wrong="${red}\u2717${nocolor}"
fat_wrong="\u2718"
right="${green}\u2713${nocolor}"
fat_right="u2714"

DIRECTORY="data"

function what_was_passed_to_this_script() {
  local passed=$1
  if [[ -d $passed ]]; then
    run_all_python_programs $passed
    run_all_java_programs $passed
    return 0
  elif [[ -f $passed ]]; then
    local extension=${passed##*.}
    if [[ $extension = "py" ]]; then
      run_python_program $passed
      return 0
    elif [[ $extension = "java" ]]; then
      run_java_program $passed
      return 0
    else
      return 1
    fi
  else
    return 1
  fi
}

function run_all_python_programs() {
  python_files=("${PWD}/*.py")
  if [ ${#python_files[@]} -eq 0 ]; then
    return 1
  fi

  for python_file in *.py; do
    run_python_program $python_file
  done
}

function run_all_java_programs() {
  java_files=("${PWD}/*.java")
  if [ ${#java_files[@]} -eq 0 ]; then
    return 1
  fi

  for java_source_code in *.java; do
    local file=$java_source_code
    run_java_program $file
  done
}

function run_python_program() {
  python_file=$1
  print_file $python_file
  run_program "python" $python_file
}

function run_java_program() {
  java_file=$1
  print_file $java_file

  compile "javac" $java_file 
  run_program "java" $java_file
}

function compile {
  compiler=$1
  file=$2

  $compiler $java_file 2> /dev/null
  compile_val=$?
  if [[ $compile_val != 0 ]]; then
    echo -e "** fail ** (failed to compile) ${wrong}"
    return 1
  fi
}

function print_file() {
  file_name=$1
  printf "${blue}\e[1mRunning ${file_name}...${nocolor}"
}

function run_program() {
  local executor=$1
  local program_file=$2

  local file_name=${program_file%.*}
  local file=${program_file%.java}
  check_for_program_data_folder $file_name

  for program in data/$file_name; do

    if [ -z "$(ls -A $program)" ]; then
      printf "\n\n"
      print_error_location "${program}... ${file_name} HAS NO TEST CASES\n"
      print_termination
    fi

    for case in $program/*/; do
      run_on_input_files ${file} ${case} ${executor}
    done
  done
  return 0
}

function check_for_program_data_folder() {
  local file_name=$1
  if [ ! -d $DIRECTORY/$file_name ]; then
    echo -e "no input data ${fat_wrong}"
    print_pre_termination_message "A DATA FOLDER IS REQUIRED FOR ALL PROGRAMS\n" 
    print_termination
  fi
  echo ""
}

function print_error_location() {
  local message=$1
  printf "\n\n"
  printf "${yellow}\e[1mERROR: $message${nocolor}"
}

function print_pre_termination_message() {
  local message=$1
  printf "\n\n"
  printf "%10s"
  printf "${red}\e[1m${message}" 
}

function print_termination() {
  for i in 1, 2, 3; do
    printf "%25s" "" 
    echo ""
  done
  printf "${red}\e[1m"
  printf "%22s" "**************"
  printf "${red}\e[1m ABORTING PROGRAM"
  printf " ***************\n"
  clean_up
  exit 1
}

function run_on_input_files() {
  local file=$1
  local dir=$2
  local run=$3

  local input_file=$(echo $dir*.in)
  local output_file=$(echo $dir*.out)
  
  check_for_correct_input_data_format $dir $input_file $output_file

  local result=${file}_output.txt
  touch $result
  echo "$(cat ${input_file} | $run $file)" > $result 2> /dev/null

  check_for_runtime_error $dir 

  check_result $dir $result $output_file
}

function check_for_correct_input_data_format() {
  local dir=$1
  local input_file=$2
  local output_file=$3

  local input_prefix=${input_file%.*}
  local output_prefix=${output_file%.*}

  if [ -z "$(ls -A $dir)" ] || [ $output_prefix != $input_prefix ]; then
    print_error_location "$dir..."
    print_pre_termination_message "EACH TEST CASE REQUIRES 1 .in and 1 .out FILE\n"
    print_termination
  fi
}

function check_for_runtime_error() {
  local dir=$1
  execution_val=$?
  if [[ $execution_val != 0 ]]; then
    print_right_aligned ${dir} "** fail ** (program crashed)" ${wrong}
    return 1 
  fi
}

function check_result() {
  local dir=$1
  local result=$2
  local output_file=$3

  diff -Z $result $output_file> /dev/null
  local diff_val=$?
  
  if  [[ $diff_val != 0 ]]; then
    print_right_aligned ${dir} "** fail ** (output does not match)" ${wrong}
    return 1
  else
    print_right_aligned ${dir} "PASS!" ${right}
    PASS_CNT=`expr $PASS_CNT + 1`
  fi
  return 0
}

function print_right_aligned() {
  local file=$1
  file=${file#*/}
  file=${file#*/}
  local result=$2
  local output=$3
  printf "%25s %35s" "${file}..." "${result}"
  if [[ $result = "PASS!" ]]; then
    printf " ${right}\n"
  else
    printf " ${wrong}\n"
  fi
}

function clean_up() {
  rm -f *.class
  rm -f *.txt
}

function print_header() {
  echo ""
  echo "================================================================"
  echo "                        Running pTest"
  echo "================================================================"
  echo ""
}

function check_for_data_folder() {
  if [ ! -d "$DIRECTORY" ]; then
    print_pre_termination_message "pTest REQUIRES THE USE OF A 'data' DIRECTORY"
    print_termination
  fi
}

print_header
check_for_data_folder
what_was_passed_to_this_script $1
clean_up