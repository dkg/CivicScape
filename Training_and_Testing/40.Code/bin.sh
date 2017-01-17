#!/bin/bash -e
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
		echo "Need to pass in an output file"
		exit 1
fi


input=$1
output=$2
bin_index_day_of_week=$3
bin_index_month_of_year=$4
bin_index_year=$5
bin_index_hournumber=$6
bin_index_tract=$7
tmp_output=${output}.tmp



awk -F, -f $helperDir/bin_1_temperature.awk $input \
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
	> $output

# day_of_week  old: 37,  new: 37  		0-6
awk -F, -v indexColumn="1" -v unpivotColumn="37" -f $helperDir/unpivot_with_index.awk $bin_index_day_of_week $output > $tmp_output
mv $tmp_output $output

#month_of_year   old: 36, new: 36		1-12
awk -F, -v indexColumn="1" -v unpivotColumn="36" -f $helperDir/unpivot_with_index.awk $bin_index_month_of_year $output > $tmp_output
mv $tmp_output $output

# year  old: 2   new: 6			2010-2020
awk -F, -v indexColumn="1" -v unpivotColumn="6" -f $helperDir/unpivot_with_index.awk $bin_index_year $output > $tmp_output
mv $tmp_output $output

# hournumber  old: 3,  new: 7		0-23
awk -F, -v indexColumn="1" -v unpivotColumn="7" -f $helperDir/unpivot_with_index.awk $bin_index_hournumber $output > $tmp_output
mv $tmp_output $output

# census_tract  old: 1  new: 1		from csv
awk -F, -v indexColumn="1" -v unpivotColumn="1" -f $helperDir/unpivot_with_index.awk $bin_index_tract $output > $tmp_output
mv $tmp_output $output




