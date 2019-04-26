#!./test/libs/bats/bin/bats

load 'libs/bats-support/load'
load 'libs/bats-assert/load'

profile_script='./bopeep.sh'
BOPEEP_TEST_DIR="./test/"

setup() {
  source ${profile_script}    
}

# teardown() {
#   rm *.class
# }

@test "Should print header" {
  run print_header 
  assert_output -p "Running bopeep" 
}

@test "Should throw a java compile-time error" {
  run compile "javac" "test/fixtures/WontCompile.java"
  assert_output -p "failed to compile"
}

@test "Should throw a java runtime-error" {
  run compile "javac" "test/fixtures/RuntimeErrorProgram.java"
  cd "test/fixtures"
  run execute "data/RuntimeErrorProgram/input.in" "java" "RuntimeErrorProgram" "temp.out" 
  assert_output -p "program crashed"
  rm temp.out
  cd ../../
}

@test "Should find there is no program data folder" {
  run check_for_program_data_folder "MissingProgramFolder"
  assert_output -p "no input data"
}

@test "Should find there is not test cases for program" {
  local test_file="MissingTestCases.java"
  cd test/fixtures
  run run_program "javac" ${test_file}
  assert_output -p "HAS NO TEST CASES"
  cd ../../
}

@test "Should find .out name doesn't match .out name" {
  local dir="case001"
  mkdir $dir
  touch "$dir/input.in"
  touch "$dir/output.out"
  run check_for_correct_input_data_format $dir
  assert_output -p "ERROR"
  rm -r "$dir"
}

@test "Should find there is no input and output data" {
  local dir="case001"
  mkdir $dir
  run check_for_correct_input_data_format $dir
  assert_output -p "ERROR"
  rm -r "case001"
}

@test "Should compile java program" {
  run compile "javac" "test/fixtures/HelloWorld.java"
  compile_val=$?
  assert [ $compile_val=0 ]
}
