import pandas as pd
import os


def get_dp() -> str:
    """
    Returns the absolute path to the 'data' directory, which is located two levels above the directory containing the current file.

    :return: A string representing the absolute path to the 'data' directory.
    :rtype: str
    """
    fp = os.path.realpath(__file__)
    dp = os.path.join(os.path.dirname(os.path.dirname(fp)), 'data')
    # print(dp)
    return dp


def load_data(name: str) -> pd.DataFrame:
    """
    Load a data file based on the given name and return it as a pandas DataFrame.

    Parameters:
        name (str): The name of the data file to load. Valid names are 'icu_ibd'.

    Returns:
        pd.DataFrame: The loaded data as a pandas DataFrame.

    Raises:
        AssertionError: If the given name is not a valid data name.

    Example:
        >>> load_data('icu_ibd')
        icu_ibd_all_table.csv
    """
    mapping = {
        'icu_ibd': 'icu_ibd_all_table_revised.csv',
        'patients_ibd': 'patients_ibd.csv',
    }
    assert name in mapping, '{} is not a valid data name'.format(name)

    return pd.read_csv(os.path.join(get_dp(), mapping[name]))


def preprocess_icu_ibd(df: pd.DataFrame) -> pd.DataFrame:
    """
    Preprocesses the ICU-IBD data by performing the following steps:
    
    1. Converts the 'intime' column to datetime format.
    2. Loads the 'patients_ibd' data and converts the 'anchor_year' column to datetime format.
    3. Merges the ICU-IBD data with the 'patients_ibd' data based on the 'subject_id' column.
    4. Calculates the age in years by subtracting the 'anchor_year' from the 'intime' and converting the difference to days, then dividing by 365 and adding the original 'age' column.
    5. Removes unnecessary columns from the data.
    6. Parses the 'race' column and replaces it with standardized race categories.
    
    Parameters:
    - df (pd.DataFrame): The input ICU-IBD data.
    
    Returns:
    - pd.DataFrame: The preprocessed ICU-IBD data.
    """
    def parse_race(race: str) -> str:
        """
        Parse the race string and return a standardized race category based on the input string.

        Parameters:
        race (str): The input string containing race information.

        Returns:
        str: The standardized race category based on the input string.
        """
        assert type(race) == str, 'race must be a string, not {}'.format(
            type(race))

        if 'WHITE' in race:
            return 'WHITE'
        elif 'BLACK' in race:
            return 'BLACK'
        elif 'HISPANIC' in race or 'LATINO' in race:
            return 'HISPANIC/LATINO'
        elif 'ASIAN' in race:
            return 'ASIAN'
        else:
            return 'OTHER'

    df['intime'] = pd.to_datetime(df['intime'])

    df2 = load_data('patients_ibd')
    func = lambda x: pd.to_datetime('{}-01-01'.format(x))
    df2['anchor_year'] = df2['anchor_year'].apply(func)
    
    data = df.merge(df2[['subject_id', 'anchor_year']], on='subject_id', how='left')
    data['age'] = ((data['intime'] - data['anchor_year']).dt.days) / 365 + data['age']
    
    cols_except = [
        'hadm_id',
        'subject_id',
        'intime',
        'outtime',
        'mortality',
        'weight',
        'bmi',
        'systolic_pressure',
        'diastolic_pressure',
        'temperature',
        'white_blood_cell',
        'red_blood_cell',
        'CRP',
        'die_in_icu',
        'anchor_year',
        'uc_cd'
    ]

    cols_include = [col for col in data.columns if col not in cols_except]
    data = data[cols_include]
    data = data[ ~data[cols_include].isna().any(axis=1) ]
    
    data['race'] = data['race'].apply(parse_race)
    
    return data




if __name__ == '__main__':
    # fp = os.path.realpath(__file__)
    # dp = os.path.join(os.path.dirname(os.path.dirname(fp)), 'data')

    # icu_ibd = pd.read_csv(os.path.join(dp, 'icu_ibd_all_table.csv'))
    # icu_ibd = icu_ibd.dropna(subset=['race'])

    # icu_ibd['race'] = icu_ibd['race'].apply(parse_race)
    icu_ibd = preprocess_icu_ibd(load_data('icu_ibd'))
    print(icu_ibd.shape)
    # # df['race'] = df['race'].apply(parse_race)

    # print(icu_ibd['race'].value_counts())
