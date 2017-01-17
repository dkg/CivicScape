#!/bin/bash -e
code=$WC_TRAIN/50.Code
work=$WC_JOB_DIR/50.work
input=$WC_JOB_DIR/40.prepared_csvs
output=$WC_JOB_DIR/50.training_apps

mkdir -p $work $output

function displayUsage {
	echo "./prepare_training_app.sh {,NO}WEATHER {,NO}BLOB"	
	echo "eg:  ./prepare_training_app.sh WEATHER NOBLOB"
	echo "NOBLOB = Running without blobs"
}

if [[ "x$1" == "xNOWEATHER" ]]; then
	pbs_script_suffix="noweather"
	r_script_weather_prefix="_noweather"
elif [[ "x$1" == "xWEATHER" ]]; then
	pbs_script_suffix="weather"
	r_script_weather_prefix=""
else
	echo "2nd param must be either: WEATHER or NOWEATHER"
	displayUsage
	exit 1
fi

if [[ "x$2" == "xNOBLOB" ]]; then
	blobs="ALL"
	#DATAPATH=/home/mking/data/$crime
	# DATAPATH="/Users/jeff/wsPersonal/Weather-and-Crime/anl/data/$crime"
	DATAPATH="$WC_TRAIN_DATA/4.work/$WC_CITY/$crime"
	r_script_blobs_postfix=""
	r_script_blob_param=""
	
elif [[ "x$2" == "xBLOB" ]]; then
	blobs=`seq 0 37`
	#DATAPATH="/home/mking/data/blobs/blob_\$blob/$crime"
	#DATAPATH="/Users/jeff/wsPersonal/Weather-and-Crime/anl/data/blobs/blob_\$blob/$crime"
	DATAPATH="$WC_TRAIN_DATA/4.work/$WC_CITY/blob_\$blob/$crime"
	r_script_blobs_postfix="_blobs"
	r_script_blob_param="\$blob"
else
	echo "3nd param must be either: BLOB or NOBLOB"
	displayUsage
	exit 1
fi



mkdir -p $work/$crime

for blob in $blobs
do
	
	## Write .pbs file to the directory 
	work_config=$work/blob_${blob}_config.yaml
	temp_config=${work_config}.tmp
	cp config.yaml $work_config
	
	yaml set $work_config city $WC_CITY  > $temp_config 		; mv $temp_config $work_config
	yaml set $work_config output $output  > $temp_config 		; mv $temp_config $work_config
	yaml set $work_config code $code  > $temp_config 		; mv $temp_config $work_config
	yaml set $work_config blob $blob  > $temp_config 		; mv $temp_config $work_config
	yaml set $work_config r_script_weather_prefix $r_script_weather_prefix > $temp_config		; mv $temp_config $work_config 
	yaml set $work_config r_script_blobs_postfix $r_script_blobs_postfix > $temp_config		; mv $temp_config $work_config 
	yaml set $work_config r_script_blob_param $r_script_blob_param > $temp_config			; mv $temp_config $work_config 
	yaml set $work_config DATAPATH $input > $temp_config			; mv $temp_config $work_config 
	yaml set $work_config MODELPATH $output > $temp_config			; mv $temp_config $work_config 
	
	yaml set $work_config R_NNET_HIDDEN_NODE_COUNT $R_NNET_HIDDEN_NODE_COUNT > $temp_config		; mv $temp_config $work_config 
	yaml set $work_config R_NNET_ITER_COUNT $R_NNET_ITER_COUNT > $temp_config			; mv $temp_config $work_config 
	
	for i in $(seq 1 $WC_MODEL_COUNT)
	do
		echo "Running $i"
		model_config=$work/model_${i}_config.yaml
		model_temp=${model_config}.tmp
		cp $work_config $model_config
		
		train_csv="${WC_CITY}_train_data.${i}.binned.csv"
		train_zip=${train_csv}.tar.gz

		yaml set $model_config model_number $i 	   > $model_temp	; mv $model_temp $model_config 
		yaml set $model_config train_csv $train_csv > $model_temp	; mv $model_temp $model_config 
		yaml set $model_config train_zip $train_zip > $model_temp	; mv $model_temp $model_config 


		app_folder=model_$i
		iter_dir=${work}/$app_folder
		rm -rf $iter_dir
		mkdir -p ${iter_dir}

		# Copy the data in
		file=$train_csv
		cp $input/$file ${iter_dir} 

		# Put the default app contents 
		# Put the R script there too- for now let's just grab them all and let the bash script choose which it wants
		cp $code/app_default_content/* $iter_dir

		# Put the driving script in the output dir
		pbs_file=${iter_dir}/trainModel_model_${i}_blob_${blob}_${pbs_script_suffix}.pbs
		yaml template $model_config $code/model_generator.sh.yaml > $pbs_file
		chmod +x $pbs_file

		# Output
		mkdir -p ${output}
		zippedFile="${output}/${app_folder}.tar.gz"
		tar -zcf $zippedFile -C $work $app_folder
	done
	rm $work_config

done


