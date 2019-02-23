# Fail whale is credited to Dr. Sean Szumlanski 
# at the University of Central Florida
function output() {
  PASS_CNT=$1
  NUM_FILES=$2
  if [ $PASS_CNT -eq $NUM_FILES ]; then
    echo ""
    echo "  CONGRATULATIONS! You appear to be passing all the test cases"
    echo "  and safety checks performed by this script!!"
    echo ""
  else
    echo "                           ."
    echo "                          \":\""
    echo "                        ___:____     |\"\\/\"|"
    echo "                      ,'        \`.    \\  /"
    echo "                      |  o        \\___/  |"
    echo "                    ~^~^~^~^~^~^~^~^~^~^~^~^~"
    echo ""
    echo "                           (fail whale)"
  fi
}