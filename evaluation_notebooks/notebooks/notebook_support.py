# Code to support notebooks

import __future__
import itertools
import numpy as np
import matplotlib.pyplot as plt
from sklearn import svm, datasets
from sklearn.model_selection import train_test_split
from sklearn.metrics import confusion_matrix
import pandas as pd
import os
from sklearn import metrics
import itertools
from IPython.display import Image
import warnings


ACT_CRIMES = ['crime_count']
RISK_CRIMES = ['risk_assessment']
HIST_CRIMES = ['crime_count_historical']
HISTOFFSET = 3

def data_check(risk_assessments, historical):
    '''
    Checks that necessary columns are here.
    '''
    expected_risk = ['census_tra', 'dt', 'hournumber', 'crime_count', 'risk_assessment', 'risk_st_dev']
    expected_hist = ['month', 'year', 'census_tra', 'crime_count']
    diff = list(set(expected_risk).difference(set(risk_assessments.columns))) + list(set(expected_hist).difference(set(historical.columns)))
    if len(diff) > 0:
            print("\nLooks like the files you uploaded may have some missing columns:\n")
            print(diff)
    else:
        print("\nData files were loaded! You're ready to start!\n")

def data_prep(risk_assessments, historical):
    '''
    Carries out all the necessary data prep.
    '''
    # Split the date-time column into parts
    risk_assessments['dt'] = pd.to_datetime(risk_assessments['dt'])
    risk_assessments['month'] = risk_assessments['dt'].map(lambda x:x.month)
    risk_assessments['day_of_week'] = risk_assessments['dt'].map(lambda x:x.dayofweek)
    risk_assessments['date'] = risk_assessments['dt'].map(lambda x:x.day)
    risk_assessments['year'] = risk_assessments['dt'].map(lambda x:x.year)
    # Convert crime_count into a binary variable
    risk_assessments['crime_count'] = np.where(risk_assessments.crime_count >= 1, 1, 0)
    # Check only 0,1 values present
    assert set(risk_assessments.crime_count.values) == set([0,1])
    print ("\nData prep done!")
    columns = risk_assessments.columns
    pmin = risk_assessments.dt.min()
    pmax = risk_assessments.dt.max()
    print("This file contains risk_assessments for the test date range {} through {}.".format(pmin, pmax))
    return (risk_assessments, historical)

def constrict_times(risk_assessments, historical=None, hours=(), days=[], date_range=()):
    '''
    Allows user to contrict the analysis to a particular hour, date, or date_range.
    '''
    pd.options.mode.chained_assignment = None

    for x in [hours, days, date_range]:
        assert type(x) == list or type(x) == tuple

    if hours != ():
        if 24 in hours:
            print("\n24 is not an hour on the 24-hour clock; use 0.")
            raise ValueError
        low = hours[0]
        high = hours[1]
        hours = list(range(low, high))
        ## If the time spans around midnight, will be empty
        if hours == []:
            hours = list(range(low, 23)) + list(range(0, high + 1))
        ## Cut by whether hour number is in set
        risk_assessments = risk_assessments[risk_assessments['hournumber'].isin(hours)]
        print("\nYou've restricted the risk score data for the following hours:")
        print("    {}:00 until {}:00".format(low, high))
        if historical and 'hournumber' not in historical.columns:
            print("\nYour historical dataset does not have an hours column.")
        elif historical:
            historical = historical[historical['hournumber'].isin(hours)]

    if days != []:
        translate = {'M': 0, 'T': 1, 'W': 2, 'R': 3, 'F': 4, 'Sa': 5, 'Su': 6}
        # Remove anything that doesn't match standard
        poor = [x for x in days if x not in translate]
        if len(poor) > 0:
            print('\nThe following days of the week were not in the correct format:')
            print(poor)
        # Translate to numbers
        days_trans = [translate[x] for x in days if x in translate]
        # Cut by presence in list
        risk_assessments = risk_assessments[risk_assessments['day_of_week'].isin(days_trans)]
        print("\nYou've restricted the risk score data for the following days:")
        print("    {}".format(days))
        if 'day_of_week' not in historical.columns:
            print("\nYour historical dataset does not have a day_of_week column.")
        else:
            historical = histoical[historical['day_of_week'].isin(days_trans)]

    if date_range != ():
        low = pd.to_datetime(date_range[0])
        high = pd.to_datetime(date_range[1])
        if high > risk_assessments.dt.max():
            high = risk_assessments.dt.max()
            print("\nYou've entered a date past the end of your dataset.")
        if low < risk_assessments.dt.min():
            low = risk_assessments.dt.min()
            print("\nYou've entered a date earlier than the beginning of your dataset.")
        # Cut risk_assessments by membership
        risk_assessments = risk_assessments[(risk_assessments.dt >= low) & (risk_assessments.dt <= high)]
        # Make sure historical.dt is in datetime; cut to match (3-year history)
        if type(historical) != type(None):
            historical['dt'] = pd.to_datetime(historical['dt'])
            historical = historical[(historical.dt >= low - pd.DateOffset(years=HISTOFFSET)) & (historical.dt <= high)]
            print("\nYou've restricted the risk score data for the following dates:")
            print("    {} through {}".format(low, high))

    pd.options.mode.chained_assignment = 'warn'
    if type(historical) != type(None):
        return risk_assessments, historical
    else:
        return risk_assessments

def plot_roc(fpr, tpr, thresholds, roc_auc):
    '''
    Plots the ROC curve.
    '''
    plt.figure()
    plt.plot(fpr, tpr, color='darkorange', label='ROC curve (AUC = %0.2f)' % roc_auc)
    plt.plot([0, 1], [0, 1], color='navy', linestyle='--')
    plt.xlim([0.0, 1.0])
    plt.ylim([0.0, 1.05])
    plt.xlabel('False Positive Rate')
    plt.ylabel('True Positive Rate')
    plt.title('Receiver Operating Characteristic Curve')
    plt.legend(loc="lower right")
    plt.show()

def plot_fpr_tpr(fpr, tpr, thresholds):
    '''
    Shows a plot of FPR and TPR against thresholds.
    '''
    plt.figure()
    plt.plot(thresholds, fpr, color='red', label='False Positive Rate')
    plt.plot(thresholds, tpr, color='blue', label='True Positive Rate')
    plt.xlim([0.0, 1.0])
    plt.ylim([0.0, 1.05])
    plt.xlabel('Thresholds')
    plt.legend(bbox_to_anchor=(0., 1.02, 1., .102), loc=3,
               ncol=2, mode="expand", borderaxespad=0.)
    plt.show()

def optimal_threshold(thresholds, fpr, tpr):
    '''
    Prints optimal threshold.
    '''
    value = (0, 0)
    for i in range(len(thresholds)):
        if thresholds[i] > 1:
            continue
        new_value = (np.sqrt((tpr[i])**2 + (1-fpr[i])**2), thresholds[i])
        if new_value[0] > value[0] and new_value[0] != 1.0:
            value = new_value
    print("\nThe optimal threshold for your data is: {:.2}.\n".format(value[1]))

def confusion_matrix(risk_assessments, threshold = .75, output=None, title=None):
    '''
    Shows a plot of the confusion matrix.
    '''
    pd.options.mode.chained_assignment = None
    if len(set(risk_assessments.crime_count.values)) > 2:
        risk_assessments['crime_count'] = np.where(risk_assessments['crime_count'] >= 1, 1, 0)
    if 'risk_binary' not in risk_assessments.columns:
        risk_assessments['risk_binary'] = np.where(risk_assessments['risk_assessment'] >= threshold, 1, 0)
    cnf_matrix = metrics.confusion_matrix(risk_assessments.crime_count, risk_assessments.risk_binary)
    # Needs to be rotated for some reason
    cnf_matrix = np.rot90(cnf_matrix, k=2)
    plt.figure()
    if not title:
        title = 'Normalized Confusion Matrix'
    plot_confusion_matrix(cnf_matrix, classes=['Crime', 'No Crime'], normalize=True,
                          title=title)
    if not output:
        plt.show()
    else:
        plt.savefig(output)
    pd.options.mode.chained_assignment = 'warn'

def plot_confusion_matrix(cm, classes, normalize=False,title='Confusion matrix',
    cmap=plt.cm.Blues):
    """
    This function prints and plots the confusion matrix.
    Normalization can be applied by setting `normalize=True`.
    Taken from scikitlearn documentation:
    http://scikit-learn.org/stable/auto_examples/model_selection/plot_confusion_matrix.html
    """
    if normalize:
        cm = cm.astype('float') / cm.sum(axis=1)[:, np.newaxis]
    plt.imshow(cm, interpolation='nearest', cmap=cmap)
    plt.title(title)
    tick_marks = np.arange(len(classes))
    plt.xticks(tick_marks, classes, rotation=45)
    plt.yticks(tick_marks, classes)

    thresh = cm.max() / 2.0
    for i, j in itertools.product(range(cm.shape[0]), range(cm.shape[1])):
        plt.text(j, i, cm[i, j],horizontalalignment="center",color="black" if cm[i, j] < thresh else "white")

    plt.tight_layout()
    plt.ylabel('True label')
    plt.xlabel('Predicted label')
    plt.colorbar()
    plt.clim(0,1)

def metrics_table(risk_assessments, name=None):
    '''
    Creates a metrics table with accuracy, TPR, TNR, FPR, FNR.
    '''
    pd.options.mode.chained_assignment = None
    risk_assessments['tp'] = np.where((risk_assessments.risk_binary==1) & (risk_assessments.crime_count==1), 1, 0)
    risk_assessments['tn'] = np.where((risk_assessments.risk_binary==0) & (risk_assessments.crime_count==0), 1, 0)
    risk_assessments['fp'] = np.where((risk_assessments.risk_binary==1) & (risk_assessments.crime_count==0), 1, 0)
    risk_assessments['fn'] = np.where((risk_assessments.risk_binary==0) & (risk_assessments.crime_count==1), 1, 0)
    sums = risk_assessments[['tp', 'tn', 'fp', 'fn']].sum()
    tp_sum = sums['tp']
    tn_sum = sums['tn']
    fp_sum = sums['fp']
    fn_sum = sums['fn']
    # Calculate Rates
    results = {}
    results['True Positive Rate'] = tp_sum/(tp_sum + fn_sum)
    results['True Negative Rate'] = tn_sum/(tn_sum + fp_sum)
    results['False Positive Rate '] = 1 - results['True Negative Rate']
    results['False Negative Rate'] = 1 - results['True Positive Rate']
    results['Accuracy'] = (tp_sum + tn_sum) / (len(risk_assessments))

    if not name:
        name = 'Value'

    pd.options.mode.chained_assignment = 'warn'

    return pd.DataFrame(results, index=[name])

def historical_prep(risk_assessments, historical):
    '''
    Prepares dataframes for historical analysis.
    '''
    risk_assessments['dt'] = pd.to_datetime(risk_assessments['dt'])
    pmin = risk_assessments['dt'].min()
    pmax = risk_assessments['dt'].max()
    if 'day' not in historical.columns:
        print("\nLooks like your historical dataset doesn't have days, so we'll look at months instead.")
    pred_months = risk_assessments.groupby(['census_tra', 'month', 'year'])
    historical['dt'] = historical['year'].map(str) + '-' + historical['month'].map(str) + '-01 00:00:00'
    historical['dt'] = pd.to_datetime(historical['dt'])
    hist_min = historical['dt'].min() + pd.DateOffset(years=3)
    hist_max = historical['dt'].max() + pd.DateOffset(years=1)
    if hist_min > hist_max:
        raise ValueError("\nInsufficient historical data; this system requires three years of historical data.")
    date_range = (pmin, pmax)
    drop_low = [hist_min, pmin]
    if hist_min != pmin:
        drop_low.sort()
        print("\nThe period from {} to {} will be left off the dataset because data are missing.".format(drop_low[0], drop_low[1]))
        drop_high = [hist_max, pmax]
    if hist_max != pmax:
        drop_high.sort()
        print("\nThe period from {} to {} will be left off the dataset because data are missing.".format(drop_high[0], drop_high[1]))

    date_range = [drop_low[1], drop_high[0]]
    risk_keep = (risk_assessments.dt >= date_range[0]) & (risk_assessments.dt <= date_range[1])
    historical = historical[(historical.dt >= date_range[0] - pd.DateOffset(years=3)) & (historical.dt <= date_range[1])]

    print("\nThe final overlapping period for analysis is: {} through {}".format(date_range[0], date_range[1]))

    return (risk_keep, risk_assessments, historical)

def get_paper_comparisons(risk_keep, risk_assessments, historical, show=True):
    '''
    Shows the graphs from the paper comparing historical averages to
    Crimescape model.
    '''
    # Pulls out actuals from risk scores df, performs group by for selected
    # periods
    pd.options.mode.chained_assignment = None
    actuals, new_pred, months = prepare_dfs(risk_assessments, historical)
    hist_merged = group_and_join(['month','census_tra'], months, actuals, HIST_CRIMES, ACT_CRIMES, mean_pred=False)
    pred_merged = group_and_join(['date','month','year','hournumber','census_tra'], new_pred[risk_keep], actuals, RISK_CRIMES, ACT_CRIMES, mean_pred=True)

    final_df = pd.DataFrame()
    rv_final = final_df

    extract_columns(hist_merged,HIST_CRIMES,ACT_CRIMES,final_df)
    extract_columns(pred_merged,RISK_CRIMES,ACT_CRIMES,final_df)

    if show:
        for i in range(len(ACT_CRIMES)):
            final_df['CrimeScape_dif_' + ACT_CRIMES[i]] = final_df[RISK_CRIMES[i]] - final_df[HIST_CRIMES[i]]
            make_graph(final_df[[HIST_CRIMES[i],RISK_CRIMES[i]]],'Model Comparison over Top X tracts','Cumulative number of prioritized census tracts','Total violent crimes in prioritized tracts',col_labels=['3 Year Avg. Based risk_assessments','CrimeScape risk_assessments'])
            make_graph(final_df[['CrimeScape_dif_' + ACT_CRIMES[i]]],'Difference Between CrimeScape & 3-Year risk_assessments','Cumulative number of prioritized census tracts','Difference in Violent Crimes in Predicted Tracts',col_labels=['CrimeScape risk_assessments less 3 Year Avg. Based risk_assessments'])

    pd.options.mode.chained_assignment = 'warn'

    return (hist_merged, pred_merged, rv_final)

def prepare_dfs(pred_df, hist_df):
    '''
    Does basic prep for running the COMPSTAT analysis.
    '''
    # Convert the census tract to an int
    pred_df.loc[:,['census_tra']] = pred_df.loc[:,['census_tra']].astype(int)

    # Pull in historical month (COMPSTAT)
    rename_dict = {}
    for x in hist_df.columns:
        if 'crime' in x and 'historical' not in x:
            rename_dict[x] = x + '_historical'
    hist_df.rename(columns=rename_dict,inplace=True)

    # Uses actuals from the CrimeScape risk scores
    actuals = pred_df.loc[:,['census_tra', 'dt', 'hournumber', 'crime_count', 'month',
     'day_of_week', 'date', 'year']]
    actuals.columns = ['census_tra', 'dt', 'hournumber', 'crime_count', 'month',
     'day_of_week', 'date', 'year']

    return (actuals, pred_df, hist_df)

def group_and_join(groupby, model_data, actuals, pred_sum_cols, act_sum_cols,
    mean_pred=True, ranks=True):
    '''
    Groups a df of risk scores (model_data) by groupby, taking either the mean
    or the sum of crimes, depending on mean_pred setting. Mean by default.

    Groups a df of actuals by the same groupby, but sums the number of crimes.

    Joins these two together, then creates ranks for geography based on
    historical crime levels if ranks = True (default is True).
    '''
    # Prep risk scores
    if mean_pred:
        model_grouped = model_data.groupby(by=groupby)[pred_sum_cols].mean()
    else:
        model_grouped = model_data.groupby(by=groupby)[pred_sum_cols].sum()
    # Prep actual crime levels
    actuals_grouped = actuals.groupby(by=groupby)[act_sum_cols].sum()
    #
    final = actuals_grouped.join(model_grouped,how='inner',lsuffix='_actuals')
    # Add ranks
    if ranks:
        ranked_titles = [col + '_ranked' for col in pred_sum_cols]
        levels = list(range(len(groupby)-1))
        final[ranked_titles] = final[pred_sum_cols].groupby(level=levels).rank(
        method='first',ascending=False)

    return final

def extract_columns(data_df, rank_cols, actuals, final_df):
    '''
    This function builds into final_df a new df, whose index is the
    rank for a geography, and whose columns are the number of predicted crimes
    for both the COMPSTAT and CivicScape methods. This is the table that was
    used to create the graphs in the white paper.
    '''
    for x in range(len(rank_cols)):
        rank_col = rank_cols[x] + '_ranked'
        act_col = actuals[x]
        small_df = data_df[[rank_col,act_col]].copy()
        colvals = small_df.groupby(by=[rank_col])[act_col].sum()
        final_df[rank_cols[x]] = colvals.cumsum()

def make_graph(sorted_cols,title,xlabel,ylabel,col_labels=[]):
    '''
    Makes cumulative graphs for historical comparison.
    '''
    if col_labels == []:
        col_labels = sorted_cols.columns.tolist()
    cols = []
    x = 0
    for col in sorted_cols.columns.tolist():
        col, = plt.plot(sorted_cols[col], label=col_labels[x])
        x += 1
        cols.append(col)

    plt.legend(handles=cols,bbox_to_anchor=(1.05, 1), loc=2, borderaxespad=0.)
    plt.title(title)
    plt.xlabel(xlabel)
    plt.ylabel(ylabel)
    plt.axhline(0,color='k')
    plt.show()

#######################################
##### RACIAL/INCOME BIAS SPECIFIC #####
#######################################

def get_census_data(census_econ_path, census_race_path, race_keep=None, econ_keep=None):
    '''
    Returns well formed datasets for census data. Can take different race_keep
    and econ_keep, but the columns should match any 2010 census file for these
    data.
    '''
    if not race_keep:
        race_keep = {'GEO.id2': 'geo_id', 'HD01_S076': 'race_total', 'HD02_S078': 'white_per', 'HD02_S079': 'black_per', 'HD02_S081': 'asian_per', 'HD02_S107': 'hisp_per'}
    if not econ_keep:
        econ_keep = {'GEO.id2': 'geo_id', 'HC01_EST_VC13': 'median_hh_income'}
    if race_keep == 2000:
        race_keep = {'GEO.id2': 'geo_id', 'HC01_VC28': 'race_total', 'HC02_VC29': 'white_per', 'HC02_VC30': 'black_per', 'HC02_VC32': 'asian_per', 'HC02_VC56': 'hisp_per'}
        econ_keep = {'GEO.id2': 'geo_id', 'HC01_VC64': 'median_hh_income'}

    econ = pd.read_csv(census_econ_path)
    race = pd.read_csv(census_race_path)
    econ = econ[list(econ_keep.keys())]
    race = race[list(race_keep.keys())]

    econ.drop(0, axis=0, inplace=True)
    econ.columns = list(econ_keep.values())
    race.drop(0, axis=0, inplace=True)
    race.columns = list(race_keep.values())

    econ['geo_id'] = econ.geo_id.str[-6:]
    race['geo_id'] = race.geo_id.str[-6:]
    econ.dropna(inplace=True)
    race.dropna(inplace=True)

    final = econ.join(race, rsuffix='_r')
    for col in final.columns:
        final.drop(final[final[col] == '(X)'].index, axis=0, inplace=True)

    # Get quintiles for white population percent
    final['white_per'] = final.white_per.astype('float64')
    final['white_per_q'] = pd.qcut(final.white_per, 5, labels=[1, 2, 3, 4, 5], retbins=False, precision=3)
    final['hisp_per'] = final.hisp_per.astype('float64')
    final['hisp_per_q'] = pd.qcut(final.hisp_per, 5, labels=[1, 2, 3, 4, 5], retbins=False, precision=3)
    final['black_per'] = final.black_per.astype('float64')
    final['black_per_q'] = pd.qcut(final.black_per, 5, labels=[1, 2, 3, 4, 5], retbins=False, precision=3)
    final['median_hh_income'] = final.median_hh_income.astype('float64')
    final['income_quintile'] = pd.qcut(final.median_hh_income, 5, labels=[1, 2, 3, 4, 5], retbins=False, precision=3)
    final['geo_id'] = final.geo_id.astype('int')

    return final

#######################################
#### DEPLOYMENT SPECIFIC FUNCTIONS ####
#######################################

def build_assumptions_dict(a, b, c, d, e, f, g, h):
    '''
    Returns assumptions as a dict.
    '''
    return {'threshold_for_Crimescape_assignment': a,
        'threshold_for_COMPSTAT_assignment': b,
        'CS_likelihood_patrol_stops_crime': c,
        'threshold_for_COMPSTAT_assignment': d,
        'COMP_likelihood_patrol_stops_crime': e,
        'additional_when_highrisk_tract': f,
        'percent_floating_patrol': g,
        'patrol_officers_for_shift': h
        }

def police_deployment_analysis(hist_merged, risk_merged, assumptions):
    '''
    Runs the polic deployment analysis.
    '''
    warnings.filterwarnings('ignore')

    hist_merged['risk_score'] = hist_merged.crime_count_historical/3
    hist_merged['crime_count_binary'] = np.where(hist_merged.crime_count
     >= 1, 1, 0)
    hist_merged['risk_binary'] = np.where(hist_merged.risk_score >=
     assumptions['threshold_for_COMPSTAT_assignment'], 1, 0)
    hist_merged.reset_index(inplace=True)
    risk_merged.reset_index(inplace=True)
    average_risk = risk_merged.groupby(['census_tra'], as_index=False)[
     'risk_assessment'].mean()
    sum_count = risk_merged.groupby(['census_tra'], as_index=False)[
     'crime_count'].sum()
    average_risk = average_risk.merge(sum_count, left_on='census_tra',
     right_on='census_tra', how='inner', suffixes=['', '_sum'])
    average_risk['risk_binary'] = np.where(average_risk.risk_assessment >=
     assumptions['threshold_for_Crimescape_assignment'], 1, 0)

    CS_tracts_at_risk = len(average_risk[average_risk.risk_binary == 1])
    COMP_tracts_at_risk = len(hist_merged[hist_merged.risk_binary == 1])
    CS_crime_occured_rate = len(average_risk[(average_risk.risk_binary == 1)
     & (average_risk.crime_count > 0)])/len(average_risk)
    COMP_crime_occured_rate = len(hist_merged[(hist_merged.risk_binary == 1)
     & (hist_merged.crime_count > 0)])/len(average_risk)
    CS_crimes_stopped = len(average_risk[(average_risk.risk_binary == 1)
     & (average_risk.crime_count > 0)]) * assumptions['CS_likelihood_patrol_stops_crime']
    COMP_crimes_stopped = len(hist_merged[(hist_merged.risk_binary == 1)
     & (hist_merged.crime_count > 0)]) * assumptions['COMP_likelihood_patrol_stops_crime']

    CS_addnl_officers = CS_tracts_at_risk * np.floor(assumptions['additional_when_highrisk_tract'])
    COMP_addnl_officers = COMP_tracts_at_risk * np.floor(assumptions['additional_when_highrisk_tract'])

    CS_overtime = 0
    COMP_overtime = 0
    CS_extra = 0
    COMP_extra = 0
    available = assumptions['percent_floating_patrol'] * assumptions['patrol_officers_for_shift']

    if available < CS_addnl_officers:
        CS_overtime = CS_addnl_officers - available
    else:
        CS_extra = available - CS_addnl_officers
    if available < COMP_addnl_officers:
        COMP_overtime = COMP_addnl_officers - available
    else:
        COMP_extra = available - COMP_addnl_officers

    print('\n\nCrimeScape tracts at risk: ', CS_tracts_at_risk)
    print('    Additional officers necessary: ', CS_addnl_officers)
    print('    Overtime officers: ', CS_overtime)
    print('    Extra officers: ', CS_extra)
    print('    Estimated crimes stopped: {:.2f}'.format(np.floor(CS_crimes_stopped)))
    print('\nCOMPSTAT tracts at risk: ', COMP_tracts_at_risk)
    print('    Additional officers necessary: ', COMP_addnl_officers)
    print('    Overtime officers: ', COMP_overtime)
    print('    Extra officers: ', COMP_extra)
    print('    Estimated crimes stopped: {:.2f}\n\n'.format(np.floor(COMP_crimes_stopped)))

    return (average_risk, hist_merged)

def map_average_risk(average_risk, ):
    '''
    Maps average risk.
    '''
    pass
