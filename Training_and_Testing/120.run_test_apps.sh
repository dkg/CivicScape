

code=$WC_TRAIN/120.Code
shared_code=$WC_TRAIN/SharedCode
work=$WC_JOB_DIR/120.work
output=$WC_JOB_DIR/90.test_results
input=$WC_JOB_DIR/100.aws_test_jobs

mkdir -p $work
#for task_tar in $( find $input -name "*.tar.gz" ); do
run_test_app() {

	# Start instance & run init scripts
	echo "Starting instance to process $input_zip"
	init_log=$work/test_init_split_${split_i}.sh
	python $code/ec2_tester_launcher.py $WC_JOB_NAME $WC_CITY $WC_CRIME $split_i $WC_MODEL_COUNT $init_log
	#python $code/ec2_spot_launcher.py $crime $i
	
}
for task_tar in $( find $input -name "*.tar.gz" ); do
#for task_tar in $( find $input -name "*split_1.tar.gz" ); do
	split_i=$( basename $task_tar | cut -d "_" -f 4 | cut -d "." -f 1)
	#if [ "$split_i" = "0" ]; then  continue ;  fi
	run_test_app
done
