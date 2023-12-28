import os
import matplotlib as mpl
import matplotlib.pyplot as plt
import platform
import numpy as np

from dotenv import load_dotenv


'''
    加载环境变量
'''
def get_parent_dir(depth=2) -> str:
    parent_dir = os.path.dirname(os.path.abspath(__file__))
    for _ in range(depth):
        parent_dir = os.path.dirname(parent_dir)
        
    return parent_dir


def load_env_file(root_dir=get_parent_dir()) -> None:
    print('load env file')
    print('  root dir:\n    {}'.format(root_dir))
    mapping_list = {
        'Darwin': '.env.darwin',
        'Windows': '.env.windows',
        'Linux': '.env.linux',
    }
    print('  current system:\n    {}'.format(platform.system()))
    
    if platform.system() not in mapping_list:
        print('  loaded env file:\n    {}'.format('.env'))
        load_dotenv(os.path.join(root_dir, '.env'))
    else:
        print('  loaded env file:\n    {}'.format(mapping_list[platform.system()]))
        load_dotenv(os.path.join(root_dir, mapping_list[platform.system()]))
    
    print('  loaded data dir:\n    {}'.format(os.getenv('DATA_DIR')))
    print('done.')
    
    return os.getenv('DATA_DIR')


'''
    配置 matplotlib
'''
def set_mpl_configs() -> None:
    print('set matplotlib configs')
    mpl.rcParams['font.family'] = 'Times New Roman'
    print('  font family:\n    {}'.format(mpl.rcParams['font.family']))
    print('done.')


    
if __name__ == '__main__':
    load_env_file()