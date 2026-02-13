#!/bin/bash
# Claude Code 起動スクリプト

set -e

# 引数が渡された場合はプロンプト付きで実行
if [ "$#" -gt 0 ]; then
    exec claude --dangerously-skip-permissions -p "$*"
else
    # 引数なしの場合はインタラクティブモードで起動
    exec claude --dangerously-skip-permissions
fi
