#!/bin/bash

#//tb/140626

#todo:
#need test for string tokens in whitelist
#-> match string min/max length of param_s

#need check unique symbols in hints, grid, in message_(in|out)

#need match grid points -> min, max and default must be grid points
#except f,d exclusive start ]   exclusive end [

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

if [ $# -lt 1 ]
then
	echo "need param: <xml file> (<xsd file>)" >&2
	exit
fi

XML="$1"
XSD="$DIR/oschema.xsd"

if [ $# -gt 1 ]
then
	XSD="$2"
fi

if [ ! -e "$XSD" ]
then
	echo "schema file $XSD not found!" >&2
	exit 1
fi

if [ ! -e "$XML" ]
then
	echo "instance file $XML not found!" >&2
	exit 1
fi

print_label()
{
	echo ".------" >&2
	echo "| $1" >&2
	echo "\______" >&2
}

checkAvail()
{
	which "$1" >/dev/null 2>&1
	ret=$?
	if [ $ret -ne 0 ]
	then
		print_label "/!\\ tool \"$1\" not found. please install"
		exit 1
	fi
}

sed_replace()
{
	while read line
	do
		echo "$line" \
		| sed 's/_LT_/</g'  | sed 's/_LTE_/<=/g' | sed 's/_GT_/>/g' | sed 's/_GTE_/>=/g' | sed 's/_AND_/\&\&/g'
	done
}

process_output()
{
	grep -v "^$" | 
	while read line
	do
		a=`echo "$line" | sed_replace`
		echo $line
		echo -n "$a:"
		b=`echo "$a" | bc`
		echo $b
	done \
	| grep ":0$"
}

expect_ret()
{
	if [ x"$1" != x"$2" ]
	then
		print_label "/!\\ found at least one invalid aspect, aborting."
		exit 1
	fi
}

validate()
{
	xmlstarlet val -e -s "$1" "$2" 1>&2
}

check_typetag_param_count()
{
#typetag length = param count
xmlstarlet sel -t -m "//*[starts-with(name(.),'message_') and not(contains(@typetag,'*'))]" \
-v "name(.)" -o " " -v @pattern -o " " -v @typetag -o " typetag len:" \
-v "string-length(@typetag)" -o " param count:" \
-v "count(*[starts-with(name(.),'param_')])" \
--if "string-length(@typetag) != count(*[starts-with(name(.),'param_')])" \
-o " INVALID" -b -n "$1" \
| grep "INVALID$"
return $?

# --else -o " ok" 
#older xmlstarlet do not support --else
}

check_typetag_param_type()
{
#typetag position = param type
diff \
<( \
xmlstarlet sel -t -m "//*[starts-with(name(.),'message_') and not(contains(@typetag,'*'))]" \
-v "name(.)" -o " " -v @pattern -o " " \
-v @typetag -n "$1" \
) \
<( \
xmlstarlet sel -t -m "//*[starts-with(name(.),'message_') and not(contains(@typetag,'*'))]" \
-v "name(.)" -o " " -v @pattern -o " " \
-m "*[starts-with(name(.),'param_')]" \
-v "substring-after(name(.),'_')" -b -n "$1" \
)
return $?
}

check_message_unique()
{
#don't allow multiple messages with same direction, pattern typetag
diff \
<( \
xmlstarlet sel -t -m "//*[starts-with(name(.),'message_')]" \
-v "name(.)" -o " " -v "@pattern" -o " " -v "@typetag" \
-n "$1" | sort \
) \
<( \
xmlstarlet sel -t -m "//*[starts-with(name(.),'message_')]" \
-v "name(.)" -o " " -v "@pattern" -o " " -v "@typetag" \
-n "$1" | sort | uniq \
)
return $?
}

check_param_s_min_max()
{
#param_s min_length, max_length
xmlstarlet sel -t -m "//param_s[@min_length and @max_length]" \
\
-o "/*" -v "name(..)" -o " " -v "../@pattern" -o " " -v "../@typetag" -o " " -v "@symbol" -o "*/ " \
\
-v "@min_length" -o "_LTE_" -v "@max_length" -n "$1" \
\
| process_output
return $?
}

check_param_b_min_max()
{
#param_b min_size, max_size
xmlstarlet sel -t -m "//param_b[@min_size and @max_size]" \
\
-o "/*" -v "name(..)" -o " " -v "../@pattern" -o " " -v "../@typetag" -o " " -v "@symbol" -o "*/ " \
\
-v "@min_size" -o "_LTE_" -v "@max_size" -n "$1" \
\
| process_output
return $?
}

check_range_min_max()
{
#test min<=max on all range_min_max
xmlstarlet sel -t -m "//range_min_max" \
\
-o "/*" -v "name(../..)" -o " " -v "../../@pattern" -o " " -v "../../@typetag" -o " " \
-v "../@symbol" -o " " -v "name(.)" -o "*/ " \
\
-v "@min" -o "_LTE_" -v "@max" -n "$1" \
\
| process_output
return $?
}

check_range_values_min_inclusive()
{
#MIN [: i,h,f,d
xmlstarlet sel -t -m "//*[starts-with(name(.),'range_') and \
name(.)!='range_inf_inf' and @min and ((@lmin and @lmin[.='[']) or not(@lmin))]" \
\
-o "/*" -v "name(../..)" -o " " -v "../../@pattern" -o " " -v "../../@typetag" -o " " \
-v "../@symbol" -o " " -v "name(.)" -o "*/ " \
\
-v @min -o "_LTE_" --if "@default" -v @default -b --if "not(@default)" -v @min -b \
-m ".//point" -o "_AND_" -v "../../@min" -o "_LTE_" -v @value -b \
-n "$1" \
\
| process_output
return $?
}

check_range_values_min_exclusive()
{
#MIN ]: f,d
xmlstarlet sel -t -m "//*[starts-with(name(.),'range_') and \
name(.)!='range_inf_inf' and @min and @lmin and @lmin[.=']']]" \
\
-o "/*" -v "name(../..)" -o " " -v "../../@pattern" -o " " -v "../../@typetag" -o " " \
-v "../@symbol" -o " " -v "name(.)" -o "*/ " \
\
-v @min -o "_LT_" --if "@default" -v @default -b --if "not(@default)" -v @min -b \
-m ".//point" -o "_AND_" -v "../../@min" -o "_LT_" -v @value -b \
-n "$1" \
\
| process_output
return $?
}

check_range_values_max_inclusive()
{
#MAX ]: i,h,f,d
xmlstarlet sel -t -m "//*[starts-with(name(.),'range_') and \
name(.)!='range_inf_inf' and @max and ((@lmax and @lmax[.=']']) or not(@lmax))]" \
\
-o "/*" -v "name(../..)" -o " " -v "../../@pattern" -o " " -v "../../@typetag" -o " " \
-v "../@symbol" -o " " -v "name(.)" -o "*/ " \
\
--if "@default" -v @default -b --if "not(@default)" -v @max -b \
-o "_LTE_" -v @max \
-m ".//point" -o "_AND_" -v @value -o "_LTE_" -v "../../@max" -b \
-n "$1" \
\
| process_output
return $?
}

check_range_values_max_exclusive()
{
#MAX [: f,d
xmlstarlet sel -t -m "//*[starts-with(name(.),'range_') and \
name(.)!='range_inf_inf' and @max and @lmax and @lmax[.='[']]" \
\
-o "/*" -v "name(../..)" -o " " -v "../../@pattern" -o " " -v "../../@typetag" -o " " \
-v "../@symbol" -o " " -v "name(.)" -o "*/ " \
\
--if "@default" -v @default -b --if "not(@default)" -v @min -b \
-o "_LT_" -v @max \
-m ".//point" -o "_AND_" -v @value -o "_LT_" -v "../../@max" -b \
-n "$1" \
\
| process_output
return $?
}

###################################################3

for tool in {xmlstarlet,sed,diff,bc,sort,uniq}; \
	do checkAvail "$tool"; done

#program return values: 0 normally means no error
#grep on error: 
	#if matching -> return 0 -> means found error
	#if not matching -> return 1 -> means no error

print_label "validating instance document against schema \"$XSD\""
validate "$XSD" "$XML"
expect_ret $? 0 #no error

print_label "semantical tests"
print_label "typetag length == param count"
check_typetag_param_count "$XML"
expect_ret $? 1 #grep does not match INVALID

print_label "typetag position + type == param position + type"
check_typetag_param_type "$XML"
expect_ret $? 0 #no difference in diff

print_label "unique messages (direction,pattern,typetag)"
check_message_unique "$XML"
expect_ret $? 0 #no difference in diff

print_label "param_S min_length <= max_length"
check_param_s_min_max "$XML"
expect_ret $? 1

print_label "param_B min_size <= max_size"
check_param_b_min_max "$XML"
expect_ret $? 1

print_label "range min <= max"
check_range_min_max "$XML"
expect_ret $? 1

print_label "range [ min <= default, points"
check_range_values_min_inclusive "$XML"
expect_ret $? 1

print_label "range ] min < default, points"
check_range_values_min_exclusive "$XML"
expect_ret $? 1

print_label "range ] default, points <= max"
check_range_values_max_inclusive "$XML"
expect_ret $? 1

print_label "range [ default, points < max"
check_range_values_max_exclusive "$XML"
expect_ret $? 1

print_label "done validate.sh - file is a valid oschema instance :)"

exit
