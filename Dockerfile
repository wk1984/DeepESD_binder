# 使用支持CUDA的基础镜像
FROM nvidia/11.8.0-cudnn8-runtime-ubuntu20.04

# 设置环境变量
ENV LANG=C.UTF-8
ENV LC_ALL=C.UTF-8
ENV DEBIAN_FRONTEND=noninteractive
ENV PYTHON_VERSION=3.9
ENV R_VERSION=3.6.3

# 设置工作目录
WORKDIR /workspace

# 安装系统依赖
RUN apt-get update && apt-get install -y --no-install-recommends \
    wget \
    curl \
    git \
    vim \
    build-essential \
    software-properties-common \
    ca-certificates \
    gnupg2 \
    && rm -rf /var/lib/apt/lists/*

# 安装Python 3.9
RUN apt-get update && apt-get install -y --no-install-recommends \
    python3.9 \
    python3.9-dev \
    python3.9-distutils \
    python3-pip \
    && ln -sf /usr/bin/python3.9 /usr/bin/python3 \
    && ln -sf /usr/bin/python3 /usr/bin/python \
    && rm -rf /var/lib/apt/lists/*

# 更新pip并安装基础Python包
RUN curl -sS https://bootstrap.pypa.io/get-pip.py | python3.9
RUN pip3 install --no-cache-dir --upgrade pip setuptools wheel

# 安装R 3.6
RUN apt-get update && apt-get install -y --no-install-recommends \
    dirmngr \
    gnupg \
    && wget -qO- https://cloud.r-project.org/bin/linux/ubuntu/marutter_pubkey.asc | apt-key add - \
    && echo "deb https://cloud.r-project.org/bin/linux/ubuntu focal-cran40/" >> /etc/apt/sources.list \
    && apt-get update \
    && apt-get install -y --no-install-recommends \
    r-base=${R_VERSION}* \
    r-base-dev=${R_VERSION}* \
    && rm -rf /var/lib/apt/lists/*

# 安装TensorFlow 2.10 with CUDA支持
RUN pip3 install --no-cache-dir \
    tensorflow==2.10.0 \
    numpy==1.23.5 \
    pandas \
    scikit-learn \
    matplotlib \
    jupyter

# 安装R包（包括tensorflow和reticulate）
RUN R -e "install.packages('reticulate', repos='https://cloud.r-project.org/')" \
    && R -e "install.packages('tensorflow', repos='https://cloud.r-project.org/')" \
    && R -e "install.packages('devtools', repos='https://cloud.r-project.org/')" \
    && R -e "install.packages('ggplot2', repos='https://cloud.r-project.org/')" \
    && R -e "install.packages('dplyr', repos='https://cloud.r-project.org/')"

# 配置reticulate使用正确的Python版本
RUN R -e "reticulate::use_python('/usr/bin/python3.9', required=TRUE)"

# 在R中安装和配置tensorflow
RUN R -e "tensorflow::install_tensorflow(version = '2.10.0')"

# 创建Jupyter内核，同时支持R和Python
RUN pip3 install --no-cache-dir irkernel \
    && R -e "IRkernel::installspec(user = FALSE)"

# 设置环境变量让R的tensorflow包能找到Python的tensorflow
ENV RETICULATE_PYTHON=/usr/bin/python3.9
ENV TENSORFLOW_PYTHON=/usr/bin/python3.9

# 创建测试脚本
RUN echo 'library(tensorflow)\nlibrary(reticulate)\n\n# 测试TensorFlow是否正常工作\ncat("Python version:", py_config()$version, "\\n")\ncat("TensorFlow version in Python:", tf$`__version__`, "\\n")\n\n# 测试R的tensorflow包\ncat("R tensorflow version:", as.character(packageVersion("tensorflow")), "\\n")\n\n# 创建一个简单的tensorflow计算\ntf$constant("Hello from TensorFlow in R!")' > /workspace/test_tensorflow.R

RUN echo 'import tensorflow as tf\nimport sys\n\nprint("Python version:", sys.version)\nprint("TensorFlow version:", tf.__version__)\nprint("GPU available:", tf.test.is_gpu_available())\n\n# 测试GPU\nif tf.test.is_gpu_available():\n    print("GPU devices:")\n    for device in tf.config.experimental.list_physical_devices("GPU"):\n        print(f"  - {device}")\nelse:\n    print("No GPU detected")' > /workspace/test_tensorflow.py

# 暴露Jupyter端口
EXPOSE 8888

# 创建启动脚本
RUN echo '#!/bin/bash\n\n# 测试环境\necho "=== Testing Python TensorFlow ==="\npython3 /workspace/test_tensorflow.py\n\necho -e "\\n=== Testing R TensorFlow ==="\nRscript /workspace/test_tensorflow.R\n\necho -e "\\n=== Starting Jupyter Lab ==="\njupyter lab --ip=0.0.0.0 --port=8888 --no-browser --allow-root --NotebookApp.token="" --NotebookApp.password=""' > /workspace/start.sh

RUN chmod +x /workspace/start.sh

# 设置默认命令
CMD ["/workspace/start.sh"]