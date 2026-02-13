#!/bin/bash
# コンテナ起動時の共通初期化処理

set -e

# ホストのSSH設定をコピーし、macOS固有オプションをLinuxで動作するよう加工
if [ -d /home/claude/.ssh_host ]; then
    mkdir -p /home/claude/.ssh
    # 鍵ファイル等をコピー（既存のknown_hostsは保持）
    cp -n /home/claude/.ssh_host/* /home/claude/.ssh/ 2>/dev/null || true

    # configファイルにIgnoreUnknownを先頭に追加してLinux互換にする
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

# 渡されたコマンドを実行
exec "$@"
