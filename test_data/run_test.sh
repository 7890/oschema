#!/bin/bash

#//tb/140616

if [ $# -ne 3 ]
then
	echo "need params <xsd file> <validation script> <test data dir>"
	exit
fi

#XSD=oscdoc.xsd
#TEST_DIR=tests_data

XSD="$1"
VAL_SCRIPT="$2"
TEST_DIR="$3"

checkAvail()
{
        which "$1" >/dev/null 2>&1
        ret=$?
        if [ $ret -ne 0 ]
        then
                echo -e "tool \"$1\" not found. please install"
                exit 1
        fi
}

###################################################3

for tool in {xmlstarlet,sed,diff,bc,sort,uniq}; \
        do checkAvail "$tool"; done

echo ""
echo "TEST INVALID FILES"
echo ""

ls -1 "$TEST_DIR"/inv_*.xml | while read line; do "$VAL_SCRIPT" "$line" "$XSD" ; done

echo ""
echo "TEST VALID FILES"
echo ""

ls -1 "$TEST_DIR"/*.xml | grep -v "inv_" | while read line
	do
		a=`"$VAL_SCRIPT" "$line" "$XSD"`
		ret=$?

		if [ $ret -ne 0 ]
		then
			echo "$line: INVALID"
			echo "$a"
		else
			echo "$line: valid"
		fi
		echo ""
	done

echo ""
echo "done run_tests.sh"
