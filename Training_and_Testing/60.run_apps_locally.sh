#!/bin/bash
code=$WC_TRAIN/60.Code
work=$WC_TRAIN_DATA/60.work
output=$WC_TRAIN_DATA/60.output
input=$WC_TRAIN_DATA/50.output

mkdir -p $code $work $output

run_app() {
	rm -rf $work/*

	model=${crime}_model_${i}
	zip=${model}.tar.gz
	input_zip=$input/$zip
	echo $crime $i
	echo $code

	echo "cp $input_zip $work"
	cp $input_zip $work
	tar -zxf $input_zip -C $work


	driver="$work/$model/trainModel_${crime}_model_${i}_blob_ALL_weather.pbs"
	$driver


}

for crime in ${WC_CRIMES}; do
	for i in $(seq 1 $WC_MODEL_COUNT); do
	#for i in $(seq 1 1); do
		#if [[ "$crime" = "robbery" ]] ; then
		#	if [[ $i -le 1 ]] ; then
		#		continue
		#	fi
		#fi
		echo "$crime $i"
		run_app
	done
done
