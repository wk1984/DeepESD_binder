# ==================================================================
# 1. 基础镜像
# ==================================================================
# 使用官方的 NVIDIA CUDA 11.2.2 镜像，包含 cuDNN 8 和开发工具
FROM wk1984/climate4r

# 设置工作目录
WORKDIR /workspace

RUN source /opt/conda/bin/activate c4r-tf && \
    mamba install -y -c conda-forge notebook==6.5.6 jupyterlab jupyter_contrib_nbextensions jupyter_nbextensions_configurator jupyter && \
    R --vanilla -e 'IRkernel::installspec(name = "c4r-tf", displayname = "climate4R (deep)")'

# 设置容器启动时执行的默认命令。
# 启动一个 bash 终端，此时 Conda 环境 'c4r-tf' 已被自动激活。
CMD [ "bash" ]