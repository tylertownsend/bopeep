#!/bin/bash
RED="\033[0;91m"
NOCOLOR="\033[0m"
GREEN="\033[0;92m"
YELLOW="\033[0;33m"
BLUE="\033[38;5;111m"

WRONG="${RED}\u2717${NOCOLOR}"
FAT_WRONG="\u2718"
RIGHT="${GREEN}\u2713${NOCOLOR}"
FAT_RIGHT="u2714"

DIRECTORY="data"

function what_was_passed_to_this_script() {
  local passed=$1
  if [[ -d $passed ]]; then
    run_all_python_programs $passed
    run_all_c_programs "g++" $passed
    run_all_java_programs $passed
    return 0
  elif [[ -f $passed ]]; then
    local extension=${passed##*.}
    if [[ $extension = "py" ]]; then
      run_python_program $passed
    elif [[ $extension = "java" ]]; then
      run_java_program $passed
    elif [[ $extension = "c" ]]; then
      run_c_program "gcc" $passed 
    elif [[ $extension = "cc" ]] || [[ $extension = "cpp" ]]; then
      run_c_program "g++" $passed 
    fi
  elif [ $# -eq 0 ]; then
    run_all_python_programs $passed
    run_all_c_programs "g++" $passed
    run_all_java_programs $passed
  else
    echo "Proper usage: $PROGRAM <path_to_file>"
  fi
}

function run_all_python_programs() {
  local myarray=(`find ./ -maxdepth 1 -name "*.py"`)
  if [ ${#myarray[@]} -eq 0 ]; then
    return 1
  fi

  for python_file in *.py; do
    run_python_program $python_file
  done
}

function run_all_c_programs() {
  local myarray=(`find ./ -maxdepth 1 -name "*.c"`)
  if [ ${#myarray[@]} -eq 0 ]; then
    return 1
  fi

  for c_file in *.c*; do
    run_c_program "g++" $c_file
  done
}

function run_all_java_programs() {
  local myarray=(`find ./ -maxdepth 1 -name "*.java"`)
  if [ ${#myarray[@]} -eq 0 ]; then
    return 1
  fi

  for java_source_code in *.java; do
    local file=$java_source_code
    run_java_program $file
  done
}

function run_python_program() {
  local python_file=$1
  print_file $python_file
  run_program "python" $python_file
}

function run_java_program() {
  local java_file=$1
  print_file $java_file

  compile "javac" $java_file 
  run_program "java" $java_file
}

function run_c_program() {
  local compiler=$1
  local c_file=$2
  print_file $c_file
  local file=${c_file%.*}

  compile $compiler $c_file "-o ${file}.exe"
  run_program "./" $c_file
}

function compile {
  compiler=$1
  file=$2
  flags=$3

  $compiler $file $flags 2> /dev/null
  compile_val=$?
  if [[ $compile_val != 0 ]]; then
    echo -e "** fail ** (failed to compile) ${wrong}"
    return 1
  fi
}

function print_file() {
  file_name=$1
  printf "${BLUE}\e[1mRunning $file_name...${NOCOLOR}"
}

function run_program() {
  local executor=$1
  local program_file=$2

  local file_name=${program_file%.*}
  local file=$program_file
  if [ ${file##*.} != 'py' ]; then
    file=$file_name
  fi
  check_for_program_data_folder $file_name

  for program in data/$file_name; do
    local subdircount=`find ${program} -maxdepth 1 -mindepth 1 -type d | wc -l`
    if [ $subdircount -eq 0 ]; then
      printf "\n\n"
      print_error_location "$program... $file_name HAS NO TEST CASES\n"
      print_termination
    fi

    for case in $program/*/; do
      run_on_input_files $file $case $executor
    done
  done
  return 0
}

function check_for_program_data_folder() {
  local file_name=$1
  if [ ! -d $DIRECTORY/$file_name ]; then
    echo -e "no input data ${FAT_WRONG}"
    print_pre_termination_message "A DATA FOLDER IS REQUIRED FOR ALL PROGRAMS\n" 
    print_termination
  fi
  echo ""
}

function print_error_location() {
  local message=$1
  printf "\n\n"
  printf "${YELLOW}\e[1mERROR: $message${NOCOLOR}"
}

function print_pre_termination_message() {
  local message=$1
  printf "\n\n"
  printf "%10s"
  printf "${RED}\e[1m${message}" 
}

function print_termination() {
  for i in 1, 2, 3; do
    printf "%25s" "" 
    echo ""
  done
  printf "${RED}\e[1m"
  printf "%22s" "**************"
  printf "${RED}\e[1m ABORTING PROGRAM"
  printf " ***************\n"
  clean_up
  exit 1
}

function run_on_input_files() {
  local program_file=$1
  local dir=$2
  local run=$3

  local input_data_file=$(echo $dir*.in)
  local output_file=$(echo $dir*.out)
  
  check_for_correct_input_data_format $dir $input_data_file $output_file

  local result=${file}_output.txt
  touch $result
  
  execute $input_data_file $run $program_file $result
  local return_val=$?
  if [[ $return_val -eq 1 ]]; then
    return 0;
  fi
  
  # check_for_runtime_error $dir 

  check_result $dir $result $output_file
}

function execute() {
  local input_file=$1
  local run=$2
  local file=$3
  local result=$4

  local argument="$run $file"
  if [ $run == "./" ]; then
    argument="$run$file.exe"
  fi

  cat ${input_file} | $argument > $result 2> /dev/null
  execution_val=$?
  if [[ $execution_val != 0 ]]; then
    print_right_aligned ${dir} "** fail ** (program crashed)" ${WRONG}
    return 1 
  fi
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
    # print_termination
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
    printf " ${RIGHT}\n"
  else
    printf " ${WRONG}\n"
  fi
}

function clean_up() {
  rm -f *.class
  rm -f *.txt
  rm -f *.exe
}

function print_header() {
  echo ""
  echo "================================================================"
  echo "                        Running bopeep"
  echo "================================================================"
  echo ""
}

function check_for_data_folder() {
  if [ ! -d "$DIRECTORY" ]; then
    print_pre_termination_message "bopeep REQUIRES THE USE OF A 'data' DIRECTORY"
    print_termination
  fi
}

function run_main() {
  print_header
  check_for_data_folder
  what_was_passed_to_this_script $1
  clean_up
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]
then
  run_main ${1}
fi