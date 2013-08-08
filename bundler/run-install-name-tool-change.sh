#!/bin/sh

if [ $# -lt 3 ]; then
    echo "Usage: $0 library old_prefix new_prefix action"
    exit 1
fi

LIBRARY=$1
WRONG_PREFIX=$2
#RIGHT_PREFIX="@executable_path/../$3"
RIGHT_PREFIX="@rpath"
ACTION=$4

if [ "x$ACTION" == "xchange" ]; then
    libs="`otool -L $LIBRARY 2>/dev/null | fgrep compatibility | cut -d\( -f1 | grep $WRONG_PREFIX | sort | uniq`"
    for lib in $libs; do
	if ! echo $lib | grep --silent "$RIGHT_PREFIX" ; then
	    fixed=`echo $lib | sed -e s,\$WRONG_PREFIX,\$RIGHT_PREFIX,`
	    install_name_tool -change $lib $fixed $LIBRARY
	fi
    done;
elif [ "x$ACTION" == "xid" ]; then
    lib=`otool -D $LIBRARY 2>/dev/null | grep "$WRONG_PREFIX"`
	if [ "x$lib" != "x" ]; then
		#echo "will change id ""$lib"""
		fixed=`echo $lib | sed -e s,\$WRONG_PREFIX,\$RIGHT_PREFIX,`
		#echo "install_name_tool -id $fixed $LIBRARY"
		install_name_tool -id $fixed $LIBRARY
	#else
		#echo "won't change id of '$LIBRARY'"
	fi

fi
    
