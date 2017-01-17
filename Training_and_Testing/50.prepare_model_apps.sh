#!/bin/bash

code=$WC_TRAIN/50.Code
work=$WC_JOB_DIR/50.work
input=$WC_JOB_DIR/40.prepared_csvs
output=$WC_JOB_DIR/50.training_apps

mkdir -p $code $wd $output

#for weather in WEATHER NOWEATHER; do
for weather in WEATHER; do
	for blob in NOBLOB; do
		echo "$code/prepare_training_app.sh $crime $weather $blob"
		$code/prepare_training_app.sh $weather $blob
	done
done
