# Downscaling Multi-Model Climate Projection Ensembles with Deep Learning (DeepESD): Contribution to CORDEX EUR-44
This repository contains the material and guidelines to reproduce the results presented in the manuscript entitled *Downscaling Multi-Model Climate Projection Ensembles with Deep Learning (DeepESD): Contribution to CORDEX EUR-44*, submitted to *Geoscientific Model Development* journal  (https://doi.org/10.5194/gmd-2022-57). Authors and corresponding ORCID can be found in the [zenodo.json](.zenodo.json) file.

**2022_Bano_DeepESD_GMD.ipynb** is a Jupyter notebook based on R containing the code necessary to replicate the results. 

**Dockerfile** contains the versions of the python and R libraries employed to reproduce the results of the manuscript. A conda environment with the appropriate versions.


**DOWNLOAD DEMO DATASETS**
> zenodo_get -r 17331040 -o ./data -g x_ERA-Interim.rds.gz
> 
> zenodo_get -r 17331040 -o ./data/pr -g y.rds.gz