import os
import matplotlib.pyplot as plt
import numpy as np


def drop_outliers(data: np.ndarray) -> np.ndarray:
    Q1 = np.percentile(data, 25)
    Q3 = np.percentile(data, 75)
    IQR = Q3 - Q1

    return  data[(data >= Q1 - 1.5 * IQR) & (data <= Q3 + 1.5 * IQR)]


def plot_distribution(data: np.ndarray, 
                          bins_nums: int, 
                          del_outliers: bool = False,
                          **kwargs) -> (np.ndarray, np.ndarray):
    if del_outliers:
        data = drop_outliers(data)
    data_mean = np.mean(data)
    
    hist, bins = np.histogram(data, bins=bins_nums)
    
    plt.figure(figsize=(16, 9), dpi=300)
    plt.bar(bins[:-1], 
            hist / len(data), 
            width=np.diff(bins), 
            color='lightskyblue', 
            label='{}'.format(kwargs.get('label', '')))
    plt.axvline(data_mean, 
                color='r', 
                linestyle='--', 
                linewidth=2, 
                label='{}'.format(kwargs.get('vlinelabel', 'Mean')))
    plt.xlabel('{}'.format(kwargs.get('xlabel', '')))
    plt.ylabel('{}'.format(kwargs.get('ylabel', '')))
    plt.xlim(0, )
    plt.legend()
    plt.show()
    
    return (hist, bins)


if __name__ == '__main__':
    data = np.random.normal(loc=100, scale=10, size=1000)
    hist, bins = plot_distribution(data, 200, True)