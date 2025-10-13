# ==================================================================
# 1. 基础镜像
# ==================================================================
# 使用官方的 NVIDIA CUDA 11.2.2 镜像，包含 cuDNN 8 和开发工具
FROM nvidia/cuda:11.2.2-cudnn8-devel-ubuntu20.04

# ==================================================================
# 2. 设置环境变量和参数
# ==================================================================
# 设置为非交互模式，避免 apt-get 等命令在构建时卡住
ENV DEBIAN_FRONTEND=noninteractive

# 定义 Miniconda 的版本和安装路径
ARG MINICONDA_URL="https://repo.anaconda.com/miniconda/Miniconda3-py39_4.9.2-Linux-x86_64.sh"
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
# 4. 创建 Conda 环境
# ==================================================================
# 将 Conda 环境配置文件复制到镜像的临时目录中
# 注意：此文件需要在构建镜像时位于 Dockerfile 的同级目录下
COPY c4r-tf.yml /tmp/c4r-tf.yml

RUN conda install mamba -c conda-forge

# 使用配置文件创建新的 Conda 环境
# 这一步可能会花费较长时间，具体取决于 yml 文件中指定的软件包数量
RUN mamba env create -f /tmp/c4r-tf.yml && \
    # 创建完成后，清理所有不必要的包和缓存，大幅减小镜像体积
    mamba clean -afy

# ==================================================================
# 5. 配置默认环境和启动命令
# ==================================================================
# ！！！重要提示！！！
# 请将下面的 'your_env_name' 替换为你的 c4r-tf.yml 文件中 'name:' 字段定义的环境名称。
# 比如，如果你的 yml 文件中写的是 "name: tensorflow_env"，这里就应该写 "tensorflow_env"。
# 我在这里假设环境名为 'c4r-tf'。
SHELL ["conda", "run", "-n", "tensorflow_env", "/bin/bash", "-c"]

# 设置工作目录
WORKDIR /workspace

# 设置容器启动时执行的默认命令。
# 启动一个 bash 终端，此时 Conda 环境 'c4r-tf' 已被自动激活。
CMD [ "bash" ]