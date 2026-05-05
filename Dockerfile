###############################################
# Stage 1 — Builder (OpenVINO dev + Go + source)
###############################################
FROM ubuntu:26.04 AS builder

# Install dependencies
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && \
	apt-get install -y --no-install-recommends \
		build-essential \
		cmake \
		git \
		wget \
		python3-pip \
		python3-venv \
		ca-certificates \
		pkg-config \
		libssl-dev \
		golang-go \
		&& rm -rf /var/lib/apt/lists/*


# Create and activate a virtual environment, then install OpenVINO dev tools
RUN python3 -m venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"
RUN pip install --upgrade pip && pip install openvino-dev

# Clone Ollama (replace with correct repo if needed)
RUN git clone https://github.com/ollama/ollama.git /src/ollama
WORKDIR /src/ollama
# Build Ollama with OpenVINO backend (adjust build command as needed)
RUN go build -o /usr/local/bin/ollama .


########################################################
# Stage 2 — Backend Extractor (strip dev-only artifacts)
########################################################
FROM ubuntu:26.04 AS backend_extractor

# Copy only the built Ollama binary
COPY --from=builder /usr/local/bin/ollama /ollama/ollama
# Copy OpenVINO backend artifacts if needed (adjust path as required)
# COPY --from=builder /usr/local/lib/python3.*/dist-packages/openvino /openvino


###############################################
# Stage 3 — Runtime (OpenVINO runtime + Ollama)
###############################################
FROM ubuntu:26.04 AS runtime

ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && \
	apt-get install -y --no-install-recommends \
		python3 \
		python3-pip \
		python3-venv \
		ca-certificates \
		libssl3 \
		&& rm -rf /var/lib/apt/lists/*

# Create and activate a virtual environment, then install OpenVINO
RUN python3 -m venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"
RUN pip install --upgrade pip && pip install openvino

# Copy Ollama binary
COPY --from=backend_extractor /ollama/ollama /usr/local/bin/ollama

# (Optional) Copy OpenVINO runtime libs if needed
# COPY --from=backend_extractor /openvino /usr/local/lib/python3.*/dist-packages/openvino

# Set environment for OpenVINO device selection (iGPU/NPU)
ENV OPENVINO_DEVICE="AUTO"

EXPOSE 11434
ENTRYPOINT ["ollama", "serve"]