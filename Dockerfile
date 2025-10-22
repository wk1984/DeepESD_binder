# ===================================================================================
# Dockerfile to install R, Python, TensorFlow, Keras, and JupyterLab with an R Kernel
# ===================================================================================

# 1. Base Image
FROM rocker/r-ver:4.5
#FROM rocker/r-ver:4.1.3-cuda11.1

# ===================================================================================
# 2. System Dependencies & Installations (as root)
# ===================================================================================
USER root

# Grant the rstudio user permissions for the venv AFTER all installations
RUN useradd -m -s /bin/bash rstudio && echo "rstudio:111" | chpasswd

RUN R -e "install.packages(c('reticulate', 'gridExtra' ,'ncdf4'), repos = 'http://cran.us.r-project.org')"
    
#RUN R -e "install.packages(c('reticulate', 'tensorflow', 'keras', 'gridExtra' ,'ncdf4'), repos = 'http://cran.us.r-project.org')"

# RUN R -e "library(tensorflow); install_tensorflow(version = "2.6")"

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