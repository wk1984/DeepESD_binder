# ===================================================================================
# Dockerfile to install R, Python, TensorFlow, Keras, and JupyterLab with an R Kernel
# ===================================================================================

# 1. Base Image
FROM rocker/r-ver:4.3.1

# ===================================================================================
# 2. System Dependencies
# ===================================================================================
USER root

RUN apt-get update && apt-get install -y --no-install-recommends \
    python3-pip \
    python3-venv \
    python3-dev \
    libpng-dev \
#   ^^^^^^^^^^^  <-- ADD THIS LINE to fix the error
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Create a virtual environment for Python packages
ENV VENV_PATH=/opt/venv
RUN python3 -m venv $VENV_PATH
ENV PATH="$VENV_PATH/bin:$PATH"

# Grant the default rstudio user permissions
RUN chown -R rstudio:rstudio $VENV_PATH

# ===================================================================================
# 3. Python Packages Installation
# ===================================================================================
RUN pip install --no-cache-dir --upgrade pip && \
    pip install --no-cache-dir \
    tensorflow==2.13.0 \
    jupyterlab

# ===================================================================================
# 4. R Packages Installation
# ===================================================================================
USER rstudio

# Set the RETICULATE_PYTHON environment variable
ENV RETICULATE_PYTHON=$VENV_PATH/bin/python

# Install the R packages from CRAN, including IRkernel
RUN R -e "install.packages(c('reticulate', 'tensorflow', 'keras', 'IRkernel'), repos = 'https://cloud.r-project.org/')"

# Register the R kernel with Jupyter
RUN R -e "IRkernel::installspec(user = FALSE)"

# ===================================================================================
# 5. Networking and Final Configuration
# ===================================================================================
USER root
EXPOSE 8888
USER rstudio
WORKDIR /home/rstudio

# Set the default command to launch JupyterLab
#CMD ["jupyter", "lab", "--ip=0.0.0.0", "--port=8888", "--no-browser", "--NotebookApp.token=''"]