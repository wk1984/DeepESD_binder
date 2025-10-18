# ===================================================================================
# Dockerfile to install R, Python, TensorFlow, Keras, and JupyterLab with an R Kernel
# ===================================================================================

# 1. Base Image
FROM rocker/r-ver:4.3.1

# ===================================================================================
# 2. System Dependencies & Installations (as root)
# ===================================================================================
USER root

# Install system libraries
RUN apt-get update && apt-get install -y --no-install-recommends \
    python3-pip \
    python3-venv \
    python3-dev \
    libpng-dev \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Create and configure Python virtual environment
ENV VENV_PATH=/opt/venv
RUN python3 -m venv $VENV_PATH
ENV PATH="$VENV_PATH/bin:$PATH"

# Install Python packages
RUN pip install --no-cache-dir --upgrade pip && \
    pip install --no-cache-dir \
    tensorflow==2.13.0 \
    jupyterlab

# --- THIS IS THE KEY CHANGE ---
# Install R packages system-wide as root
RUN R -e "install.packages(c('reticulate', 'tensorflow', 'keras', 'IRkernel'), repos = 'https://cloud.r-project.org/')"

# Register the R kernel with Jupyter system-wide
RUN R -e "IRkernel::installspec(user = FALSE)"

# Grant the rstudio user permissions for the venv AFTER all installations
RUN chown -R rstudio:rstudio $VENV_PATH

# ===================================================================================
# 5. Final User Configuration and Runtime Command
# ===================================================================================
# Now, switch to the non-root user for the runtime environment
USER rstudio
WORKDIR /home/rstudio

# Set the RETICULATE_PYTHON environment variable for the user
ENV RETICULATE_PYTHON=$VENV_PATH/bin/python

# Expose the port (can be done as root, but placement here is fine)
EXPOSE 8888

# Set the default command to be run as the rstudio user
CMD ["jupyter", "lab", "--ip=0.0.0.0", "--port=8888", "--no-browser", "--NotebookApp.token=''"]