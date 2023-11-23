import pandas as pd


def who_get_this_disease(_df: pd.DataFrame, _icd_code: str) -> list:
    _df = _df[_df['icd_code'] == _icd_code]
    _stats = _df.groupby(['subject_id']).agg({
        'gender': ['first'],
    }) # make sure unique

    return list(_stats.index)


def who_not_get_this_disease(_df, _icd_code) -> list:
    patients_get_this_disease = who_get_this_disease(_df, _icd_code)
    patients_not_get_this_disease = list(set(_df['subject_id'].unique()) - set(patients_get_this_disease))
    return patients_not_get_this_disease

    
def query_by_subject_id(_df: pd.DataFrame, _subject_id: int) -> pd.DataFrame:
    _df = _df[_df['subject_id'] == _subject_id]
    return _df


def batch_query_by_subject_id(_df: pd.DataFrame, _subject_ids: list) -> pd.DataFrame:
    _df = _df[_df['subject_id'].isin(_subject_ids)]
    return _df