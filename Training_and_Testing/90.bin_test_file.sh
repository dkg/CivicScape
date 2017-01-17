#!/bin/bash -e
code=$WC_TRAIN/90.Code
shared_code=$WC_TRAIN/SharedCode
bin_work=$WC_JOB_DIR/40.work
bin_tracts=$WC_JOB_DIR/30.database_export
work=$WC_JOB_DIR/90.work
output=$WC_JOB_DIR/90.test_results
#work=$WC_TRAIN_DATA/90.work
#output=$WC_TRAIN_DATA/90.output

bin_script=$WC_TRAIN/40.Code/bin.sh
testing_csv_dir=$WC_JOB_DIR/30.database_export
training_csv_dir=$WC_JOB_DIR/40.prepared_csvs
model_dir=$WC_JOB_DIR/70.models

mkdir -p $code $work $output

testing_file="$work/${WC_CITY}_test_data_binned.csv"

unbinned_testing_file="$testing_csv_dir/${WC_CITY}_test_data.csv"

# Bin the long-ago-exported testing dataset
# *** takes a while, only run when necessary
if [ ! -f $testing_file ]; then
	echo "Binning test file to $testing_file"
	bin_index_day_of_week=$bin_work/bin_index_day_of_week.txt 
	bin_index_month_of_year=$bin_work/bin_index_month_of_year.txt
	bin_index_year=$bin_work/bin_index_year.txt
	bin_index_hournumber=$bin_work/bin_index_hournumber.txt
	bin_index_tract=$bin_tracts/${WC_CITY}_tracts.csv
	$bin_script $unbinned_testing_file $testing_file $bin_index_day_of_week $bin_index_month_of_year $bin_index_year $bin_index_hournumber $bin_index_tract
fi



#pred_file=$output/Pred_${WC_JOB_NAME}.csv
#pred_result=$output/Pred_${WC_JOB_NAME}.txt

#train_data_prefix="$training_csv_dir/${WC_CITY}_train_data."
#train_data_suffix=".binned.csv"


#echo "Rscript $code/testNN.R $testing_file $WC_CITY "crime_count" $WC_MODEL_COUNT $train_data_prefix $train_data_suffix $model_dir/$WC_CITY $output/Pred_${WC_CITY}_${crime}.csv"
#Rscript $code/testNN.R $testing_file $WC_CITY "crime_count" $WC_MODEL_COUNT $train_data_prefix $train_data_suffix $model_dir/$WC_CITY $pred_file

#echo "Testing Done"
#echo "****"
#Rscript $code/eval.R $pred_file > $pred_result
#echo "Results saved to $pred_result"
#cat $pred_result
		




