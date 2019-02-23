#!/bin/bash

# Check if there is a file passed
if [[-f *.java]]; then
  # run for specific java program
else
  #
fi

for java_file in java_files; do
  javac java_file
