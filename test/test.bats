#!/usr/bin/env bats

. ~/Desktop/ptest/ptest.sh

@test "argument was found to be file" {
  run what_was_passed_to_this_script ptest.sh
  [ "$output"="file" ]
}