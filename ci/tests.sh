#!/usr/bin/env zsh

# Purpose:
# Runs gemc using the jcards inside 'tests' and 'overlaps' directory (if existing)
#   inside each detector subdirs
# Assumptions: the names of the tests and overlaps directories.

# Container run example:
# docker run -it --rm jeffersonlab/gemc:3.0-clas12 bash
# git clone http://github.com/gemc/clas12-systems /root/clas12-systems && cd /root/clas12-systems
# ./ci/tests.sh -s ft/ft_cal -o

# load environment if we're on the container
# notice the extra argument to the source command
TERM=xterm # source script use tput for colors, TERM needs to be specified
FILE=/etc/profile.d/jlab.sh
test -f $FILE && source $FILE keepmine

Help()
{
	# Display Help
	echo
	echo "Syntax: tests.sh [-h|t|o|s]"
	echo
	echo "Options:"
	echo
	echo "-h: Print this Help."
	echo "-t: runs detector test. 'tests' directory must contain jcards."
	echo "-o: runs overlaps test. 'overlaps' directory must contain jcards."
	echo "-s <System>: build geometry and plugin for <System>"
	echo
}

if [ $# -eq 0 ]; then
	Help
	exit 1
fi

while getopts ":htos:" option; do
   case $option in
      h)
         Help
         exit
         ;;
      t)
         testType=tests
         ;;
      o)
         testType=overlaps
         ;;
      s)
         detector=$OPTARG
         ;;
     \?) # Invalid option
         echo "Error: Invalid option"
         exit 1
         ;;
   esac
done

TestTypeNotDefined() {
	echo "Test type is not set. Exiting"
	Help
	exit 2
}

TestTypeDirNotExisting() {
	echo Test Type dir: $detector/$testType not existing
	Help
	exit 2
}

JcardsToRun () {
	test -d $detector/$testType && echo Test Type dir: $detector/$testType || TestTypeDirNotExisting

	jcards=`ls $detector/$testType/*.jcard`

	echo
	echo List of jcards in $testType: $=jcards
}

[[ -v testType ]] && echo Running $testType tests || TestTypeNotDefined

startDir=`pwd`
GPLUGIN_PATH=$startDir/systemsTxtDB
cp $GLIBRARY/lib/gstreamer*.gplugin $GPLUGIN_PATH
jcards=no

./ci/build.sh -s $detector

# sets the list of jcards to run
JcardsToRun

# for some reason DYLD_LIBRARY_PATH is not passed to this script
export DYLD_LIBRARY_PATH=$LD_LIBRARY_PATH

# location of database
export GEMCDB_ENV=systemsTxtDB

for jc in $=jcards
do
	echo Running gemc for $jc
	gemc $jc
	exitCode=$?
	if [[ $exitCode != 0 ]]; then
		exit $exitCode
	fi
done
