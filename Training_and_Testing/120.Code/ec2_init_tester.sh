#!/bin/bash

# Default paths to use the current directory
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

testing_file=$DIR/{{testing_file}}

city={{city}}
WC_MODEL_COUNT={{WC_MODEL_COUNT}}

model_prefix="NNmodel_{{WC_JOB_NAME}}_"
model_suffix=".rds"

output=$DIR/../output
mkdir -p $output

pred_file=$output/Pred_{{WC_JOB_NAME}}_split_{{split}}.csv
pred_file_detail=$output/Pred_{{WC_JOB_NAME}}_split_{{split}}_detail.csv

Rscript $DIR/testNN.R $testing_file $city "crime_count" $WC_MODEL_COUNT $model_prefix $model_suffix $DIR $pred_file $pred_file_detail
