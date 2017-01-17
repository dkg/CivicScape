# Overview

This is the README for the Training Pipeline for CrimeScape. We use the Training Pipeline for two functions: 1) testing models to identify the most effective ones and 2) deploying them.  

To test models, we use this pipeline to configure different variables, geographic sizes, and time periods to name a few ongoing research topics we are pursuing to keep improving our models. If you're interested in digging into some of the testing and research we have already undertaken and the science behind the algorithm, please reference either our Github page for a summary or our working paper. 

To deploy models to our sites, we use this pipeline to generate the base models for each jurisdiction that we subsequently use in the Master Pipeline, which updates predictions for our users, and the Updater Pipeline, which updates our models with refreshed data for timely risk assessment. 

# Initial setup

## Requirements: 
* R
* python
* postgres 
* curl 
* wget
* boto3 (pip install boto3)
* Postgis
* jq
* go
* jsontocsv from github.com/jehiah/json2csv

## AWS Set up
This pipeline assumes an Amazon Web Services (AWS) account configured with the appropriate AWS instances required for this code. 

# How to use the Training Pipeline:

To execute the Training Pipeline and run a new set of models for a new or existing jurisdiction, we focus on two files in this directory: 
 1. 00.configure.sh: edit this file before executing the job. 
 1. 999.run_all.sh: run this file to execute the job. 

The Training pipeline runs by executing these as follows: 
```
source 00.configure.sh
./999.run_all.sh. 
```

The first line sets the environment for our job. The second line executes a job with the parameters as specified by 00.configure.sh. We set up the 00.configure.sh by specifying the following values which determine what kind of model we run: 
* WC_city = the jurisdiction in which we run this model 
* WC_MODEL_COUNT= how many models will be individually run on subsets of data to aggregate to an overall risk assessment score
* WC_CRIME= what type of crime this model anticipates
* WC_CRIME_SQL= what type of crime this model should use for exporting data from our RDS
* WC_TRAIN_START= the start of our training dataset 
* WC_TRAIN_END= the end of our training dataset
* WC_TEST_START= the start of our testing dataset
* WC_TEST_END= the end of our testing dataset 
* R_NNET_HIDDEN_NODE_COUNT= the number of hidden node iterations used in the neural network algorithm
* R_NNET_ITER_COUNT= the number of subsets of data and corresponding iterations of the neural network will factor into this model 

After specifying the necessary crime, city and model set-up steps for the 00.configure.sh file, if we have existing data loaded and formatted, we are then ready to run the model. We would use .999.run_all.sh to run steps 30. through 140. in the Training pipeline directory, which is equivalent to running all remaining steps in teh creation of the model, including exporting  datasets, formatting variables, training models, testing them, and evaluating the final model metrics. The final output of each Training pipeline job are model metrics.

If we have not yet set up the necessary data for the models to run in the Training Pipeline, we follow the steps below to set up new jurisdictions, geographic cells, configuration of crime types and weather data. 

### How to set up the Training Pipeline for a new jurisdiction

For the Training Pipeline to run, we set up the following steps detailed below in order to execute a new job. 

1. Define crime definitions for violent crime, robbery, and if applicable property crime(s) for the jurisdiction. We work closely with jurisdiction partners to ensure that the crime types that we define prior to running a model are appropriate for the jurisdiction. Importantly, we test this data for completeness and accuracy. To test data and to ensure that nothing we need is missing or problematic, we run internal checks as outlined in our Data Inputs Notebook that verify the usability of the data. 

2. Decide on the final crime definitions and code accordingly in RDS table set-up. The crime codes that are used for each crime type are specified before loading data. 

3. Load the crime data, weather data (and other useful predictors such as 311) into the  database. We do this by manually executing steps 01. through 20. in the Training Pipeline directory. Training_Pipeline/20.Code/crime_upsert.sql uses the definitions from we set in the step above to specify what crime events constitute the violent, property or robbery incidents we incorporate in our models. We record row counts and note any missing data by running Postgres_crime_all_check.sql and recording results. 

### Data Loading Details
The data load step in detail includes manually running the following steps. 

1. Edit 10.download_data.sh — create a new set of export commands at the bottom for your jurisdiction. Then create three functions -- one each for weather, crime and census-- for your jurisdiction. Fields to edit include:
	* WBANS - these are the NOAA weather stations that correspond to each jurisdiction. We check Plenar.io for available WBANS.
	* Start year and end year in weather function for your jurisdiction
	* Shapefile name and SRID for your jurisdiction - make sure to upload census tract shape files and record Spatial Reference System Identifier (SRID) information. 
	* Source of crime for your jurisdiction.

2. Run 10.download_data.sh in the terminal to upload crime and weather data.

3. Create the weather, census, and crime tables. We use Plenar.io to uniformally load data for all of our jurisdictions. We follow the same process as above and create a weather_import table and a weather_all table. Next, we popualate census tracts by creating a 30.create_pop_census_tracts file in the jurisdiction directory in 02.Code. This step takes all of the crime data and will match it to its corresponding census tract or cell. 

4. Run 02.install_database.sh to install a database with the jurisdiction and table information specified. 

5. Edit and run 20.load_data_into_db.sh to add a new set of lines for your jurisdiction to load weather, crime and, if applicable 311 data into the database.

6. Now we run ./999.run_all.sh. and allow 8 hours or so while the models process.

#### To run models with cells 
We follow these additional steps in the data loading process to use a grid instead of census tract as the geometric type: 

1. Create  30.Code/$WC_jurisdiction_cell_setup.sql for the new jurisdiction. 
2. Open the script above. 
3. Run all of the code in this file to generate the lists of census tracts that we need in order to link each cell with its corresponding census tracts.  
4. We export our shapefiles for use on our sites.

### Additional Predictor Variables 

Often we want to use additional predictor variabes to increase the performance of our models. We find that both lagged crime variables and 311 data can be helpful information to add. Some research has documented what variables are helpful but internal testing also drives decisions to include particular variables. 

For crimes like robbery and property crimes, research shows that these crimes often happen in short subsequent order - so if a robbery occurs, the chance that another occurs in the same area shortly thereafter is high. For more violent crimes, retaliation in a certain timeframe is likely. Adding this information is important for the quality of the models we run. 

Internally, we also work to verify that what we add to models is helpful to their quality. We know that when we add robberies and property crimes for the past 2 days and 3 days, we are able to improve our model's true positive rates and false positive rates. This means our models are better at assessing the risk of how often a crime occurs when we anticipate that one does, and how often a crime occurs when we anticipate that one does not. We also know that when we add lagged crime information to violent crime, historical information is important but the recentness of the timeframe adds less to the model outcomes. 

Different jurisdictions record different data, but we can often include 311 variables such as: 
* illegal dumping reports
* building maintenance reports
* sanitation reports 
* tree trimming reports
* traffic reports 
* vacant building reports
* abandoned vehicle reports 
* street light outages reports
* alley light outages reports
* garbage pickup reports

With crime data, we have more options available to us, but we often include in our robbery and property crime models information about
* if crime occured in the past day in a particular geographic area 
* if crime occurred in past two days in a particular geographic area
* if crime occurred in past three days in a particular geographic area
* if crime occurred in past week in a particular geographic area

The process for using additional predictor variables such as 311 or lagged crime variables, we edit 30.Code to incorporate these changes.  



