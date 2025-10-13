# ==================================================================
# 1. 基础镜像
# ==================================================================
# 使用官方的 NVIDIA CUDA 11.2.2 镜像，包含 cuDNN 8 和开发工具
FROM jupyter/base-notebook:python-3.9.13

RUN mamba create -n test python==3.9.13 jupyterlab -c conda-forge

SHELL ["conda", "init", "/bin/bash"]
    
# SHELL ["/bin/bash", "conda", "activate", "test"]
# 
# RUN which jupyter-lab
# 
# # RUN source /opt/conda/bin/activate c4r-tf && \
# #     mamba install -y -c conda-forge notebook==7.3 jupyterlab==4.3 referencing==0.35 jupyter==1.1 jupyter-server==2.15 \
# #                          typing-extensions==4.14.1 bokeh==3.4 && \
# #     R --vanilla -e 'IRkernel::installspec(name = "c4r-tf", displayname = "climate4R (deep)")'
# # 设置工作目录
# WORKDIR /workspace
# # 设置容器启动时执行的默认命令。
# # 启动一个 bash 终端，此时 Conda 环境 'c4r-tf' 已被自动激活。
# CMD [ "jupyter-lab" ]