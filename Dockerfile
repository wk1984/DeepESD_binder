# 使用支持CUDA的基础镜像
FROM nvidia/cuda:11.8.0-cudnn8-runtime-ubuntu20.04

# 设置环境变量
ENV LANG=C.UTF-8 LC_ALL=C.UTF-8
ENV PATH /opt/conda/bin:$PATH
ENV CUDA_HOME /usr/local/cuda
ENV LD_LIBRARY_PATH /usr/local/cuda/lib64:$LD_LIBRARY_PATH

# 设置时区
ENV TZ=UTC
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# 安装基础依赖
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    ca-certificates \
    curl \
    git \
    wget \
    vim \
    nano \
    less \
    htop \
    && rm -rf /var/lib/apt/lists/*

# 安装Miniconda
RUN wget --quiet https://github.com/conda-forge/miniforge/releases/download/4.12.0-0/Mambaforge-4.12.0-0-Linux-x86_64.sh -O ~/miniconda.sh && \
    /bin/bash ~/miniconda.sh -b -p /opt/conda && \
    rm ~/miniconda.sh && \
#    /opt/conda/bin/conda clean -tipsy && \
    ln -s /opt/conda/etc/profile.d/conda.sh /etc/profile.d/conda.sh && \
    echo ". /opt/conda/etc/profile.d/conda.sh" >> ~/.bashrc && \
    echo "conda activate base" >> ~/.bashrc

# 创建conda环境
#RUN conda install mamba -c conda-forge -y
#RUN mamba create -n rpy-tf python=3.9 r-base=4.2 -c conda-forge -y

# 初始化conda环境
#RUN echo "conda activate rpy-tf" >> ~/.bashrc
#ENV PATH /opt/conda/envs/rpy-tf/bin:$PATH

# 安装Python包
RUN mamba install -y -c conda-forge -c r \
    tensorflow==2.10.0 \
    numpy \
    pandas \
    scikit-learn \
    matplotlib \
    seaborn \
    jupyter \
    jupyterlab \
    r-reticulate r-devtools \
    r-tensorflow \
    r-keras \
    r-IRkernel \
	r-loader r-loader.2nc \
	r-transformer r-downscaler r-visualizer r-downscaler.keras \
	r-climate4r.value r-climate4r.udg r-value r-loader.java \
	r-r-climate4r.datasets r-climate4r r-climate4r.hub
	

# 配置R的tensorflow包使用正确的Python环境
RUN R -e " \
    library(reticulate); \
    use_condaenv('base', required=TRUE); \
	library(IRkernel); \
	IRkernel::installspec() " 
    
# 注册R内核到Jupyter
# RUN R -e "IRkernel::installspec()"

# 验证安装
RUN python -c "import tensorflow as tf; print('TensorFlow version:', tf.__version__); print('GPU available:', tf.config.list_physical_devices('GPU'))"
# RUN /opt/conda/envs/rpy-tf/bin/Rscript -e "library(tensorflow); tf_version()"

# 设置工作目录
RUN useradd -m -s /bin/bash user && echo "user:111" | chpasswd
RUN usermod -aG sudo user

# 必须要修改权限，否则JUPYTER停止后不能够重新启动
USER root
RUN chown -R user:user $HOME/
RUN chmod -R u+rwx $HOME/

RUN mkdir -p /workdir
RUN chown -R user:user /workdir
RUN chmod -R u+rwx /workdir

USER user
WORKDIR /workdir

# 创建Jupyter配置
#RUN /opt/conda/envs/rpy-tf/bin/jupyter notebook --generate-config && \
#    echo "c.NotebookApp.ip = '0.0.0.0'" >> /root/.jupyter/jupyter_notebook_config.py && \
#    echo "c.NotebookApp.port = 8888" >> /root/.jupyter/jupyter_notebook_config.py && \
#    echo "c.NotebookApp.open_browser = False" >> /root/.jupyter/jupyter_notebook_config.py && \
#    echo "c.NotebookApp.allow_root = True" >> /root/.jupyter/jupyter_notebook_config.py

# 暴露端口
EXPOSE 8888

# 设置默认命令
CMD ["/bin/bash"]