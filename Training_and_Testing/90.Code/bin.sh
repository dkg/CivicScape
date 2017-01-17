#!/bin/bash -e

input_file=$1
output_file=$2
helperDir="${WC_HOME}/Helpers"

tmp_file=${output_file}.tmp

echo " Binning ${input_file} "
echo "      to ${output_file}"
awk -F, -f $helperDir/bin_1_temperature.awk ${input_file} \
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
	> ${output_file}

awk -F, -v column="37" -f $helperDir/unpivot.awk ${output_file} ${output_file} > ${tmp_file}
mv ${tmp_file} ${output_file}

awk -F, -v column="36" -f $helperDir/unpivot.awk ${output_file} ${output_file} > ${tmp_file}
mv ${tmp_file} ${output_file}

awk -F, -v column="2" -f $helperDir/unpivot.awk ${output_file} ${output_file} > ${tmp_file}
mv ${tmp_file} ${output_file}

awk -F, -v column="3" -f $helperDir/unpivot.awk ${output_file} ${output_file} > ${tmp_file}
mv ${tmp_file} ${output_file}

awk -F, -v column="1" -f $helperDir/unpivot.awk ${output_file} ${output_file} > ${tmp_file}
mv ${tmp_file} ${output_file}

exit 0
# tar -zcf $zippedFile -C $work ${output_file}Name
# gzip -f ${output_file}


