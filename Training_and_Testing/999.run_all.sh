#!/bin/bash -e
train() {
	./30.export_db_data_to_csv.sh
	./40.prepare_csv_for_R.sh
	./50.prepare_model_apps.sh
	./60.run_train_apps_on_aws.sh
}
prep_test() {
	./90.bin_test_file.sh
	./100.create_aws_test_apps.sh
	./110.upload_test_tasks.sh
}
validate_training() {
	./70.download_data_from_aws.sh		# download so we can see if enough models were generated to actually do anything
}
test() {
	./120.run_test_apps.sh
}
eval_test() {
	./130.download_test_preds.sh
	./140.eval_preds.sh
}


full_run() {
	date
	train
	date
	prep_test
	date
	echo "Sleeping for 2 hours to let the training finish"
	sleep 7200 # sleep 2 hours
	sleep 7200
	#sleep 7200
	date
	validate_training
	test
	date
	echo "Sleeping for 2 hours to let the testing finish"
	sleep 7200 # sleep 2 hours
	sleep 7200
	#sleep 7200
	date
	eval_test
	date
}

full_run

#prep_test
#echo "prep_test done"
#validate_training
#test
#echo "Sleeping for 2 hours to let the testing finish"
#sleep 7200 # sleep 2 hours
#sleep 7200
#sleep 7200
#eval_test
