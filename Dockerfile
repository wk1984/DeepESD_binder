# ==================================================================
# 1. 基础镜像
# ==================================================================

#FROM continuumio/miniconda3:4.12.0
FROM condaforge/mambaforge:24.9.2-0

RUN mamba install -c conda-forge jupyterlab tensorflow keras

RUN mamba install -c conda-forge -c r -c santandermetgroup r-loader r-loader.2nc r-transformer r-downscaler r-visualizer r-downscaler.keras r-climate4r.value r-climate4r.udg r-value r-loader.java r-tensorflow r-irkernel r-ncdf4

RUN which jupyter-lab

#USER user

EXPOSE 8888

WORKDIR /workdir

# ---- 新增的测试步骤 ----
# 在构建时测试 jupyter-lab 是否可以正常调用。
# --version 会打印版本号并成功退出(返回码0)。如果 jupyter-lab 安装失败，构建会在此处停止。
RUN echo "Testing Jupyter Lab installation..." && \
    jupyter-lab --version && \
    echo "Jupyter Lab test successful."