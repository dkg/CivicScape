
code=$WC_TRAIN/130.Code
shared_code=$WC_TRAIN/SharedCode
work=$WC_JOB_DIR/130.work
output=$WC_JOB_DIR/130.test_preds
input=$WC_JOB_DIR/100.aws_test_jobs

mkdir -p $output

for task_tar in $( find $input -name "*.tar.gz" ); do
#for task_tar in $( find $input -name "*split_1.tar.gz" ); do
	split_i=$( basename $task_tar | cut -d "_" -f 4 | cut -d "." -f 1)

	file=Pred_${WC_JOB_NAME}_split_${split_i}.csv
	s3_file=$WC_JOB_NAME/test_results/$file
	local_file=$output/$file
	echo $s3_file
	echo $local_file
	echo ""

	python $shared_code/download_data_from_s3.py $s3_file $local_file
done
