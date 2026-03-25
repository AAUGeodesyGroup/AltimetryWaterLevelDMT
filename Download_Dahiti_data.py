# Downloading Dahiti data

''' Modified version '''

''' Author: Christian Schwatke <christian.schwatke@tum.de>'''

''' Last change: 2025-10-30 '''

 

import os

import sys

import json

import pprint

import requests

import datetime

 

''' Download path were all water level time series will be stored '''

download_path = 'downloads/'

if not os.path.isdir(download_path):

    os.mkdir(download_path)

 

API_KEY = ' ' # insert API key here

OUTPUT_FORMAT = 'netcdf'

#~ OUTPUT_FORMAT = 'json'

#~ OUTPUT_FORMAT = 'netcdf'

#~ OUTPUT_FORMAT = 'csv'

 

url = 'https://dahiti.dgfi.tum.de/api/v2/list-targets/'

args = {}

''' User configuration '''

args['api_key'] = API_KEY

''' Search options '''

# args['basin'] = 'Niger'

# args['continent'] = 'Asia'

# args['country'] = 'de'


# ---- Niger -----------
args['min_lon'] = -15
args['max_lon'] = 15
args['min_lat'] = 2
args['max_lat'] = 20
 

''' send request as method POST '''

response = requests.post(url, data=args)

if response.status_code == 200:

    ''' convert json string in python list '''

    targets = json.loads(response.text)['data']

    # Exclude targets for which no water level data is available (to minimize the amount of requests).
    for i in range(len(targets)-1,-1,-1):
        target = targets[i]
        if target['data_access']['water_level_altimetry']!='public':
            targets.pop(i)

    print ('Dataset(s) found:',len(targets))        

 

    for target in targets[1:]:

               

        print (target)      

 

        ''' download water level time series '''

        url = 'https://dahiti.dgfi.tum.de/api/v2/download-water-level/'

        args = {}

        args['api_key'] = API_KEY

        args['dahiti_id'] = target['dahiti_id']

        args['format'] = OUTPUT_FORMAT

       

        if args['format'] == "ascii":

            path_output = os.path.abspath(download_path+'/'+str(target['dahiti_id'])+'.txt')

        elif args['format'] == "json":

            path_output = os.path.abspath(download_path+'/'+str(target['dahiti_id'])+'.json')

        elif args['format'] == "netcdf":

            path_output = os.path.abspath(download_path+'/'+str(target['dahiti_id'])+'.nc')

        elif args['format'] == "csv":

            path_output = os.path.abspath(download_path+'/'+str(target['dahiti_id'])+'.csv')

        else:

            print ('Invalid format `'+format+'`')

            sys.exit(0)

 

        print ('Downloading ... ',target['dahiti_id'],'->',target['target_name'].encode("utf8"),'('+path_output+')')

       

        response_download = requests.post(url, json=args)

        if response_download.status_code == 200:

            if args['format'] == "ascii":

                data_ascii = response_download.text

                output = open(path_output,'w')

                output.write(data_ascii)

                output.close()

            if args['format'] == "json":

                data_json = response_download.text

                output = open(path_output,'w')

                output.write(data_json)

                output.close()

            if args['format'] == "netcdf":              

                with open(path_output, 'wb') as f:

                    for chunk in response_download.iter_content(chunk_size=1024):

                        if chunk:

                            f.write(chunk)

            if args['format'] == "csv":

                data_csv = response_download.text

                output = open(path_output,'w')

                output.write(data_csv)

                output.close()                      

        else:

            print ('Error: `download-water-level` request failed!')

            data = json.loads(response_download.text)

            pprint.pprint(data)

            #sys.exit(0)s

else:

    print ('Error: `list-targets` request failed!')

    data = json.loads(response.text)

    pprint.pprint(data)

 