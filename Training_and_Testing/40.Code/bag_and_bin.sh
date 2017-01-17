#!/bin/bash
#./bag_and_bin.sh WeatherandCrime_Data_Iter.csv 100 FALSE 1 datapath

# How to Run: 
# ./bag_and_bin.sh inputfile numberofbags [TRUE/FALSE to use cached main file -never applicable in the updater] DownsamplingFactor
helperDir="${WC_HOME}/Helpers"

work_root=${WC_JOB_DIR}/40.work
output_root=${WC_JOB_DIR}/40.prepared_csvs



if [[ "z$1" == "z" ]]; then
		echo "Need to pass in an input file"
		exit 1
fi
if [[ "z$2" == "z" ]]; then
	echo "No bag passed in via 2nd param, defaulting to WC_MODEL_COUNT"
	NumBags=$WC_MODEL_COUNT
else
	NumBags=$2
fi

if [[ "z$3" == "z1" ]]; then
	useCachedMainOnesAndZeroes="true"
else
	useCachedMainOnesAndZeroes="false"
fi

if [[ "z$4" == "z" ]]; then
	echo "No multiple parameter passed in, defaulting to creating balanced samples"
	MultipleOfZeroes=1
else
	MultipleOfZeroes=$4
fi

input=$1
echo "input: $input"
baseName=$( basename $1 | sed 's/.csv//' )
echo "baseName: $baseName"

#for crime in shooting robbery assault; do
for crime in ${WC_CRIMES}; do
	
	work=${work_root}/$crime
	output=${output_root}/$crime
	mkdir -p $work $output
	
	echo ""
	echo "*** Starting $crime @ $(date)"
	if [[ "$crime" == "shooting" ]]; then
		crimeCsvColumn=5
	elif [[ "$crime" == "robbery" ]]; then
		crimeCsvColumn=6
	elif [[ "$crime" == "assault" ]]; then
		crimeCsvColumn=7
	else 
		echo " Invalid loop value"
		exit 1
	fi
	
	onesFile=$work/$baseName.$crime.ones.csv
	zeroesFile=$work/$baseName.$crime.zeroes.csv

	echo "onesFile:   $onesFile"
	echo "zeroesFile: $zeroesFile"

	# awkOneCmd="NR>1 {if ($"${crimeCsvColumn}' >= 1 && 2009 <= $2 ) print $0}'
	# awkZeroCmd="NR>1 {if ($"${crimeCsvColumn}' == 0 && 2009 <= $2 ) print $0}'

	if [ "$useCachedMainOnesAndZeroes" == "true" ] && [ -e $onesFile ] && [ -e $zeroesFile ]; then
		echo " Using cached $onesFile"	
		echo " Using cached $zeroesFile"
	else
		echo " Writing training $crime Ones to $onesFile  @ $(date)"
		echo "   and Writing training $crime Zeroes to $zeroesFile  @ $(date)"

		# I removed the 2009 restriction here- enforce it on the output csv if you want to
		# dualAwkCmd="NR>1 {if ($"${crimeCsvColumn}' >= 1 && 2009 <= $2 ) { print $0 > "/dev/stdout" } else { print $0 > "/dev/stderr"}  }'
		dualAwkCmd="NR>1 {if ($"${crimeCsvColumn}' >= 1) { print $0 > "/dev/stdout" } else { print $0 > "/dev/stderr"}  }'
		awk -F, "$dualAwkCmd" $input > $onesFile 2> $zeroesFile
	fi	

	# Find how many zeros to pull
	NumberOfOnes=$(wc -l $onesFile | awk '{print $1 }')
	echo " Found $NumberOfOnes rows with One"

	for iter in $(seq 1 $NumBags); do
		echo " Starting iteration $iter @ $(date)"

		iterZeroesFile=${work}/$baseName.$crime.$iter.zeroes.csv
		baggedFile=${work}/$baseName.$crime.$iter.bagged.csv
		binnedFileName=$baseName.$crime.$iter.binned.csv	# breaking this out so `tar -zcf file.tar.gz -C $work $binnedFileName` works
		binnedFile=${output}/$binnedFileName 
		tmpBinnedFile=${binnedFile}.tmp

		echo " Pulling $NumberOfOnes total rows into $iterZeroesFile"
		#For perfrectly balanced samples run this line:
		#perl $helperDir/randlines.pl $NumberOfOnes $zeroesFile > $iterZeroesFile
		
		#For tuned downsamples instead of perfectly balanced samples, run this line and define the tuning parameter $MultipleOfZeroes first
		numberofzeroes=$(($MultipleOfZeroes*$NumberOfOnes))
		echo "NumberOfOnes: $NumberOfOnes"
		echo "numberofzeroes: $numberofzeroes"
		perl $helperDir/randlines.pl $numberofzeroes $zeroesFile > $iterZeroesFile
		

		foundZeros=$(wc -l $iterZeroesFile | awk '{print $1 }') 
		echo " Found $foundZeros Zeroes in $iterZeroesFile"

		# Write the header row out
		head -n 1 $input > $baggedFile
		echo " Writing Zeros and Ones to $baggedFile"
		cat $onesFile >> $baggedFile
		cat $iterZeroesFile >> $baggedFile

		echo " Binning $baggedFile "
		echo "      to $binnedFile"
		awk -F, -f $helperDir/bin_1_temperature.awk $baggedFile \
			| awk -F, -f $helperDir/bin_2_wind.awk \
			| awk -F, -f $helperDir/bin_4_rain.awk \
			| awk -F, -f $helperDir/bin_5_humidity.awk \
			| awk -F, -f $helperDir/bin_wow_1.awk \
			| awk -F, -f $helperDir/bin_wow_2.awk \
			| awk -F, -f $helperDir/bin_dod_1.awk \
			| awk -F, -f $helperDir/bin_dod_2.awk \
			| awk -F, -f $helperDir/bin_dod_3.awk \
			| awk -F, -f $helperDir/bin_rain_count_1day.awk \
			| awk -F, -f $helperDir/bin_rain_count_2day.awk \
			| awk -F, -f $helperDir/bin_rain_count_1week.awk \
			| awk -F, -f $helperDir/bin_count_SINCE_rain.awk \
			> $binnedFile

		awk -F, -v column="37" -f $helperDir/unpivot.awk $binnedFile $binnedFile > $tmpBinnedFile
		mv $tmpBinnedFile $binnedFile

		awk -F, -v column="36" -f $helperDir/unpivot.awk $binnedFile $binnedFile > $tmpBinnedFile
		mv $tmpBinnedFile $binnedFile
		
		awk -F, -v column="2" -f $helperDir/unpivot.awk $binnedFile $binnedFile > $tmpBinnedFile
		mv $tmpBinnedFile $binnedFile

		awk -F, -v column="3" -f $helperDir/unpivot.awk $binnedFile $binnedFile > $tmpBinnedFile
		mv $tmpBinnedFile $binnedFile

		awk -F, -v column="1" -f $helperDir/unpivot.awk $binnedFile $binnedFile > $tmpBinnedFile
		mv $tmpBinnedFile $binnedFile
	
		# tar -zcf $zippedFile -C $work $binnedFileName
		# gzip -f $binnedFile
	
	done
done


