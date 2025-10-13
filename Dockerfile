FROM jupyter/base-notebook:python-3.9.13


ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC

USER root
RUN apt-get update && apt-get install -y xorg git wget build-essential tzdata && apt-get clean

#RUN useradd -m -s /bin/bash jovyan && echo "jovyan:111" | chpasswd
#RUN usermod -aG sudo jovyan

#USER jovyan
RUN conda install mamba -y -n base -c conda-forge

# climate4R + tensorflow for deep learning
COPY c4r-tf.yml c4r-tf.yml

RUN conda env update --name base --file c4r-tf.yml --prune && \
    mamba install -y -c conda-forge -c r -c santandermetgroup jupyter && \
    R --vanilla -e 'IRkernel::installspec(name = "base", displayname = "climate4R (deep)", user = TRUE)'

#RUN mamba env create -n climate4tf --file c4r-tf.yml && \
#    source /opt/conda/bin/activate climate4tf && \
#    mamba install -y -c conda-forge -c r -c santandermetgroup jupyter && \
#    R --vanilla -e 'IRkernel::installspec(name = "climate4tf", displayname = "climate4R (deep)", user = TRUE)'