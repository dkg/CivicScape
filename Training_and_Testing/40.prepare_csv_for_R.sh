#!/bin/bash -e
code=$WC_TRAIN/40.Code
work=$WC_JOB_DIR/40.work
input=$WC_JOB_DIR/30.database_export
output=$WC_JOB_DIR/40.prepared_csvs
helperDir="${WC_HOME}/Helpers"

mkdir -p $work $output
#output_train_csv="$output/${WC_CITY}_train_data.csv"
#output_test_csv="$output/${WC_CITY}_test_data.csv"

#code=$WC_TRAIN/40.Code
#wd=$WC_TRAIN_DATA/40.work
#output=$WC_TRAIN_DATA/40.output


# Bag and bin into the work directory
# $code/bag_and_bin.sh $input_csv $WC_MODEL_COUNT 1	# use preexisting ones and zeroes files


input_csv=$input/${WC_CITY}_train_data.csv
baseName=$( basename $input_csv | sed 's/.csv//' )
onesFile=$work/$baseName.ones.csv
zeroesFile=$work/$baseName.zeroes.csv

bin_index_day_of_week=$work/bin_index_day_of_week.txt 
bin_index_month_of_year=$work/bin_index_month_of_year.txt
bin_index_year=$work/bin_index_year.txt
bin_index_hournumber=$work/bin_index_hournumber.txt
bin_index_tract=$input/${WC_CITY}_tracts.csv

split_ones_and_zeroes() {

	$code/split_ones_and_zeroes.sh $input_csv $onesFile $zeroesFile

}
bag() {
	echo "Bagging $baggedFile from"
	echo "  $input_csv"
	echo "  $onesFile"
	echo "  $zeroesFile"
	$code/bag.sh $input_csv $onesFile $zeroesFile $baggedFile
}
# Binning needs files of the possible values for value based binning
prep_bin() {
	$helperDir/gen_bin_index_file.sh $bin_index_day_of_week day_of_week 0 6
	$helperDir/gen_bin_index_file.sh $bin_index_month_of_year month_of_year 1 12
	$helperDir/gen_bin_index_file.sh $bin_index_year year 2008 2020
	$helperDir/gen_bin_index_file.sh $bin_index_hournumber hournumber 0 23
}
bin() {
	echo "Binning to $binnedFile"
	echo "  from $baggedFile"
	echo "  using these tracts: $bin_index_tract"

	$code/bin.sh $baggedFile $binnedFile $bin_index_day_of_week $bin_index_month_of_year $bin_index_year $bin_index_hournumber $bin_index_tract
}

#if [ $WC_CITY = "seattle_wa" ] || [ $WC_CITY = "boston_ma" ]; then
#	input_csv=$input/${WC_CITY}_train_data.csv
#	$code/bag_and_bin.sh $input_csv $WC_MODEL_COUNT $1 

#elif [ $WC_CITY = "chicago_il" ]; then
#	input_csv=$input/WeatherandCrime_Data.csv
#	$code/bag_and_bin.sh $input_csv $WC_MODEL_COUNT $1
#else
#	echo "City not implemented"
#fi

split_ones_and_zeroes
prep_bin

for i in $(seq 1 $WC_MODEL_COUNT); do
	echo "i: $i"
	baggedFile=${work}/$baseName.$i.bagged.csv
	binnedFile=${output}/$baseName.$i.binned.csv
	bag
	bin

done
