FROM nvidia/cuda:11.2.2-cudnn8-devel-ubuntu20.04
# FROM ubuntu:20.04

RUN export DEBIAN_FRONTEND=noninteractive \
    export DEBCONF_NONINTERACTIVE_SEEN=true \
    && apt-get update -y \
    && apt-get install -y --no-install-recommends wget make m4 patch build-essential ca-certificates cmake curl nano git \
                                                  ffmpeg libsm6 libxext6 \
                                                  libgeos-dev libproj-dev \
												  libssl-dev zlib1g-dev libbz2-dev libreadline-dev libsqlite3-dev \
												  llvm libncurses5-dev libncursesw5-dev xz-utils tk-dev libffi-dev liblzma-dev python-openssl \
#     && apt-get install -y --no-install-recommends libgeos-dev libproj-dev libgl1-mesa-glx \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# RUN python3 -V

RUN wget --quiet https://repo.anaconda.com/miniconda/Miniconda3-py39_4.9.2-Linux-x86_64.sh -O ~/miniforge.sh \
# RUN wget --quiet https://mirrors.tuna.tsinghua.edu.cn/anaconda/miniconda/Miniconda3-py38_23.9.0-0-Linux-x86_64.sh -O ~/miniforge.sh \
#RUN wget --quiet https://gh-proxy.com/https://github.com/conda-forge/miniforge/releases/download/4.12.0-0/Mambaforge-4.12.0-0-Linux-x86_64.sh -O ~/miniforge.sh \
    && /bin/bash ~/miniforge.sh -b -p /opt/miniforge \
    && rm ~/miniforge.sh \
    && ln -s /opt/miniforge/etc/profile.d/conda.sh /etc/profile.d/conda.sh \
    && echo ". /opt/miniforge/etc/profile.d/conda.sh" >> ~/.bashrc

ENV PATH=/opt/miniforge/bin:${PATH}
ENV SKLEARN_ALLOW_DEPRECATED_SKLEARN_PACKAGE_INSTALL=True

# RUN useradd -m -s /bin/bash user && echo "user:111" | chpasswd
# RUN usermod -aG sudo user
# USER user

# 配置PYTHON环境

RUN . /root/.bashrc \
     && /opt/miniforge/bin/conda init bash \
#     && conda info --envs \
#     && conda update -n base -c defaults conda \
# #    && conda config --set custom_channels.conda-forge https://mirrors.tuna.tsinghua.edu.cn/anaconda/cloud/ \
     && conda install -c conda-forge mamba -y
# 
RUN python -m pip install pip==20.2 # -i https://mirrors.tuna.tsinghua.edu.cn/pypi/web/simple

# 更新conda并安装所有依赖包
RUN mamba install -c conda-forge -y \
    # R 基础环境
    'r-base>=3.6.1,<4' \
    # R 包依赖
    'r-loader=1.7.1' \
    'r-loader.2nc=0.1.1' \
    'r-transformer=2.1.0' \
    'r-downscaler=3.3.2' \
    'r-visualizer=1.6.0' \
    'r-downscaler.keras=1.0.0' \
    'r-climate4r.value=0.0.2' \
    'r-climate4r.udg=0.2.4' \
    'r-value=2.2.2' \
    'r-loader.java=1.1.1' \
    'r-tensorflow=2.6.0' \
    'r-irkernel=1.2' \
    'r-magrittr=2.0.1' \
    'r-rcolorbrewer=1.1_2' \
    'r-gridextra=2.3' \
    'r-ggplot2=3.3.3' \
    # Python 依赖
    'tensorflow=2.6.0' \
    'python=3.9.*' \
    # Jupyter Lab
    'jupyterlab' \
    'ipykernel' && \
    conda clean -afy

# 安装额外的R包和配置
RUN R -e "install.packages(c('devtools'), repos='https://cloud.r-project.org/')" && \
#    R -e "keras::install_keras()" && \
    R -e "IRkernel::installspec(user = FALSE)"
 
# RUN python -c "import dl4ds as dds; import climetlab as cml"
# notebook==7.3.2 jupyter==1.1.1 jupyterlab==4.3.4 jupyter-server==2.15.0 referencing==0.35.1 typing-extensions==3.7.4.3 python-json-logger==2.0.7