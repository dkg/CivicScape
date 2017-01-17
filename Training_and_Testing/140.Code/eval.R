#R script for evaluating results from prediction.csv 

args <- commandArgs(trailingOnly = TRUE)

#define arguments passed into the script
#args <- commandArgs(trailingOnly = TRUE)
#workingDir = args[1]
#predictions_data = args[2]
#ratio = args[3]

#ratio = ratio

#setwd(workingDir)
#data <- read.csv(file=predictions_data)


# Set wd and data manually instead:
#setwd("/home/mking/data")  #CHANGE for crime type BEFORE running
#data <- read.csv("shooting_prediction1to100_ratio_3_weighted.csv")  #CHANGE to prediction csv number BEFORE running
pred_file=args[1]
print("Using pred_file:")
print(pred_file)
data <- read.csv(pred_file)

data$census_tra = data[,1]
data$dt = data[,2]
data$hournumber = data[,3]
data$true_crime = data[,4]
data$prediction = data[,5]
data$predictionBinary = data[,6]


data$predictionBinary = data$prediction
data$predictionBinary[data$prediction>=0.5] = 1
data$predictionBinary[data$prediction<0.5] = 0


data<- subset(data, !is.na(prediction))
#from https://en.wikipedia.org/wiki/Sensitivity_and_specificity :)

#Create TP and TN rates
data$tp <- ifelse((data$true_crime == 1 & data$predictionBinary == 1), 1, 0)
data$tn = ifelse((data$true_crime == 0 & data$predictionBinary == 0), 1, 0)
data$fp = ifelse((data$true_crime ==0 & data$predictionBinary ==1),1, 0)
data$fn = ifelse((data$true_crime ==1 & data$predictionBinary==0), 1, 0)
tp_sum = sum(data$tp)
tn_sum = sum(data$tn)
fp_sum = sum(data$fp)
fn_sum = sum(data$fn)

# Calculate Sensitivity (aka recall aka TPR)
tpr = tp_sum/(tp_sum + fn_sum)

# Calculate Specificity (aka TNR)
tnr = tnr = tn_sum/(tn_sum + fp_sum)

# Calculate False Positive Rate (FPR)
fpr = 1 - tnr

#Accuracy
acc = (tp_sum + tn_sum) / (nrow(data))

#print(ratio)
print(paste0("TPR:", tpr))
print(paste0("TNR:", tnr))
print(paste0("FPR:", fpr))
print(paste0("ACCURACY:", acc))

