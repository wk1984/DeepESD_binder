# ==============================================================================
# Dockerfile to install compatible versions of R, Python, TensorFlow, and Keras
# ==============================================================================

# 1. Base Image
# Using a specific version of rocker/r-ver for reproducibility.
FROM rocker/r-ver:4.1.3-cuda11.1

# ==============================================================================
# 2. System Dependencies
# Install Python, pip, and create a virtual environment.
# ==============================================================================
# Switch to root to install system packages
USER root

RUN apt-get update && apt-get install -y --no-install-recommends \
    python3-pip \
    python3-venv \
    python3-dev \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Create a virtual environment for Python packages to avoid system conflicts
ENV VENV_PATH=/opt/venv
RUN python3 -m venv $VENV_PATH
ENV PATH="$VENV_PATH/bin:$PATH"

# Grant the default rstudio user permissions to use the virtual environment

RUN useradd -m -s /bin/bash rstudio && echo "rstudio:111" | chpasswd

RUN chown -R rstudio:rstudio $VENV_PATH

# ==============================================================================
# 3. Python Packages Installation
# Install specific versions of TensorFlow.
# Keras is now integrated into TensorFlow (tf.keras).
# ==============================================================================
RUN pip install --no-cache-dir --upgrade pip && \
    pip install --no-cache-dir \
    tensorflow==2.13.0

# ==============================================================================
# 4. R Packages Installation
# Switch back to the default non-root user 'rstudio'
# ==============================================================================
# Set the RETICULATE_PYTHON environment variable.
# This is crucial for the R 'reticulate' package to find the correct Python installation.
ENV RETICULATE_PYTHON=$VENV_PATH/bin/python

# Install the R packages from CRAN
RUN R -e "install.packages(c('reticulate', 'tensorflow', 'keras'), repos = 'https://cloud.r-project.org/')"

# ==============================================================================
# 5. Verification
# Run some R commands to ensure that TensorFlow and Keras are correctly configured.
# ==============================================================================
RUN R -e "library(tensorflow); cat('Python configuration used by R:\\n'); reticulate::py_config()"
RUN R -e "library(tensorflow); cat('\\nTensorFlow version detected by R:\\n'); print(tf_config())"
RUN R -e "library(keras); cat('\\nIs Keras available to R?:', is_keras_available(), '\\n')"
RUN R -e "library(tensorflow); cat('\\nPython TensorFlow module version:', tf$`__version__`, '\\n')"

# ==============================================================================
# 6. Set Default Command (Optional)
# ==============================================================================
USER rstudio
WORKDIR /home/rstudio
CMD ["/bin/bash"]