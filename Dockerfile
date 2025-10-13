# ==================================================================
# 1. 基础镜像
# ==================================================================
# 使用官方的 NVIDIA CUDA 11.2.2 镜像，包含 cuDNN 8 和开发工具
#FROM santandermetgroup/meteohub:20250325

#ARG ENV0=climate4tf

#ENV PATH=/opt/conda/envs/${ENV0}/bin:$PATH

#RUN conda init bash && \
#    echo "source /opt/conda/etc/profile.d/conda.sh" >> ~/.bashrc && \
#    echo "conda activate ${ENV0}" >> ~/.bashrc
	
#RUN pip install jupyterlab
	
#RUN mamba install -y -c conda-forge -c r -c santandermetgroup jupyter jsonschema==4.25.1 
#RUN mamba install -y -c conda-forge -c r -c santandermetgroup jupyter referencing==0.36.2 
#RUN mamba install -y -c conda-forge -c r -c santandermetgroup jupyter typing-extensions==4.14.1 typing_extensions==4.14.1

FROM wk1984/climate4r

RUN usermod -aG sudo jovyan

USER jovyan

RUN which jupyter-lab

# ---- 新增的测试步骤 ----
# 在构建时测试 jupyter-lab 是否可以正常调用。
# --version 会打印版本号并成功退出(返回码0)。如果 jupyter-lab 安装失败，构建会在此处停止。
RUN echo "Testing Jupyter Lab installation..." && \
    jupyter-lab --version && \
    echo "Jupyter Lab test successful."

EXPOSE 8888

CMD ["jupyter-lab",  "--ip=0.0.0.0"  , "--no-browser"]