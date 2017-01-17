library(neuralnet)
library(nnet)

#process arguments passed into the script
args <- commandArgs(trailingOnly = TRUE)

print("===processing input parameters====")

if(length(args) != 6){
  print("[Error] Invalid Input Parameters")
  quit()
}

print("=========crime type=============")
print(args[1])
crimeType = args[1]

print("===directory to input training data===")
print(args[2])
trainingDataDir = args[2]

print("===directory to output model=======")
print(args[3])
modelDir = args[3]

print("======Index of Bagged Samples=====")
print(args[4])
indexOfBaggedSamples = as.integer(args[4])

print("===number of hidden nodes=======")
print(args[5])
nHidden = as.integer(args[5])

print("======number of iterations=====")
print(args[6])
nIter = as.integer(args[6])


#load training data
print("loading training data...")
trainingData = read.csv(paste(trainingDataDir, "/WeatherandCrime_Data.robbery.",indexOfBaggedSamples,".binned.csv",sep=""))
trainingData = data.frame(trainingData)
print("Done.")

#Prepare model formula
crimeType = trainingData$robbery_count
names = names(trainingData)

predictors = trainingData[!names %in% c("shooting_count", "census_tra", "year", "hournumber", "dt", "robbery_count", "assault_count", "hourstart", "hr", "wind_speed", "drybulb_fahrenheit", "hourly_precip", "relative_humidity", "dod1_drybulb_fahrenheit", "dod2_drybulb_fahrenheit", "dod3_drybulb_fahrenheit", "wow1_drybulb_fahrenheit", "wow2_drybulb_fahrenheit", "precip_hour_cnt_in_last_1_day", "precip_hour_cnt_in_last_3_day", "precip_hour_cnt_in_last_1_week", "hour_count_since_precip", "month_of_year", "day_of_week")]

trainingData <- cbind(crimeType,predictors)

#f <- as.formula(paste(paste(crimeType," ~"), paste(predictors, collapse = " + ")))
f <- as.formula(paste('crimeType ~', paste(colnames(trainingData), collapse = '+')))

#Train NN model
print("Training model....")

ir.nn <- nnet(f, data = trainingData, size = nHidden, rang = 0.1, MaxNWts = 30000, decay = 5e-4, maxit = nIter)

#Save trained model in model directory
print("Saving model....")
saveRDS(ir.nn, file = paste(modelDir,"/NNmodel_",indexOfBaggedSamples,".rds",sep = ""))

print(paste("Model",indexOfBaggedSamples,"Finished Training."))


