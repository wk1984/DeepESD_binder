# ==================================================================
# 1. 基础镜像
# ==================================================================

FROM continuumio/miniconda3:4.12.0

RUN conda install -c conda-forge jupyterlab tensorflow keras

RUN conda install -c conda-forge -c r -c santandermetgroup r-loader r-loader.2nc r-transformer r-downscaler r-visualizer r-downscaler.keras r-climate4r.value r-climate4r.udg r-value r-loader.java r-tensorflow r-irkernel r-ncdf4

USER user

EXPOSE 8888

WORKDIR /workdir   

RUN which jupyter-lab