#!/bin/bash -e 

code=$WC_TRAIN/100.Code
work=$WC_JOB_DIR/100.work
input_csv_dir=$WC_JOB_DIR/90.work
input_csv=${WC_CITY}_test_data_binned.csv
input=$WC_JOB_DIR/90.prepared_csvs
output=$WC_JOB_DIR/100.aws_test_jobs

#rm -rf $work $output
mkdir -p $code $output $work

split_csv() {
	owd=$( pwd )
	cd $work
	input_file=$input_csv_dir/$input_csv
	input_file_no_header=$input_file.noheader
	tail -n +2  $input_file > $input_file_no_header
	split -l 100000 $input_file_no_header

	i=0
	for file in $( ls x* ); do

		loop_file=split_${i}.csv
			
		head -n 1 $input_file > $loop_file
		cat $file >> $loop_file
		
		i=$(($i+1))
	done
	cd $owd
}

create_aws_driver_scripts() {

	for file in $( find $work -name "split_*.csv" -type f ); do
		echo "processing $file"
		split=$(basename $file | cut -d "_" -f 2 | cut -d "." -f 1)
		split_dir=$work/task_test_split_$split
		mkdir -p $split_dir

		work_config=$work/split_${split}_config.yaml
		temp_config=${work_config}.tmp
		cp config.yaml $work_config

		yaml set $work_config city $WC_CITY  > $temp_config 		; mv $temp_config $work_config
		yaml set $work_config WC_JOB_NAME $WC_JOB_NAME  > $temp_config 	; mv $temp_config $work_config
		yaml set $work_config split $split  > $temp_config 		; mv $temp_config $work_config
		yaml set $work_config testing_file $(basename $file)  > $temp_config 	; mv $temp_config $work_config
		yaml set $work_config WC_MODEL_COUNT $WC_MODEL_COUNT  > $temp_config 	; mv $temp_config $work_config

		yaml template $work_config $code/driver.sh.yaml > $split_dir/driver.sh
			
	done



# Rscript $code/testNN.R $testing_file $WC_CITY "crime_count" $WC_MODEL_COUNT $train_data_prefix $train_data_suffix $model_dir/$WC_CITY $pred_file
}

fill_rest_of_task() {
	# Move the split test csv in
	for file in $( find $work -name "split_*.csv" -type f); do
		split=$(basename $file | cut -d "_" -f 2 | cut -d "." -f 1)
		split_dir=$work/task_test_split_$split
		mv $file $split_dir
	done
	# Copy all models in
	for split_dir in $( find $work -name "task_test*" -type d );do
		echo $split_dir
		cp $code/testNN.R $split_dir
	done

}
create_tasks() {
	for task_dir in $( find $work -name "task_test*" -type d ); do
		echo $task_dir
		task=$( basename $task_dir)
		tar -czf $output/${task}.tar.gz -C $task_dir/.. $task
	done
}

split_csv
create_aws_driver_scripts
fill_rest_of_task
create_tasks
