# Claude Code Sandbox
FROM node:22-bookworm

# Install common dev tools
RUN apt-get update && apt-get install -y \
    git \
    curl \
    wget \
    vim \
    ripgrep \
    fd-find \
    jq \
    python3 \
    python3-pip \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Install Claude Code globally
RUN npm install -g @anthropic-ai/claude-code

# Create non-root user (use 1001 to avoid conflicts)
RUN useradd -m -u 1001 -s /bin/bash coder

# Pre-create Claude config dirs with correct ownership
RUN mkdir -p /home/coder/.claude /home/coder/.config/claude && \
    chown -R coder:coder /home/coder/.claude /home/coder/.config

# Working directory where project will be mounted
WORKDIR /workspace
RUN chown coder:coder /workspace

# Add scripts
COPY --chmod=755 entrypoint.sh /usr/local/bin/entrypoint.sh
COPY --chmod=755 statusline.sh /usr/local/bin/statusline.sh

USER coder

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
