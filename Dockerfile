FROM ubuntu:24.04

# 非インタラクティブモードでパッケージインストール
ENV DEBIAN_FRONTEND=noninteractive

# 基本パッケージのインストール
RUN apt-get update && apt-get install -y \
    git \
    curl \
    openssh-client \
    zsh \
    ripgrep \
    jq \
    sudo \
    ca-certificates \
    gnupg \
    && rm -rf /var/lib/apt/lists/*

# Node.js 20 のインストール（NodeSource経由）
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - \
    && apt-get install -y nodejs \
    && rm -rf /var/lib/apt/lists/*

# GitHub CLI のインストール
RUN curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg \
    | dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg \
    && chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg \
    && echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" \
    | tee /etc/apt/sources.list.d/github-cli.list > /dev/null \
    && apt-get update \
    && apt-get install -y gh \
    && rm -rf /var/lib/apt/lists/*

# 非rootユーザー claude を作成（sudo権限付き）
RUN useradd -m -s /bin/zsh -G sudo claude \
    && echo "claude ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# claudeユーザーに切り替え
USER claude

# SSHのknown_hosts事前設定（github.com）
RUN mkdir -p /home/claude/.ssh \
    && ssh-keyscan github.com >> /home/claude/.ssh/known_hosts 2>/dev/null \
    && chmod 700 /home/claude/.ssh \
    && chmod 644 /home/claude/.ssh/known_hosts

# Claude Code のインストール
RUN curl -fsSL https://claude.ai/install.sh | bash

# PATHにClaude Codeを追加
ENV PATH="/home/claude/.claude/bin:/home/claude/.local/bin:${PATH}"

# スクリプトをコピー
COPY --chown=claude:claude scripts/entrypoint.sh /home/claude/entrypoint.sh
COPY --chown=claude:claude scripts/start.sh /home/claude/start.sh
RUN chmod +x /home/claude/entrypoint.sh /home/claude/start.sh

WORKDIR /workspace

# entrypoint.shでSSH設定等の初期化を行い、CMDで指定されたコマンドを実行
ENTRYPOINT ["/home/claude/entrypoint.sh"]
CMD ["/home/claude/start.sh"]
