#!/bin/bash -e
code=$WC_TRAIN/02.Code
wd=$WC_TRAIN_DATA/02.work


city=$WC_CITY

if [ -z "$city" ]; then
	echo "You must configure WC_HOME (via the 0.configure.sh script)"
	exit 1
fi

init_cmd="psql -h $WC_PG_HOST -U accountname postgres "
cmd="psql -h $WC_PG_HOST -U accountname $city"


$init_cmd -c "drop database if exists $city"  
$init_cmd -c "create database $city"

echo "1"
init=$code/db_init
mkdir -p $init
for sql in $(find $init -type f -name "*.sql"); do
	echo "Running $sql"
	$cmd -f $sql
done

echo "2"
city_dir=$code/$city
mkdir -p $city_dir
for sql in $(find $city_dir -type f -name "*.sql"); do
	echo "Running $sql"
	$cmd -f $sql
done

echo "3"
finalize=$code/db_finalize
mkdir -p $finalize
for sql in $(find $finalize -type f -name "*.sql"); do
	echo "Running $sql"
	$cmd -f $sql
done
