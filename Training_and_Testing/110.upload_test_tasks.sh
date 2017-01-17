
code=$WC_TRAIN/110.Code
shared_code=$WC_TRAIN/SharedCode
work=$WC_JOB_DIR/90.work
output=$WC_JOB_DIR/90.test_results
input=$WC_JOB_DIR/100.aws_test_jobs

for task_tar in $( find $input -name "*.tar.gz" ); do
#for task_tar in $( find $input -name "*split_0.tar.gz" ); do
	base=$( basename $task_tar )	
	python $shared_code/upload_data_to_s3.py $task_tar $WC_JOB_NAME/test_apps/$base
done
