#!/bin/bash 
code=$WC_TRAIN/70.Code
work=$WC_JOB_DIR/70.work
output=$WC_JOB_DIR/70.models

#work=$WC_TRAIN_DATA/70.work
#output=$WC_TRAIN_DATA/70.output
#input=$WC_TRAIN_DATA/50.output
shared_code=$WC_TRAIN/SharedCode

mkdir -p $code $work $output

download_from_s3() {

	s3_dir=$WC_JOB_NAME/models

	#s3_model_file="NNmodel_${WC_CITY}_${i}.rds"
	s3_model_file="NNmodel_${WC_JOB_NAME}_${i}.rds"
	s3_log_file="NNmodel_${WC_CITY}_${i}.rds.log"
	#s3_log_file="NNmodel_${WC_JOB_NAME}_${i}.rds.log"

	echo "$shared_code/download_data_from_s3.py ${s3_dir}/${s3_model_file} $output_dir/$s3_model_file"
	$shared_code/download_data_from_s3.py ${s3_dir}/${s3_model_file} $output_dir/$s3_model_file
	#if [ -e $output_dir/$s3_model_file ]; then
	#	$shared_code/delete_data_from_s3.py ${s3_dir}/${s3_model_file}
	#fi

	$shared_code/download_data_from_s3.py ${s3_dir}/${s3_log_file} $output_dir/$s3_log_file
	#if [ -e $output_dir/$s3_log_file ]; then
	#	$shared_code/delete_data_from_s3.py ${s3_dir}/${s3_log_file}
	#fi
}

output_dir=$output/$WC_CITY
mkdir -p $output_dir

for i in $(seq 1 $WC_MODEL_COUNT); do
	download_from_s3
	sleep .05
done

model_count=`find $output_dir -name "*.rds" | wc -l`
log_count=`find $output_dir -name "*.log" | wc -l`

echo "Found $model_count models"
echo "Found $log_count logs"

if [ $log_count -gt $model_count ]; then
	echo "ERROR, there should never be more logs than models- check on .70's output"
	exit 1
fi
