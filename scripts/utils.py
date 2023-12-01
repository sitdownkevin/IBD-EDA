import os
import matplotlib as mpl
import matplotlib.pyplot as plt
import platform
import numpy as np

from dotenv import load_dotenv

def set_mpl_configs() -> None:
    print('set matplotlib configs')
    mpl.rcParams['font.family'] = 'Times New Roman'
    print('  font family:\n    {}'.format(mpl.rcParams['font.family']))
    print('done.')


def load_env_file(root_dir=os.path.dirname(os.path.dirname(os.path.abspath(__file__)))): # load env variables
    print('load env file')
    print('  root dir:\n    {}'.format(root_dir))
    mapping_list = {
        'Darwin': '.env.darwin',
        'Windows': '.env.windows',
        'Linux': '.env.linux'
    }
    print('  current system:\n    {}'.format(platform.system()))
    if platform.system() not in mapping_list:
        print('  load {}'.format('.env'))
        load_dotenv(os.path.join(root_dir, '.env'))
    else:
        print('  load {}'.format(mapping_list[platform.system()]))
        load_dotenv(os.path.join(root_dir, mapping_list[platform.system()]))
    print('  loaded data dir:\n    {}'.format(os.getenv('DATA_DIR')))
    
    print('done.')


def leave_percentile(data: np.ndarray) -> np.ndarray:
    Q1 = np.percentile(data, 25)
    Q3 = np.percentile(data, 75)
    IQR = Q3 - Q1

    return  data[(data >= Q1 - 1.5 * IQR) & (data <= Q3 + 1.5 * IQR)]


def distribution_analysis(_data: np.ndarray, _bins=200, **kwargs) -> (np.ndarray, np.ndarray):
    if kwargs.get('do'):
        _data = leave_percentile(_data)
        
    data_mean = np.mean(_data)
    hist, bins = np.histogram(_data, bins=_bins)
    plt.figure(figsize=(16, 9), dpi=300)
    plt.bar(bins[:-1], hist / len(_data), width=np.diff(bins), color='lightskyblue', label='{}'.format(kwargs.get('label', '')))
    plt.axvline(data_mean, color='r', linestyle='--', linewidth=2, label='{}'.format(kwargs.get('vlinelabel', 'Mean')))
    plt.xlabel('{}'.format(kwargs.get('xlabel', '')))
    plt.ylabel('{}'.format(kwargs.get('ylabel', '')))
    plt.xlim(0, )
    plt.legend()
    plt.show()
    
    return (hist, bins)

if __name__ == '__main__':
    current_dir = os.path.dirname(os.path.abspath(__file__))
    root_dir = os.path.dirname(current_dir)
    load_env_file(root_dir)