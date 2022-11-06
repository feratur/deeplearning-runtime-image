ARG DEEPSPEED_VERSION=0.7.4
ARG ONNX_VERSION=1.13.1

FROM pytorch/pytorch:1.12.1-cuda11.3-cudnn8-devel AS devel

ARG DEEPSPEED_VERSION
WORKDIR /workspace

ENV CUDA_PATH=/usr/local/cuda \
    CUDA_HOME=/usr/local/cuda \
    LD_LIBRARY_PATH=/usr/local/cuda/lib64

# DeepSpeed needs libaio-dev
RUN export DEBIAN_FRONTEND=noninteractive && \
    apt-get update && \
    apt-get install -y --no-install-recommends libaio-dev && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# It is really necessary to install DeepSpeed requirements
# before building DeepSpeed wheel (otherwise the build might fail)
COPY deepspeed_requirements.txt /tmp/
RUN pip install --no-cache-dir -r /tmp/deepspeed_requirements.txt

# Building DeepSpeed wheel - might take a lot of time
RUN pip download --no-deps deepspeed==${DEEPSPEED_VERSION} && \
    tar -xzf deepspeed-${DEEPSPEED_VERSION}.tar.gz && \
    cd deepspeed-${DEEPSPEED_VERSION} && \
    DS_BUILD_OPS=1 python setup.py bdist_wheel

# deepspeed-0.7.4-cp37-cp37m-linux_x86_64.whl
FROM pytorch/pytorch:1.12.1-cuda11.3-cudnn8-runtime AS runtime

ARG DEEPSPEED_VERSION
ARG ONNX_VERSION
WORKDIR /workspace

# This lets ONNX Runtime properly locate cuDNN library
# inside PyTorch package directory
ENV LD_LIBRARY_PATH=/opt/conda/lib/python3.7/site-packages/torch/lib

# Installing AWS CLI (for data loading) and some useful utilities
RUN export DEBIAN_FRONTEND=noninteractive && \
    apt-get update && \
    apt-get install -y --no-install-recommends curl unzip jq && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" && \
    unzip awscliv2.zip && \
    ./aws/install && \
    rm awscliv2.zip && \
    rm -rf aws

# Pre-built DeepSpeed wheel is copied from the previous build stage
COPY deepspeed_requirements.txt /tmp/
COPY --from=devel /workspace/deepspeed-${DEEPSPEED_VERSION}/dist/deepspeed-${DEEPSPEED_VERSION}-cp37-cp37m-linux_x86_64.whl /tmp/

# Installing DeepSpeed and ONNX Runtime
RUN pip install --no-cache-dir -r /tmp/deepspeed_requirements.txt && \
    pip install /tmp/deepspeed-${DEEPSPEED_VERSION}-cp37-cp37m-linux_x86_64.whl && \
    pip install --no-cache-dir onnxruntime-gpu==${ONNX_VERSION}

# Entrypoint for loading external data from S3 before starting the container
COPY --chmod=555 entrypoint.sh /

ENTRYPOINT ["/entrypoint.sh"]
CMD ["bash"]
