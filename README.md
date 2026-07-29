
# Altimetry Water Level Data Management Tool

[![Made by Hilda Vörös](https://img.shields.io/badge/Made%20by-Hilda_Vörös-blue)](https://aaugeodesy.com/hilda-voros/)

> :warning: Please read the [Wiki of this tool](https://github.com/AAUGeodesyGroup/AltimetryWaterLevelDMT/wiki) on GitHub to understand how to use the materials, that are provided.

## License and citation

The framework is licensed under a
[Creative Commons Attribution 4.0 International License][cc-by].
[![CC BY 4.0][cc-by-image]][cc-by]

This tool should be cited as:

* Vörös, H., 2026. AltimetryWaterLevelDMT. [https://doi.org/10.6084/m9.figshare.32452485)](https://doi.org/10.6084/m9.figshare.32452485)

The following scripts in this tool are based on the following sources: 
- The script given in Download_CLMS_data.py is based on the codes given by William Ray in [GitHubGist](https://gist.github.com/willrayeo/8aa424384f272d3003a2dea6460cb07b#file-keychain_credentials-py)
- The script given in Download_Dahiti_data.py is based on the codes given by Christian Schwatke in the [Dahiti website](https://dahiti.dgfi.tum.de/en/api/doc/v2/download-water-level/)
- The script given in Download_Hydroweb_data.py is using the python package [Py Hydroweb](https://pypi.org/project/py-hydroweb/)

> :warning: The used datasets downloaded from websites should also be cited. Please read the [Wiki of this tool](https://github.com/AAUGeodesyGroup/AltimetryWaterLevelDMT/wiki) on GitHub to find information about how to make citation to the different types of datasets.

## Funding

We acknowledge the support of the Independent Research Fund Denmark (DFF) through the DFF1-Green thematic research project entitled “Space-based Free Flood Awareness System for Africa (SFAS),” Grant No. 10.46540/4307-00146B

## Description
The **Altimetry Water Level Data Management Tool** is created to facilitate the easy downloading, filtering, mapping, and plotting of river altimetry data from the processing centres CLMS, Dahiti, and Hydroweb.

**This tool is capable of downloading and processing the following data from the processing centres:**
- CLMS: [River Water Level 2002-present (vector), global, Near Real Time – version 2](https://land.copernicus.eu/en/products/water-bodies/water-level-rivers-near-real-time-v2.0#download)
- Dahiti: [Water Level Time Series from Satellite Altimetry](https://dahiti.dgfi.tum.de/en/products/water-level-altimetry/)
- Hydroweb: [Theia Hydroweb Operational Altimetry River Water Level (ID: HYDROWEB_RIVERS_OPE)](https://hydroweb.next.theia-land.fr/)

## Capabilities of this tool

The use of the **Altimetry Water Level Data Management Tool** produces various results. A sample of results for Niger basin are presented in the image.

![teaser](https://github.com/user-attachments/assets/809146a5-0406-47c3-9a10-972a9ff74429)


The virtual stations from processing centres are handled in this tool as follows:
- Filtering
  - First filter with requirements about **percentage of temporal coverage** and **number of maximum days of allowed gaps**.
  - Second filter is based on the selected stations from first filter and the specified **time period**.
- Least squares method (LSM)
  - Linear trend, Annual amplitude, Semiannual amplitude.
- Mapping of filtered virtual stations
  - Gives an overview of where virtual stations are located.
- Geospatial and timeseries comparison
  - Triple match and double match to compare altimetry data from each virtual station
  - Gwm lakes and HydroLAKES to compare the location to virtual stations


[cc-by]: http://creativecommons.org/licenses/by/4.0/
[cc-by-image]: https://i.creativecommons.org/l/by/4.0/88x31.png
[cc-by-shield]: https://img.shields.io/badge/License-CC%20BY%204.0-lightgrey.svg



