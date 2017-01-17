#!/bin/bash -e

if [[ "z$1" == "z" ]]; then
		echo "Need to pass in an input file"
		exit 1
fi

if [[ "z$2" == "z" ]]; then
		echo "Need to pass a file to save ones in"
		exit 1
fi

if [[ "z$3" == "z" ]]; then
		echo "Need to pass a file to save zeroes in"
		exit 1
fi

if [[ "z$4" == "z1" ]]; then
	useCachedMainOnesAndZeroes="true"
else
	useCachedMainOnesAndZeroes="false"
fi

input=$1
onesFile=$2
zeroesFile=$3

echo "input: $input"
baseName=$( basename $1 | sed 's/.csv//' )
echo "baseName: $baseName"

echo ""
echo "*** Starting @ $(date)"
crimeCsvColumn=3


echo "onesFile:   $onesFile"
echo "zeroesFile: $zeroesFile"

if [ "$useCachedMainOnesAndZeroes" == "true" ] && [ -e $onesFile ] && [ -e $zeroesFile ]; then
	echo " Using cached $onesFile"	
	echo " Using cached $zeroesFile"
else
	echo " Writing training $crime Ones to $onesFile  @ $(date)"
	echo "   and Writing training $crime Zeroes to $zeroesFile  @ $(date)"

	dualAwkCmd="NR>1 {if ($"${crimeCsvColumn}' >= 1) { print $0 > "/dev/stdout" } else { print $0 > "/dev/stderr"}  }'
	awk -F, "$dualAwkCmd" $input > $onesFile 2> $zeroesFile
fi	


