#!/bin/bash

PROGRAM="ptest.sh"
PROGRAM_NAME="ptest"
FILES_TO_COPY="${PROGRAM} utils.sh"

function sleeping() {
  sleep .5;
}

echo ""
echo "Running the ${PROGRAM_NAME} installer"
echo ""
sleeping

# Create the folder to store the folder
DESTINATION="/opt/${PROGRAM_NAME}"
mkdir -p ${DESTINATION}
cp -r ${FILES_TO_COPY} ${DESTINATION}


# Make the files
EXECUTABLE=${PROGRAM_NAME}
touch ${EXECUTABLE}
echo "#!/bin/bash" >> ${EXECUTABLE}
echo "bash ${DESTINATION}/${PROGRAM} "'$1' >> ${EXECUTABLE}
chmod +x ${EXECUTABLE}
mv ${EXECUTABLE} /usr/bin

echo "Installer finished"
echo ""

