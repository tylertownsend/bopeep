#!./test/libs/bats/bin/bats

load 'libs/bats-support/load'
load 'libs/bats-assert/load'

profile_script='./ptest.sh'

@test "Should print header" {
  source ${profile_script}
  run print_header 
  assert_output -p "Running pTest" 
}

@test "Should throw a java compile-time error" {
  source ${profile_script}
  run compile "javac" "test/fixtures/WontCompile.java"
  assert_output -p "failed to compile"
}

@test "Should find there is no program data folder" {
  source ${profile_script}
  run check_for_program_data_folder "MissingProgramFolder"
  assert_output -p "no input data"
}

@test "Should find there is not test cases for program" {
  source ${profile_script}
  local test_file="MissingTestCases.java"
  cd test/fixtures
  run run_program "javac" ${test_file}
  assert_output -p "HAS NO TEST CASES"
  cd ../../
}
