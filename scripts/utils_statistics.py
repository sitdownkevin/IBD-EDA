import numpy as np

from scipy.stats import chi2_contingency, fisher_exact
from utils_complications import who_get_this_disease, who_not_get_this_disease


def construct_chi2_test(pos_df, neg_df, icd_code, silent=False) -> float:
    '''
              get  not_get
        pos   a    b
        neg   c    d
    '''
    a = len(who_get_this_disease(pos_df, icd_code))
    b = len(who_not_get_this_disease(pos_df, icd_code))
    c = len(who_get_this_disease(neg_df, icd_code))
    d = len(who_not_get_this_disease(neg_df, icd_code))
    
    observed = np.array([[a, b], [c, d]])    
    chi2, pvalue, dof, expected = chi2_contingency(observed)
    
    if not silent:
        print('start chi2 test')
        print('  observed:\n    {:.4f}    {:.4f}\n    {:.4f}    {:.4f}'.format(observed[0, 0], observed[0, 1], observed[1, 0], observed[1, 1]))
        print('  expected:\n    {:.4f}    {:.4f}\n    {:.4f}    {:.4f}'.format(expected[0, 0], expected[0, 1], expected[1, 0], expected[1, 1]))
        print('  chi2: {:.4f}'.format(chi2))
        print('  pvalue: {:.4f}'.format(pvalue))
        print('  dof: {:.4f}'.format(dof))
        print('done.')
    
    return pvalue
    
    
def construct_fisher_test(pos_df, neg_df, icd_code, silent=False) -> float:
    '''
              get  not_get
        pos   a    b
        neg   c    d
    '''
    a = len(who_get_this_disease(pos_df, icd_code))
    b = len(who_not_get_this_disease(pos_df, icd_code))
    c = len(who_get_this_disease(neg_df, icd_code))
    d = len(who_not_get_this_disease(neg_df, icd_code))
    
    observed = np.array([[a, b], [c, d]])
    oddsratio, pvalue = fisher_exact(observed)
    
    if not silent:
        print('start fisher test')
        print('  observed:\n    {:.4f}    {:.4f}\n    {:.4f}    {:.4f}'.format(observed[0, 0], observed[0, 1], observed[1, 0], observed[1, 1]))
        print('  oddsratio: {:.4f}'.format(oddsratio))
        print('  pvalue: {:.4f}'.format(pvalue))
        print('done.')
    
    return pvalue