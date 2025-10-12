# 使用官方 Miniconda 镜像作为基础
FROM continuumio/miniconda3:4.12.0

# 设置环境变量
ENV LANG=C.UTF-8 LC_ALL=C.UTF-8
ENV PYTHONUNBUFFERED=1

# 创建并设置工作目录
WORKDIR /workspace

# 更新conda并安装所有依赖包
RUN conda update -n base -c defaults conda && \
    conda install -c conda-forge -y \
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
    # 工具和其他依赖
    'cdo=1.9.10' \
    # Python 依赖
    'tensorflow=2.6.*' \
    'python=3.9.*' \
    # Jupyter Lab
    'jupyterlab' \
    'ipykernel' && \
    conda clean -afy

# 安装额外的R包和配置
RUN R -e "install.packages(c('devtools', 'keras'), repos='https://cloud.r-project.org/')" && \
    R -e "keras::install_keras()" && \
    R -e "IRkernel::installspec(user = FALSE)"

# 暴露 Jupyter Lab 端口
EXPOSE 8888
