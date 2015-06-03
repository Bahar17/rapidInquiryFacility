#!/bin/sh
#
cmd() {
	DIR=$1
	CMD=$2
	shift;shift
	ARGS=$*
	if [ -f build.log ]; then
		rm  -f build.log
	fi
	echo "UNIX($DIR)> $CMD $ARGS"
	$CMD $ARGS
	cmd_status=$?
	if [ $cmd_status != "0" ]; then
		echo "$DIR: command: $CMD failed with code: $cmd_status"
		if [ -f build.log ]; then
			cat build.log
		fi
		exit 1
	fi
}
rm rifServices/src/main/webapp/WEB-INF/lib/*.jar
find rifServices/target -name \*.jar  -exec rm {} \;
#
cmd rifGenericLibrary mvn --log-file build.log --errors --fail-at-end --file rifGenericLibrary --file rifServices clean validate compile package install
cmd rifGenericLibrary mvn --log-file build.log --errors --fail-at-end --file rifServices war:war
cmd rifGenericLibrary mvn --log-file build.log --errors --fail-at-end --file rifServices war:inplace
#
find . -name \*.jar
find . -name \*.war

#
# Eof