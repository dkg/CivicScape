#!/bin/sh
displayUsage {
	echo "./train.sh {shooting,assault,robber} {,NO}WEATHER {,NO}BLOB"	
	echo "eg:  ./test.sh shooting WEATHER NOBLOB"
}
crime=$1
if [[ "x$crime" == "x" ]]; then
	echo "Must pass in a crime: shooting, assault, robbery"
	displayUsage
	exit 1
fi

if [[ "x$2" == "xNOWEATHER" ]]; then
	pbs_script_suffix="noweather"
	r_script_weather_prefix="_noweather"
elif [[ "x$2" == "xWEATHER" ]]; then
	pbs_script_suffix="weather"
	r_script_weather_prefix=""
else
	echo "2nd param must be either: WEATHER or NOWEATHER"
	displayUsage
	exit 1
fi

if [[ "x$3" == "xNOBLOB" ]]; then
	blobs="ALL"
	r_script_blob_param=""
	r_script_blobs_postfix=""
	MODEL_PATH=/home/mking/data/$crime
	INPUT_DATA_PATH=/home/mking/data/$crime
	PREDICTION_PATH=/home/mking/data/$crime
	
elif [[ "x$3" == "xBLOB" ]]; then
	blobs=`seq 0 37`
        #blobs=`seq 1 1`
	r_script_blob_param="\$blob"
	r_script_blobs_postfix="_blobs"
	MODEL_PATH="/home/mking/data/blobs/blob_\$blob/$crime"
	INPUT_DATA_PATH="/home/mking/data/blob_test_data"
	PREDICTION_PATH=$MODEL_PATH/$crime
else
	echo "3nd param must be either: BLOB or NOBLOB"
	displayUsage
	exit 1
fi


mkdir -p generated_pbs	# Make the directory if it doesn't exist
for blob in $blobs
do
pbs_file=generated_pbs/testModel_${crime}_blob${blob}_${pbs_script_suffix}.pbs
pbs_base_file=$(basename $pbs_file)
pbs_file_root=${pbs_base_file%.*}   # remove the .pbs


echo "#!/bin/sh
#PBS -N $pbs_file_root
#PBS -l nodes=1:ppn=8,pmem=10000mb
#PBS -l walltime=24:00:00
#PBS -j oe
#PBS -o /home/mking/pbs_output
#PBS -m abe
#PBS -M meemking@gmail.com

blob=$blob

export PATH=\$PATH:/soft/R/3.0.2/bin/

WeatherAndCrimeROOT=/home/mking/src/
MODEL_PATH=$MODEL_PATH
INPUT_DATA_PATH=$INPUT_DATA_PATH
PREDICTION_PATH=$PREDICTION_PATH

numOfBags=100


cd \$WeatherAndCrimeROOT

r_script="testNN${r_script_weather_prefix}_$crime${r_script_blobs_postfix}.R"

if [ "x$3" == "xBLOB" ]; then
	test_file=/home/mking/data/blob_test_data/crime_data_blob_${blob}.binned.csv
        #Run testing model by: Rscript [testModel.R] [crimeType] [directory to testing data] [directory to model file] [directory to output prediction file] [number of bagged samples]

	Rscript \$r_script "${crime}_count" \$INPUT_DATA_PATH \$MODEL_PATH \$PREDICTION_PATH \$numOfBags \$test_file \$blob $r_script_blob_param
else 
    test_dir=/home/mking/data/noblob_test_data/
    i=0
    for test_file in \${test_dir}/split_*
    do
    i=\$((i+1))
    #Run testing model by: Rscript [testModel.R] [crimeType] [directory to testing data] [directory to model file] [directory to output prediction file] [number of bagged \
samples]
    Rscript \$r_script "${crime}_count" \$INPUT_DATA_PATH \$MODEL_PATH \$PREDICTION_PATH \$numOfBags \$test_file \$i
    done
    
fi


#Run testing model by: Rscript [testModel.R] [crimeType] [directory to testing data] [directory to model file] [directory to output prediction file] [number of bagged samples]
#Rscript \$r_script "${crime}_count" \$INPUT_DATA_PATH \$MODEL_PATH \$PREDICTION_PATH \$numOfBags \$test_file \$blob $r_script_blob_param 

" > $pbs_file

qsub $pbs_file

done
