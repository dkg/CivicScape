#!/bin/bash -e
#./bag_and_bin.sh WeatherandCrime_Data_Iter.csv 100 FALSE 1 datapath

# How to Run: 
# ./bag_and_bin.sh inputfile numberofbags [TRUE/FALSE to use cached main file -never applicable in the updater] DownsamplingFactor
helperDir="${WC_HOME}/Helpers"


if [[ "z$1" == "z" ]]; then
		echo "Need to pass in a Header file"
		exit 1
fi
if [[ "z$2" == "z" ]]; then
		echo "Need to pass in a Ones input file"
		exit 1
fi
if [[ "z$3" == "z" ]]; then
	echo "Need to pass in a Zeroes input file"
	exit 1
fi
if [[ "z$4" == "z" ]]; then
	echo "Need to pass in an Output file"
	exit 1
fi

if [[ "z$5" == "z" ]]; then
	echo "No multiple parameter passed in, defaulting to creating balanced samples"
	MultipleOfZeroes=1
else
	MultipleOfZeroes=$5
fi

headerFile=$1
onesFile=$2
zeroesFile=$3
outputFile=$4

# Write the header row out
head -n 1 $headerFile > $outputFile
cat $onesFile >> $outputFile

echo " Pulling $NumberOfOnes total rows into $iterZeroesFile"
#For perfrectly balanced samples run this line:
#perl $helperDir/randlines.pl $NumberOfOnes $zeroesFile > $iterZeroesFile

#For tuned downsamples instead of perfectly balanced samples, run this line and define the tuning parameter $MultipleOfZeroes first
NumberOfOnes=$(wc -l $onesFile | awk '{print $1 }')
numberofzeroes=$(($MultipleOfZeroes*$NumberOfOnes))
echo "NumberOfOnes: $NumberOfOnes"
echo "numberofzeroes: $numberofzeroes"
perl $helperDir/randlines.pl $numberofzeroes $zeroesFile >> $outputFile

