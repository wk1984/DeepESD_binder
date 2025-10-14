# ==================================================================
# 1. 基础镜像
# ==================================================================
# 使用官方的 NVIDIA CUDA 11.2.2 镜像，包含 cuDNN 8 和开发工具
# 建议: 如果不需要在容器内编译 CUDA 代码，使用 runtime 镜像可以大幅减小体积
# FROM nvidia/cuda:11.2.2-cudnn8-devel-ubuntu20.04
FROM ubuntu:20.04

# ==================================================================
# 2. 设置环境变量和参数
# ==================================================================
# 设置为非交互模式，避免 apt-get 等命令在构建时卡住
ENV DEBIAN_FRONTEND=noninteractive

# 定义 Miniconda 的版本和安装路径
# ARG MINICONDA_URL="https://repo.anaconda.com/miniconda/Miniconda3-py39_4.9.2-Linux-x86_64.sh"
ARG MINICONDA_URL="https://github.com/conda-forge/miniforge/releases/download/25.3.1-0/Miniforge3-25.3.1-0-Linux-x86_64.sh"
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

# ==================================================================
# 4. 从 URL 创建 Conda 环境 (*** 这是修改的部分 ***)
# ==================================================================
# 定义 Conda 环境配置文件的 URL
ARG CONDA_ENV_URL="https://raw.githubusercontent.com/wk1984/climate4r_binder/refs/heads/main/c4r-tf.yml"
ARG ENV0=c4r-tf
ENV PATH=${CONDA_DIR}/envs/${ENV0}/bin:$PATH

# 首先安装 Mamba，然后使用 Mamba 创建环境以大幅提速
RUN conda install -n base -c conda-forge mamba -y && \
    # 下载配置文件
    wget ${CONDA_ENV_URL} -O /tmp/environment.yml && \
    # 使用 mamba 代替 conda 来创建环境
    mamba env create -n ${ENV0} -f /tmp/environment.yml && \
    # 删除临时文件
    rm /tmp/environment.yml && \
    # 创建完成后，清理所有不必要的包和缓存
    conda clean -afy &&\ 
    conda init bash && \
    echo "source ${CONDA_DIR}/etc/profile.d/conda.sh" >> ~/.bashrc && \
    echo "conda activate ${ENV0}" >> ~/.bashrc && \
    pip install jupyterlab==4.3.4 
    
RUN which jupyter-lab

# ---- 新增的测试步骤 ----
# 在构建时测试 jupyter-lab 是否可以正常调用。
# --version 会打印版本号并成功退出(返回码0)。如果 jupyter-lab 安装失败，构建会在此处停止。
RUN echo "Testing Jupyter Lab installation..." && \
    jupyter-lab --version && \
    echo "Jupyter Lab test successful."

# 必须要修改权限，否则JUPYTER停止后不能够重新启动
RUN useradd -m -s /bin/bash user && echo "user:111" | chpasswd && \
    usermod -aG sudo user && \
    mkdir /workspace && \
    chown -R user:user /workspace && \
    chmod -R u+rwx /workspace   && \
    chown -R user:user /home/user/   && \
    chmod -R u+rwx /home/user/

RUN pip install zenodo-get

USER user

EXPOSE 8888

WORKDIR /workdir

RUN mkdir -p /workdir/data/pr && \
    zenodo_get -r 17331040 -o /workdir/data/ -g x_ERA-Interim.rds.gz && \
    zenodo_get -r 17331040 -o /workdir/data/pr -g y.rds.gz    

RUN which jupyter-lab

# ---- 新增的测试步骤 ----
# 在构建时测试 jupyter-lab 是否可以正常调用。
# --version 会打印版本号并成功退出(返回码0)。如果 jupyter-lab 安装失败，构建会在此处停止。
RUN echo "Testing Jupyter Lab installation..." && \
    jupyter-lab --version && \
    echo "Jupyter Lab test successful."

CMD ["jupyter-lab",  "--ip=0.0.0.0"  , "--no-browser"]