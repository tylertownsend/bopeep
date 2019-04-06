#!/bin/bash

PROGRAM="ptest.sh"
PROGRAM_NAME="ptest"
CURR_DIR=$PWD

function sleeping() {
  sleep .5;
}

echo ""
echo "Running the ${PROGRAM_NAME} installer"
echo ""
sleeping

# Create the folder to store the folder
DESTINATION="${HOME}/${PROGRAM_NAME}"
mkdir -p ${DESTINATION}
cp -r . ${DESTINATION}


# Make the files
EXECUTABLE=${PROGRAM_NAME}
touch ${EXECUTABLE}
echo "#!/bin/bash" >> ${EXECUTABLE}
echo "bash ${DESTINATION}/${PROGRAM}" >> ${EXECUTABLE}
chmod +x ${EXECUTABLE}
mv ${EXECUTABLE} /usr/bin

echo "Installer finished"
echo ""

