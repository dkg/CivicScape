library(neuralnet)
library(nnet)

#process arguments passed into the script
args <- commandArgs(trailingOnly = TRUE)

print("===processing input parameters====")

if(length(args) != 9){
  print("[Error] Invalid Input Parameters")
  quit()
}

print("===test file to process===")
print (args[1])
testingFile = args[1]


print("========= CITY =============")
print(args[2])
city = args[2]

print("=========crime type=============")
print(args[3])
crimeColumn = args[3]


print("======number of Bagged Samples=====")
# This is actually the number of models to iterate over
print(args[4])
numOfBaggedSamples = as.integer(args[4])


print("===directory to input testing data===")
print( args[5] )
print( args[6] )

modelPrefix = args[5]
modelSuffix = args[6]


print("===directory to input model=======")
print( args[7] )
modelDir = args[7]


print("===file to output prediction=======")
print(args[8])
predictionOutputFile = args[8]

print("===file to output prediction details=======")
print(args[9])
predictionDetailOutputFile = args[9]








#load testing data
print("loading testing data")
print(testingFile)

#testingData = read.csv(file = testingFile, nrows=100)  # for testing quickly
testingData = read.csv(file = testingFile)

print("Done.")



## Create a thin dataframe of only the crime counts, and we'll append on the forecast # of crimes
myvars <- c("census_tra", "dt","hournumber",crimeColumn)
print(myvars);
forecastData = testingData[,myvars]
forecastPreds = data.frame(matrix(nrow= nrow(forecastData), ncol=numOfBaggedSamples))



#Create a new column to hold all the predictions
forecastData$prediction = 0

#Making prediciton using different Neural net


print("Start predicting....")


# The first thing to do is make sure our file has all the columns it needs
# To do this load the old bagged & binned files to get their headers

clone_testingData = testingData


test_count=0
for (i in c(1:numOfBaggedSamples)){
  print(paste("Running i=",i, "@", Sys.time()  ))
  training_model_file = paste(modelDir,"/",modelPrefix, i, ".rds", sep = "")
  
  stop = FALSE
  if (!file.exists(training_model_file)) {
    print(paste("=> training_model_file not found!", training_model_file))
    stop = TRUE
  }
  if (stop) {
    next    # continue in every other language
  }
  test_count = test_count + 1
  
  
  
  # The model is tied to the columns used in the file to generate it
  # Add / NA-out columns in clone_testingData as needed
  #load in i bagged sample to add columns for predictors used in i NN that are not in testingData (ie month of june)
  

  trainedNN = readRDS(file = training_model_file)
  testingMatrix=data.matrix(clone_testingData)
  predictedResult = predict(trainedNN, testingMatrix,type = "raw")
  forecastData$prediction = forecastData$prediction + predictedResult
  
  # <Delete>, this is for std dev calculation
  forecastPreds[,i] = predictedResult
  # </Delete>
  
  
#  rm(clone_testingData)
  gc()
}

print(paste("Found", test_count, "/",numOfBaggedSamples ,"(",  100*test_count/numOfBaggedSamples ,"%) combinations of models&training"))
if (test_count < numOfBaggedSamples/2) {
  print("***** MISSING OVER 50% OF TESTS ******")
}


#Average all different predictions
forecastData$prediction = forecastData$prediction / test_count

# <Delete>, this is for std dev calculation
SD = apply(forecastPreds,1, sd, na.rm = TRUE)	# 1 = apply the function by row
forecastData$prediction_std_dev = SD
# </Delete>


print("Done.")

print(paste("Saving prediction file...", predictionOutputFile))
#Save prediction to csv file
write.csv(forecastData, file = predictionOutputFile,row.names = FALSE)
print("Done.") 



print(paste("Saving prediction file...", predictionOutputFile))
#Save prediction to csv file
write.csv(forecastPreds, file = predictionDetailOutputFile,row.names = FALSE)
print("Done.") 





