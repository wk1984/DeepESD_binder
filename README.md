# Downscaling Multi-Model Climate Projection Ensembles with Deep Learning (DeepESD): Contribution to CORDEX EUR-44
This repository contains the material and guidelines to reproduce the results presented in the manuscript entitled *Downscaling Multi-Model Climate Projection Ensembles with Deep Learning (DeepESD): Contribution to CORDEX EUR-44*, submitted to *Geoscientific Model Development* journal  (https://doi.org/10.5194/gmd-2022-57). Authors and corresponding ORCID can be found in the [zenodo.json](.zenodo.json) file.

**2022_Bano_DeepESD_GMD.ipynb** is a Jupyter notebook based on R containing the code necessary to replicate the results. 

**Dockerfile** contains the versions of the python and R libraries employed to reproduce the results of the manuscript. A conda environment with the appropriate versions.

**binder** https://mybinder.org/v2/gh/wk1984/DeepESD_binder/HEAD


**DOWNLOAD DEMO DATASETS**
> zenodo_get -r 17331040 -o ./data -g x_ERA-Interim.rds.gz
> 
> zenodo_get -r 17331040 -o ./data/pr -g y.rds.gz

** FOR WINDOWS ... STILL TESTING **

  # conda deactivate
  # conda env remove -n deep-esd
  # conda create -n deep-esd python==3.9 r-base==3.6.3 tensorflow==2.6.0 jupyterlab==4.4.6 r-irkernel r-tensorflow r-loader==1.7.1 r-transformer==2.1.0 r-downscaler==3.3.2 r-downscaler.keras==1.0.0 r-visualizer==1.6.0 r-climate4r.value==0.0.2 r-climate4r.udg==0.2.4 r-loader.2nc==0.1.1 r-devtools -c conda-forge -c r -c santandermetgroup -c nvidia
