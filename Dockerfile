FROM tensorflow/tensorflow:2.6.1-gpu-jupyter

ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC
ENV PATH=/opt/miniforge/bin:${PATH}
ENV SKLEARN_ALLOW_DEPRECATED_SKLEARN_PACKAGE_INSTALL=True

# RUN export DEBIAN_FRONTEND=noninteractive \
#     export DEBCONF_NONINTERACTIVE_SEEN=true \
#     && apt-get update -y \
#     && apt-get install -y --no-install-recommends wget make m4 patch build-essential ca-certificates cmake curl nano git \
#                                                   ffmpeg libsm6 libxext6 \
#                                                   libgeos-dev libproj-dev \
# 												  libssl-dev zlib1g-dev libbz2-dev libreadline-dev libsqlite3-dev \
# 												  llvm libncurses5-dev libncursesw5-dev xz-utils tk-dev libffi-dev liblzma-dev python-openssl \
# #     && apt-get install -y --no-install-recommends libgeos-dev libproj-dev libgl1-mesa-glx \
#     && apt-get clean \
#     && rm -rf /var/lib/apt/lists/*
# 
# RUN wget --quiet https://repo.anaconda.com/miniconda/Miniconda3-py39_4.9.2-Linux-x86_64.sh -O ~/miniforge.sh \
#    && /bin/bash ~/miniforge.sh -b -p /opt/miniforge \
#    && rm ~/miniforge.sh \
#    && ln -s /opt/miniforge/etc/profile.d/conda.sh /etc/profile.d/conda.sh \
#    && echo ". /opt/miniforge/etc/profile.d/conda.sh" >> ~/.bashrc
#    
# #RUN useradd -m -s /bin/bash jovyan && echo "jovyan:111" | chpasswd
# #RUN usermod -aG sudo jovyan
# 
# #USER jovyan
# RUN conda install mamba -y -n base -c conda-forge
# 
# # climate4R + tensorflow for deep learning
# COPY c4r-tf.yml c4r-tf.yml
# 
# RUN conda env update --name base --file c4r-tf.yml --prune && \
#     mamba install -y -c conda-forge -c r -c santandermetgroup jupyter && \
#     R --vanilla -e 'IRkernel::installspec(name = "base", displayname = "climate4R (deep)", user = TRUE)'
# 
# #RUN mamba env create -n climate4tf --file c4r-tf.yml && \
# #    source /opt/conda/bin/activate climate4tf && \
# #    mamba install -y -c conda-forge -c r -c santandermetgroup jupyter && \
# #    R --vanilla -e 'IRkernel::installspec(name = "climate4tf", displayname = "climate4R (deep)", user = TRUE)'