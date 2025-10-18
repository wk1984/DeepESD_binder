# ===================================================================================
# Dockerfile to install R, Python, TensorFlow, Keras, and JupyterLab with an R Kernel
# ===================================================================================

# 1. Base Image
#FROM rocker/r-ver:4.5
FROM rocker/r-ver:4.1.3-cuda11.1

# ===================================================================================
# 2. System Dependencies & Installations (as root)
# ===================================================================================
USER root

# Grant the rstudio user permissions for the venv AFTER all installations
RUN useradd -m -s /bin/bash rstudio && echo "rstudio:111" | chpasswd

# Install system libraries
RUN apt-get update && apt-get install -y --no-install-recommends \
    libpng-dev git \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

#ARG MINICONDA_URL="https://github.com/conda-forge/miniforge/releases/download/25.3.1-0/Miniforge3-25.3.1-0-Linux-x86_64.sh"
#ARG MINICONDA_URL="https://github.com/conda-forge/miniforge/releases/download/4.14.0-2/Mambaforge-4.14.0-2-Linux-x86_64.sh"
ARG MINICONDA_URL="https://mirrors.tuna.tsinghua.edu.cn/anaconda/miniconda/Miniconda3-py39_25.7.0-2-Linux-x86_64.sh"
ENV CONDA_DIR=/opt/conda
# 将 Conda 的可执行文件路径添加到系统 PATH 中
ENV PATH=${CONDA_DIR}/bin:${PATH}

# ==================================================================
# 3. 安装系统依赖并下载安装 Miniconda
# ==================================================================
RUN apt-get update && \
    # 安装构建和下载所需的软件包
    apt-get install -y --no-install-recommends \
        wget \
        ca-certificates \
        bzip2 && \
    # 下载指定的 Miniconda 安装脚本
    wget --quiet ${MINICONDA_URL} -O ~/miniconda.sh && \
    # 以批处理模式(-b)将 Miniconda 安装到指定路径(-p)
    /bin/bash ~/miniconda.sh -b -p ${CONDA_DIR} && \
    # 删除安装脚本
    rm ~/miniconda.sh && \
    # 初始化 Conda，使其能够在 shell 中使用
    conda init bash && \
    # 清理 apt 缓存，减小镜像体积
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*
    
RUN chown -R rstudio:rstudio $CONDA_DIR

RUN conda tos accept --override-channels --channel https://repo.anaconda.com/pkgs/main
RUN conda tos accept --override-channels --channel https://repo.anaconda.com/pkgs/r

RUN conda install -c conda-forge tensorflow==2.15.0 keras==2.15.0

RUN conda install -c conda-forge -c r -c santandermetgroup r-loader r-loader.2nc r-transformer r-downscaler r-visualizer r-downscaler.keras r-climate4r.value r-climate4r.udg r-value r-loader.java r-tensorflow==2.15.0 r-keras==2.15.0
    
RUN pip install jupyterlab
    
# --- THIS IS THE KEY CHANGE ---
# Install R packages system-wide as root
RUN R -e "install.packages(c('reticulate', 'IRkernel'), repos = 'https://cloud.r-project.org/')"

# Register the R kernel with Jupyter system-wide
RUN R -e "IRkernel::installspec(user = FALSE)"

# ===================================================================================
# 5. Final User Configuration and Runtime Command
# ===================================================================================
# Now, switch to the non-root user for the runtime environment
USER rstudio
WORKDIR /home/rstudio

# Set the RETICULATE_PYTHON environment variable for the user
ENV RETICULATE_PYTHON=$CONDA_DIR/bin/python

# Expose the port (can be done as root, but placement here is fine)
EXPOSE 8888

# Set the default command to be run as the rstudio user
CMD ["jupyter", "lab", "--ip=0.0.0.0", "--port=8888", "--no-browser", "--NotebookApp.token=''"]