# ===================================================================================
# Dockerfile to install R, Python, TensorFlow, Keras, and JupyterLab with an R Kernel
# ===================================================================================

# 1. Base Image
#FROM rocker/r-ver:4.5
#FROM rocker/r-ver:4.1.3-cuda11.1

FROM tensorflow/tensorflow:2.10.1-gpu-jupyter

# sudo apt-key del 7fa2af80
# sudo apt-key adv --fetch-keys https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2004/x86_64/3bf863cc.pub
# sudo apt-key adv --fetch-keys https://developer.download.nvidia.com/compute/machine-learning/repos/ubuntu2004/x86_64/7fa2af80.pub

# ===================================================================================
# 2. System Dependencies & Installations (as root)
# ===================================================================================
USER root

# Grant the rstudio user permissions for the venv AFTER all installations
RUN useradd -m -s /bin/bash rstudio && echo "rstudio:111" | chpasswd

RUN apt-get update && apt-get install -y --no-install-recommends \
    libpng-dev git libnetcdf-dev wget  \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*
    
RUN conda update -n base conda && \
    conda install -c conda-forge -c r r-reticulate r-tensorflow r-keras -y

RUN conda install -c conda-forge -c r r-loader r-loader.2nc r-transformer r-downscaler r-visualizer r-downscaler.keras r-climate4r.value r-climate4r.udg r-value r-loader.java -y

# RUN R -e "library(reticulate)"

RUN which R

#RUN R -e "install.packages(c('reticulate', 'gridExtra' ,'ncdf4'), repos = 'http://cran.us.r-project.org')"
    
#RUN R -e "install.packages(c('tensorflow', 'keras'), repos = 'http://cran.us.r-project.org')"

# RUN R -e "library(reticulate); reticulate::virtualenv_create('r-reticulate')"

# RUN R -e "library(reticulate); install_miniconda()" 

#; conda_create('r-reticulate')"

#RUN R -e "library(tensorflow); install_tensorflow(envname = 'r-reticulate', version = '2.6')"

# ===================================================================================
# 5. Final User Configuration and Runtime Command
# ===================================================================================
# Now, switch to the non-root user for the runtime environment
USER rstudio
WORKDIR /home/rstudio

# Expose the port (can be done as root, but placement here is fine)
EXPOSE 8888

# Set the default command to be run as the rstudio user
#CMD ["jupyter", "lab", "--ip=0.0.0.0", "--port=8888", "--no-browser", "--NotebookApp.token=''"]