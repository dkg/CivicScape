#!/bin/bash -e
#. 00.configure.sh

#step=30
#code=`get_code_dir "$step"`
#work=$(get_word_dir $step)
#output=$(get_output_dir $step)
code=$WC_TRAIN/30.Code
work=$WC_JOB_DIR/30.work
output=$WC_JOB_DIR/30.database_export
output_train_csv=$output/${WC_CITY}_train_data.csv
output_test_csv=$output/${WC_CITY}_test_data.csv
output_tract_csv=$output/${WC_CITY}_tracts.csv

db_cmd="psql -h $WC_PG_HOST -U master $WC_CITY"

mkdir -p $work $output

train_config=$work/export_train.yaml
test_config=$work/export_train.yaml
tract_config=$work/export_tract.yaml

run_crime_export() {
	train_config_temp=${train_config}.tmp

	sql_yaml="$code/${WC_CITY}_crimes.sql.yaml"
	if [ ! -e $sql_yaml ]; then
		echo "couldn't find $sql_yaml"
		echo "is your code up to date?"
		exit 1
	fi
	
	# Export Training Data
	cp config.yaml $train_config
	yaml set $train_config crime_sql $WC_CRIME_SQL > $train_config_temp    		; mv $train_config_temp $train_config
	yaml set $train_config start_date_sql $WC_TRAIN_START  > $train_config_temp    	; mv $train_config_temp $train_config
	yaml set $train_config end_date_sql $WC_TRAIN_END  > $train_config_temp    	; mv $train_config_temp $train_config

	sql="$work/crime_export_train.sql"
	yaml template $train_config $sql_yaml > $sql

	# Then run the exports
	echo "Running $sql"
	echo " To export $output_train_csv"
	sql_cmd=$(cat $sql)
	psql_cmd="\COPY ($sql_cmd) TO '$output_train_csv' WITH CSV HEADER"
	$db_cmd -c "$psql_cmd"



	# Export Training Data
	test_config_temp=${test_config}.tmp

	cp config.yaml $test_config
	yaml set $test_config crime_sql $WC_CRIME_SQL > $test_config_temp    		; mv $test_config_temp $test_config
	yaml set $test_config start_date_sql $WC_TEST_START  > $test_config_temp    	; mv $test_config_temp $test_config
	yaml set $test_config end_date_sql $WC_TEST_END  > $test_config_temp    	; mv $test_config_temp $test_config

	sql="$work/crime_export_test.sql"
	yaml template $test_config $sql_yaml > $sql

	# Then run the exports
	echo "Running $sql"
	echo " To export $output_test_csv"
	sql_cmd=$(cat $sql)
	psql_cmd="\COPY ($sql_cmd) TO '$output_test_csv' WITH CSV HEADER"
	$db_cmd -c "$psql_cmd"

}
run_tract_export() {
	tract_yaml="$code/${WC_CITY}_tracts.sql.yaml"
	tract_config_temp=${tract_config}.tmp

	cp config.yaml $tract_config

	sql="$work/tract_export.sql"
	yaml template $tract_config $tract_yaml > $sql

	# Then run the exports
	echo "Running $sql"
	echo " To export $output_tract_csv"
	sql_cmd=$(cat $sql)
	psql_cmd="\COPY ($sql_cmd) TO '$output_tract_csv' WITH CSV HEADER"
	$db_cmd -c "$psql_cmd"

}
save_metadata() {
	meta=$output/metadata.txt
	echo "=== Data Export ===" > $meta
	echo "Ran training sql with these params: " >> $meta
	cat $train_config >> $meta
	echo "=> Exported $(wc -l $output_train_csv | awk '{print $1}') Rows" >> $meta

	echo "" >> $meta

	echo "Ran training sql with these params: " >> $meta
	cat $train_config >> $meta
	echo "=> Exported $(wc -l $output_test_csv | awk '{print $1}') Rows" >> $meta

	echo "" >> $meta

	echo "Ran tract sql with these params: " >> $meta
	cat $tract_config >> $meta
	echo "=> Exported $(wc -l $output_tract_csv | awk '{print $1}') Tracts" >> $meta


}

run_crime_export
run_tract_export
save_metadata
