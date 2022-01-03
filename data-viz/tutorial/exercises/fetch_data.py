import glob
import os
import pandas as pd
import calendar
import datetime as dt
import requests
import zipfile

URL = "https://earthquake.usgs.gov/fdsnws/event/1/query.csv?starttime={start}&endtime={end}&minmagnitude=2.0&orderby=time"

data_path = '../../data'
def get_earthquake_data():
    earthquakes_parquet_file = f'{data_path}/earthquakes.parq'
    if os.path.isfile(earthquakes_parquet_file):
        print('Earthquakes dataset present, skipping download')
        return

    for yr in range(2000, 2002):
        for m in range(1, 13):
            if os.path.isfile('{yr}_{m}.csv'.format(yr=yr, m=m)):
                continue
            _, ed = calendar.monthrange(yr, m)
            start = dt.datetime(yr, m, 1)
            end = dt.datetime(yr, m, ed, 23, 59, 59)
            with open('{yr}_{m}.csv'.format(yr=yr, m=m), 'w', encoding='utf-8') as f:
                f.write(requests.get(URL.format(start=start, end=end)).content.decode('utf-8'))

    dfs = []
    for i in range(2000, 2002):
        for m in range(1, 13):
            if not os.path.isfile('%d_%d.csv' % (i, m)):
                continue
            try:
                df = pd.read_csv('%d_%d.csv' % (i, m), dtype={'nst': 'float64'})
                dfs.append(df)
            except:
                print('skipping: ' + '%d_%d.csv' % (i, m))


    # Get a list of all the file paths that ends with .csv from in specified directory
    fileList = glob.glob('*.csv')

    # Iterate over the list of filepaths & remove each file.
    for filePath in fileList:
        try:
            os.remove(filePath)
        except:
            print("Error while deleting file : ", filePath)
    df = pd.concat(dfs, sort=True)
    df.to_parquet(earthquakes_parquet_file, 'fastparquet')

def download_url(url, save_path, chunk_size=128):
    r = requests.get(url, stream=True)
    with open(save_path, 'wb') as fd:
        for chunk in r.iter_content(chunk_size=chunk_size):
            fd.write(chunk)

def get_population_data():
    fname = 'gpw_v4_population_density_rev11_2010_2pt5_min.zip'
    if os.path.isfile(f'{data_path}/{fname}'):
        print('Population dataset present, skipping download')
        return
    download_url(f'https://earth-data.s3.amazonaws.com/{fname}', fname)
    with zipfile.ZipFile(fname, 'r') as zip_ref:
        zip_ref.extractall(data_path)
    os.remove(fname)
