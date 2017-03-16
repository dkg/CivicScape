# Understanding the CivicScape data and model

## What is this page?
CivicScape is dedicated to using data and evidence-based research to help police increase both the safety and trust of the communities they serve. A key component of this commitment is making our analysis open and transparent, to enable trust and encourage constructive scrutiny where we can do better. CivicScape is the only product with this level of transparency and accuracy.

Our methodology and code are available here on our Github page. To understand our analytics you can follow the steps in our Training_and_Testing code and accompanying README. We invite and encourage feedback on the model and process at any stage. You can weigh in here. 

We also share our interactive iPython Notebooks, where we aim to make it easy for you to find answers to the following questions: 

##### How does CivicScape evaluate data used in our models for missing information? See our [Data Input Audit Notebook](https://github.com/CivicScape/CivicScape/blob/master/evaluation_notebooks/notebooks/DataInputsPractices.ipynb). 
##### How does CivicScape evaluate the accuracy of the models deployed? See our [Model Metrics Notebook](https://github.com/CivicScape/CivicScape/blob/master/evaluation_notebooks/notebooks/ModelDataPractices.ipynb). 
##### How does CivicScape make police more efficient? See our [Police Deployment Notebook](https://github.com/CivicScape/CivicScape/blob/master/evaluation_notebooks/notebooks/PoliceDeployment.ipynb).
##### How does CivicScape think about preventing bias in crime data and models? See our [Bias in Crime Data Notebook](https://github.com/CivicScape/CivicScape/blob/master/evaluation_notebooks/notebooks/PreventingBias.ipynb).

## Data
CivicScape generates its risk assessments using data that is open and available to the public whenever possible. Though some jurisdictions choose to not make their crime data publicly available, all CivicScape data sources that are public can be accessed below:

#### Example Dataset; Variables used; Source

Recent Crime Activity; Violent Crime: Robbery, assault, homicide, shooting events comprise violent crime. Property crime: motor vehicle theft and burglary; Open data portals by city; crime data provided by jurisdictions.

Community Input (e.g. 311); Different communities have different 311 or community input lines and categories, for example include 311 reports for street light outages and abandoned building reports; Open data portals by city; provided by jurisdiction.

Event Date and Time; Date and time of the crime or 311 event; Open data portals by city; provided by jurisdiction.

Event Census Tracts; Census tract of the crime or call for service event location; Open data portals by city; U.S. Census Bureau shapefiles. 

Weather Forecasts; Temperature, precipitation, relative humidity, wind speed, change in all of these conditions; National Oceanic and Atmospheric Administration (NOAA) and forecast.io.

#### Data Input Audit Notebook: How does CivicScape check for data quality?  
CivicScape evaluates all data regularly before it is deployed in the model. Poor quality data, meaning data that is systematically missing observations or important categories, such as the date or time of an event, can inject bias into a model and result in inaccurate predictions. See our working whitepaper on bias in crime data for an overview of research about bias in crime data and the resulting implications for its use.  

Our audits of all input data can be replicated by running our Data Input Audit Notebook available here on our Github page. 

## Model

Currently, CivicScape uses an ensemble of feed-forward neural network models tuned to the specific nature of crime data to understand patterns of crime across a city over time. Every model generates risk assessments for every area (roughly 3 block radius) of a jurisdiction at any a given hour, updated regularly based on slightly different initial conditions. The final risk assessment for each area that we use in CivicScape is a weighted average based on recent historical performance. A patent is pending on this work.

Our model differs from previous crime models in several key ways:

1. We focus our model on the information most useful for deployment. CivicScape calculates not just the absolute chance of crime, but the relative chance for a given area at a given time compared to the rest of the city, so that officers are able to easily understand how to act on the information in real time.

1. CivicScape analytics are trained to recognize how quickly the landscape can change. Our model has the unique capacity to analyze changes in crime risk through time, from one hour to the next. This is in part because we leverage information on how changes in the environment over a specific time period, such as the speed of changes in temperature, can impact the risk at any given area of the city.

1. We employ cutting edge science to manage the sparsity of crime events. In the eyes of an analyst, crime is a relatively rare event, and the model used to analyze it should be specifically tuned to this fact in order to perform accurately. CivicScape creates a dataset with a more balanced distribution of instances of crime and no-crime to allow for better understanding of the conditions under which crime does occur. This technique of decreasing the sampling rate of no-crime occurrences at an optimal rate is called sometimes called “downsampling”. 

1. CivicScape models only use reliable raw data. Alongside our input data evaluation that checks for missing or biased data outlined in our code supplied, the model also employs numerous random subsets of the crime data that are then each trained in a separate neural network. This decreases the influence that problematic outliers or errors in the raw data may have on the neural network performance. 

#### Model Evaluation Metrics Notebook: How do CivicScape Models perform? 
We evaluate our models using several different metrics. To start, we examine the relationship between recent crime events recorded and how often our model correctly anticipates or misses these events. These include (but are not limited to):
True Positive Rate: When a crime does happen, the percent of the time the model correctly anticipates it.
True Negative Rate: When a crime does not happen, percent of the time the model correctly anticipates that a crime would not happen.
False Positive Rate: When a crime does not happen, percent of the time the model incorrectly anticipates that an event would occur.
False Negative Rate: When a crime does happen, the percent of the time the model misses it.

To maintain usefulness of this evaluation in the field, all of our evaluation metrics are based on events and risk assessments for a one hour and roughly three-block radius unit of analysis. 

Keeping with our commitment to transparency, in our Model Evaluation Metrics notebook, we make available the model metrics detailed here and more, in addition to a comparison of all metrics to a baseline model that mimics those employed today in many departments. 

## Evaluation 
At CivicScape, we’re thinking hard about algorithms and how we evaluate their impact beyond simply how accurately our models perform. 

#### Police Deployment Evaluation Notebook: How does CivicScape make police more efficient? 
Analytics can have substantial positive impact in making police deployment more efficient. Though every police department deploys officers in a different way, we make some assumptions that allow us to visualize and quantify the improvements in crime prevention that police in the right place at the right time can attain through the use of CivicScape. 

#### Bias Evaluation Notebook: How does CivicScape think about bias in crime prediction? 
We’re concerned not only with how well CivicScape anticipates crime, but also about how bias in crime data can result in disparate public safety outcomes within a community. The notebook Preventing Bias is an overview of bias in crime data and an evaluation the how CivicScape aims to measure and does its best to remove problematic bias that could drive incorrect risk assessments. 

__
We are constantly adding new work as we develop it. Please weigh in or watch our code on this page as we push out new information. 


