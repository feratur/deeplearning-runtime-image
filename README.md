# deeplearning-runtime-image [![](https://img.shields.io/badge/Docker-Hub-blue?logo=docker)](https://hub.docker.com/r/feratur/deeplearning-runtime/tags)
Scripts for building a CUDA-enabled Docker image with a runtime necessary for inferencing Deep Learning models.

### What's inside?
This image is based on the official [PyTorch runtime Docker image](https://hub.docker.com/r/pytorch/pytorch) with an addition of several libraries targeted at efficient Deep Learning model inference. The image features:
- CUDA Runtime;
- PyTorch (with torchtext, torchvision);
- DeepSpeed (including DeepSpeed Inference);
- ONNX Runtime (CUDA-enabled);
- and all minor dependencies, such as numpy, triton, etc.

### Loading data from S3 storage
The image contains an entrypoint script that allows to download arbitrary data from an S3-compatible storage upon container start. To utilize this functionality set the `S3_DATA_PATH` environment variable to the desired value (such as `s3://bucket-name/data-dir/`) - the files will be downloaded to the `/data` directory of the container. You may also set the `S3_PARAMS` environment variable to pass additional arguments to `aws cp` utility.
