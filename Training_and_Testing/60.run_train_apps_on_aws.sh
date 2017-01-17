
#!/bin/bash
code=$WC_TRAIN/60.Code
shared_code=$WC_TRAIN/SharedCode
#wd=$WC_TRAIN_DATA/60.work
#output=$WC_TRAIN_DATA/60.output
#input=$WC_TRAIN_DATA/50.output
work=$WC_JOB_DIR/60.work
input=$WC_JOB_DIR/50.training_apps
output=$WC_JOB_DIR/60.output

mkdir -p $code $wd $output


run_app() {

	zip_name=model_${i}.tar.gz

	# Upload tar.gz to s3
	input_zip=$input/$zip_name
	echo "Uploading $input_zip to S3"
	s3_file=$WC_JOB_NAME/apps/$zip_name
	python $shared_code/upload_data_to_s3.py $input_zip $s3_file

	# Start instance & run init scripts
	echo "Starting instance to process $input_zip"
	python $code/ec2_launcher.py $WC_JOB_NAME $WC_CITY $WC_CRIME $i

}

for i in $(seq 1 $WC_MODEL_COUNT); do
#for i in $(seq 41 100); do
#for i in $(seq 1 1); do
	#if [[ "$crime" = "robbery" ]] ; then
	#	if [[ $i -le 1 ]] ; then
	#		continue
	#	fi
	#fi
	echo "$WC_JOB_NAME $i"
	run_app
	echo  ""
	sleep .5
done
