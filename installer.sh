#!/bin/bash

PROGRAM="bopeep.sh"
PROGRAM_NAME="bopeep"
FILES_TO_COPY="${PROGRAM} utils.sh"

if [[ $EUID -ne 0 ]]; then
   echo "Please run this script with root privileges." 
   exit 1
fi

function sleeping() {
  sleep .5;
}

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
if [[ "$OSTYPE" == "darwin"* ]]; then
  local executable_loc="~/usr/bin/"
  [ -e "$executable_loc/${EXECUTABLE}" ] && rm "$executable_loc/${EXECUTABLE}"
  echo "#!/bin/bash" >> ${EXECUTABLE}
  echo "bash ${DESTINATION}/${PROGRAM} "'$1' >> ${EXECUTABLE}
  chmod +x ${EXECUTABLE}
  mv ${EXECUTABLE} $executable_loc
  local bash_prof_str="alias bopeep='bash $executable_loc/${EXECUTABLE}'"
  if [ -e "~/.bash_profile" ]; then
    touch ~/.bash_profile
  fi
  "# Added by bopeep installer."
  bash_prof_str >> ~/.bash_profile
  source ~/.bash_profile
else
  [ -e "/usr/bin${EXECUTABLE}" ] && rm "$/usr/bin/{EXECUTABLE}"
  echo "#!/bin/bash" >> ${EXECUTABLE}
  echo "bash ${DESTINATION}/${PROGRAM} "'$1' >> ${EXECUTABLE}
  chmod +x ${EXECUTABLE}
  mv ${EXECUTABLE} /usr/bin
fi

echo "Installer finished!"
