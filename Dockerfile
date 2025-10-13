# ==================================================================
# 1. 基础镜像
# ==================================================================
# 使用官方的 NVIDIA CUDA 11.2.2 镜像，包含 cuDNN 8 和开发工具
FROM jupyter/base-notebook:python-3.9.13

ARG ENV0=test

ENV PATH /opt/conda/envs/${ENV0}/bin:$PATH

RUN mamba create -n ${ENV0} python==3.9.13 jupyterlab -c conda-forge

RUN conda init bash && \
    echo "source /opt/conda/etc/profile.d/conda.sh" >> ~/.bashrc && \
    echo "conda activate ${ENV0}" >> ~/.bashrc
    
RUN mamba install xarray -c conda-forge -n ${ENV0}

# CMD ["conda", "init", "/bin/bash"]
    
# SHELL ["/bin/bash", "conda", "activate", "${ENV0}"]
# 
RUN which jupyter-lab

EXPOSE 8888
# 
# # RUN source /opt/conda/bin/activate c4r-tf && \
# #     mamba install -y -c conda-forge notebook==7.3 jupyterlab==4.3 referencing==0.35 jupyter==1.1 jupyter-server==2.15 \
# #                          typing-extensions==4.14.1 bokeh==3.4 && \
# #     R --vanilla -e 'IRkernel::installspec(name = "c4r-tf", displayname = "climate4R (deep)")'
# # 设置工作目录
# WORKDIR /workspace
# # 设置容器启动时执行的默认命令。
# # 启动一个 bash 终端，此时 Conda 环境 'c4r-tf' 已被自动激活。

CMD [ "jupyter-lab" ]