#!/bin/bash
# コンテナ起動時の共通初期化処理

set -e

# プロジェクト専用SSH鍵をコピーし、macOS固有オプションをLinuxで動作するよう加工
if [ -d /home/claude/.ssh_host ]; then
    mkdir -p /home/claude/.ssh
    # プロジェクト専用鍵ファイルをコピー（既存のknown_hostsは保持）
    cp -n /home/claude/.ssh_host/* /home/claude/.ssh/ 2>/dev/null || true

    # configファイルにIgnoreUnknownを先頭に追加してLinux互換にする（macOS由来の設定に対応）
    if [ -f /home/claude/.ssh_host/config ]; then
        echo "IgnoreUnknown UseKeychain,AddKeysToAgent" > /home/claude/.ssh/config
        cat /home/claude/.ssh_host/config >> /home/claude/.ssh/config
    fi

    chmod 700 /home/claude/.ssh
    chmod 600 /home/claude/.ssh/id_* 2>/dev/null || true
    chmod 644 /home/claude/.ssh/*.pub 2>/dev/null || true
    chmod 644 /home/claude/.ssh/known_hosts 2>/dev/null || true
    chmod 644 /home/claude/.ssh/config 2>/dev/null || true
fi

# プロジェクト設定ファイルのシンボリックリンク作成
# ワークスペースに既存ファイルがある場合はスキップ（プロジェクト側が優先）
CONFIG_DIR="/home/claude/project-config"

if [ -d "$CONFIG_DIR" ]; then
    # CLAUDE.md のリンク
    if [ -f "$CONFIG_DIR/CLAUDE.md" ] && [ ! -e /workspace/CLAUDE.md ]; then
        ln -s "$CONFIG_DIR/CLAUDE.md" /workspace/CLAUDE.md
        echo "[config] CLAUDE.md をリンクしました"
    fi

    # .claude/settings.json のリンク
    if [ -f "$CONFIG_DIR/.claude/settings.json" ] && [ ! -e /workspace/.claude/settings.json ]; then
        mkdir -p /workspace/.claude
        ln -s "$CONFIG_DIR/.claude/settings.json" /workspace/.claude/settings.json
        echo "[config] .claude/settings.json をリンクしました"
    fi

    # .claude/commands/*.md のリンク（個別ファイルごと）
    if [ -d "$CONFIG_DIR/.claude/commands" ]; then
        mkdir -p /workspace/.claude/commands
        for cmd_file in "$CONFIG_DIR/.claude/commands"/*.md; do
            [ -f "$cmd_file" ] || continue
            filename=$(basename "$cmd_file")
            if [ ! -e "/workspace/.claude/commands/$filename" ]; then
                ln -s "$cmd_file" "/workspace/.claude/commands/$filename"
                echo "[config] .claude/commands/$filename をリンクしました"
            fi
        done
    fi

    # .mcp.json のリンク
    if [ -f "$CONFIG_DIR/.mcp.json" ] && [ ! -e /workspace/.mcp.json ]; then
        ln -s "$CONFIG_DIR/.mcp.json" /workspace/.mcp.json
        echo "[config] .mcp.json をリンクしました"
    fi
fi

# 渡されたコマンドを実行
exec "$@"
