# Functions to support data checks notebook

import __future__
import pandas as pd
import numpy as np

def import_data(path, expected_columns, expected_types):
    '''
    Pulls data in and runs sanity checks for column presence and type.

    Performs date-time transformations.
    '''
    data = pd.read_csv(path)
    missing = []
    typealert = []
    for x in expected_columns:
        if x not in data.columns:
            missing.append(x)
        if data[x].dtype != expected_types[x]:
            typealert.append(x)
    if len(missing) != 0:
        print("\nCOLUMN MISMATCH WARNING:\n")
        print("\nData are missing these expected columns: {}.".format(warn))
    if len(typealert) != 0:
        print("\nTYPE MISMATCH WARNING:\n")
        for y in typealert:
            print("Data are unexpected format: {} is '{}' expected '{}'.\n".format(y, data[y].dtype, expected_types[y]))

    data['dt'] = pd.to_datetime(data.loc[:,'date'] + ' ' + data.loc[:,'time'])
    data['year'] = data.loc[:,'dt'].dt.year
    data['month'] = data.loc[:,'dt'].dt.month
    data['day_of_week'] = data.loc[:,'dt'].dt.dayofweek
    data['hour'] = data.loc[:,'dt'].dt.hour
    data['minute'] = data.loc[:,'dt'].dt.minute
    print("Your date range is: {} to {}.".format(data.dt.min(), data.dt.max()))

    return data

def constrict_times(data, hours=(), days=[], date_range=()):
    '''
    Allows user to contrict the analysis to a particular hour, date, or date_range.
    '''
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
        data = data[data['hour'].isin(hours)]
        print("\nYou've restricted the data to the following hours:")
        print("    {}:00 until {}:00".format(low, high))

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
        data = data[data['day_of_week'].isin(days_trans)]
        print("\nYou've restricted the data to the following days:")
        print("    {}".format(days))

    if date_range != ():
        low = pd.to_datetime(date_range[0])
        high = pd.to_datetime(date_range[1])
        if high > data.dt.max():
            high = data.dt.max()
            print("\nYou've entered a date past the end of your dataset.")
        if low < data.dt.min():
            low = data.dt.min()
            print("\nYou've entered a date earlier than the beginning of your dataset.")
        # Cut data by membership
        data = data[(data.dt >= low) & (data.dt <= high)]
        # Make sure historical.dt is in datetime; cut to match (3-year history)

    return data
