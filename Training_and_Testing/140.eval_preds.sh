#!/bin/bash -e

code=$WC_TRAIN/140.Code
shared_code=$WC_TRAIN/SharedCode
work=$WC_JOB_DIR/140.work
output=$WC_JOB_DIR/140.test_results
input=$WC_JOB_DIR/130.test_preds

mkdir -p $work $output

unified_pred_file=$work/Pred_${WC_JOB_NAME}.csv
pred_result_file=$output/Pred_${WC_JOB_NAME}.txt

echo " Unifying split pred files to: "
echo "  $unified_pred_file"

# Just get 1 header
for split_csv in $( find $input -name "*.csv" ); do
	head -n 1 $split_csv > $unified_pred_file
	break
done

# Concat all the preds into one file
for split_csv in $( find $input -name "*.csv" ); do
#for task_tar in $( find $input -name "*split_1.tar.gz" ); do

	tail -n +2 $split_csv >> $unified_pred_file
done

Rscript $code/eval.R $unified_pred_file > $pred_result_file
echo "Eval Results saved to $pred_result_file"
cat $pred_result_file
