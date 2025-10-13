# ==================================================================
# 1. 基础镜像
# ==================================================================
# 使用官方的 NVIDIA CUDA 11.2.2 镜像，包含 cuDNN 8 和开发工具
FROM santandermetgroup/meteohub:20250325

ARG ENV0=climate4tf

ENV PATH=/opt/conda/envs/${ENV0}/bin:$PATH

RUN conda init bash && \
    echo "source /opt/conda/etc/profile.d/conda.sh" >> ~/.bashrc && \
    echo "conda activate ${ENV0}" >> ~/.bashrc
    
RUN which jupyter-lab

EXPOSE 8888

CMD ["jupyter-lab",  "--ip=0.0.0.0"  , "--no-browser"]