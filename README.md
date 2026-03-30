
# Altimetry Water Level Data Management Tool

[![Made by Hilda Vörös](https://img.shields.io/badge/Made%20by-Hilda_Vörös-blue)](https://aaugeodesy.com/hilda-voros/)

> :warning: Please read the Wiki on GitHub to understand how to use the materials
 
## Description
The **Altimetry Water Level Data Management Tool** is created to facilitate the easy downloading, filtering, mapping, and plotting of river altimetry data from the processing centres CLMS, Dahiti, and Hydroweb.

**This tool is capable of downloading and processing the following data from the processing centres:**
- CLMS: [River Water Level 2002-present (vector), global, Near Real Time – version 2](https://land.copernicus.eu/en/products/water-bodies/water-level-rivers-near-real-time-v2.0#download)
- Dahiti: [Water Level Time Series from Satellite Altimetry](https://dahiti.dgfi.tum.de/en/products/water-level-altimetry/)
- Hydroweb: [Theia Hydroweb Operational Altimetry River Water Level (ID: HYDROWEB_RIVERS_OPE)](https://hydroweb.next.theia-land.fr/)

## References
The script given in Download_CLMS_data.py is based on the codes given by William Ray in [GitHubGist](https://gist.github.com/willrayeo/8aa424384f272d3003a2dea6460cb07b#file-keychain_credentials-py)

The script given in Download_Dahiti_data.py is based on the codes given by Christian Schwatke in the [Dahiti website](https://dahiti.dgfi.tum.de/en/api/doc/v2/download-water-level/)

The script given in Download_Hydroweb_data.py is using the python package [Py Hydroweb](https://pypi.org/project/py-hydroweb/)


## Capabilities of this tool

The use of the **Altimetry Water Level Data Management Tool** produces various results. A sample of results for Niger basin are presented in the image.

![teaser](https://github.com/user-attachments/assets/4e470725-176f-447f-890c-3ee50b343d4e)

The virtual stations from processing centres are handled in this tool as follows:
- Filtering
- Least squares method (LSM)
- Mapping of filtered virtual stations
- Geospatial and timeseries comparison



