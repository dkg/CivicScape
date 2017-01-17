#!/bin/bash -e
# Right now you must `source 00.configure.sh` to get the variables to take effect

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
# Params to add:
# Train {Start,End} Dt
# Test  {Start,End} Dt
# Hidden nodes
# Iterations


### Env Setup
export WC_HOME=$DIR/..
#export WC_TRAIN=${WC_HOME}/training_pipeline
export WC_TRAIN=${DIR}
export WC_TRAIN_DATA=${WC_TRAIN}/data
export WC_JOBS_DIR=${WC_TRAIN}/jobs

export WC_PG_AWS="true"
export WC_PG_DB=$WC_CITY

export WC_PG_DIR="/home/athena/data"

# PG aws vars
export WC_PG_HOST="account.info.rds.amazonaws.com"


### Job Setup

## WC_Crime types to input: robbery, violent, property

# philadelphia
export WC_CITY="philadelphia_pa"
##export WC_MODEL_COUNT=1
#export WC_MODEL_COUNT=5
export WC_MODEL_COUNT=100
export WC_CRIME="robbery"
export WC_CRIME_SQL="robbery_count"
export WC_TRAIN_START="'2013-01-01'"
export WC_TRAIN_END="'2015-12-31 23:00:00'"
export WC_TEST_START="'2016-01-01'"
export WC_TEST_END="'2016-12-31'"
export R_NNET_HIDDEN_NODE_COUNT=35
export R_NNET_ITER_COUNT=100


# Dates
# Dates

### Job Setup
export WC_JOB_NAME="${WC_CITY}-date-jobname"
export WC_JOB_DIR="${WC_JOBS_DIR}/${WC_JOB_NAME}"
echo "Running job in: $WC_JOB_DIR"
mkdir -p $WC_JOB_DIR


yaml="config.yaml"
echo "wc_city: ${WC_CITY}" > $yaml
echo "wc_home: ${WC_HOME}" > $yaml
echo "wc_train: ${WC_TRAIN}" >> $yaml
echo "wc_train_data: ${WC_TRAIN_DATA}" >> $yaml
echo "wc_model_count: ${WC_MODEL_COUNT}" >> $yaml
echo "wc_crimes: ${WC_CRIMES}" >> $yaml
echo "wc_pg_db: ${WC_PG_DB}" >> $yaml

mkdir -p $WC_TRAIN_DATA

if [ -e 00.configure.sh ]; then
	cp -f 00.configure.sh $WC_JOB_DIR

fi


wc_status() {
	env | grep "^WC"
}




