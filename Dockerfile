# ==================================================================
# 1. 基础镜像
# ==================================================================

#FROM continuumio/miniconda3:4.12.0
FROM condaforge/mambaforge:24.9.2-0

RUN mamba install -c conda-forge jupyterlab tensorflow keras -y

RUN mamba install -c conda-forge -c r -c santandermetgroup r-loader r-loader.2nc r-transformer r-downscaler r-visualizer r-downscaler.keras r-climate4r.value r-climate4r.udg r-value r-loader.java r-tensorflow r-irkernel r-ncdf4 -y

RUN pip install zenodo-get -y

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
	
USER user

EXPOSE 8888

WORKDIR /workdir

RUN mkdir -p /workdir/data/pr && \
    zenodo_get -r 17331040 -o /workdir/data/ -g x_ERA-Interim.rds.gz && \
    zenodo_get -r 17331040 -o /workdir/data/pr -g y.rds.gz 