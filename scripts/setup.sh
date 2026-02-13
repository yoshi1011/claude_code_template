#!/bin/bash
# 初回セットアップスクリプト

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

echo "=== Claude Code Docker環境 セットアップ ==="

# workspaceディレクトリの作成
if [ ! -d "$PROJECT_DIR/workspace" ]; then
    mkdir -p "$PROJECT_DIR/workspace"
    echo "[OK] workspace ディレクトリを作成しました"
else
    echo "[OK] workspace ディレクトリは既に存在します"
fi

# .envファイルのコピー
if [ ! -f "$PROJECT_DIR/.env" ]; then
    cp "$PROJECT_DIR/.env.example" "$PROJECT_DIR/.env"
    echo "[OK] .env ファイルを作成しました（.env.example からコピー）"
    echo "     必要に応じて .env を編集してください"
else
    echo "[OK] .env ファイルは既に存在します"
fi

# configディレクトリの確認
if [ -d "$PROJECT_DIR/config" ]; then
    echo "[OK] config ディレクトリは既に存在します"
else
    echo "[WARN] config ディレクトリが見つかりません"
fi

# mcp-serversディレクトリの確認
if [ -d "$PROJECT_DIR/mcp-servers" ]; then
    echo "[OK] mcp-servers ディレクトリは既に存在します"
else
    echo "[WARN] mcp-servers ディレクトリが見つかりません"
fi

# Dockerイメージのビルド
echo ""
echo "=== Dockerイメージをビルドしています... ==="
cd "$PROJECT_DIR"
docker compose build

echo ""
echo "=== セットアップ完了 ==="
echo "以下のコマンドでClaude Codeを起動できます:"
echo "  make start              # インタラクティブモード"
echo "  make run PROMPT=\"...\"   # プロンプト付き実行"
echo "  make shell              # シェルで入る"
echo ""
echo "=== カスタマイズ ==="
echo "  config/CLAUDE.md              # Claude Code のルール設定"
echo "  config/.claude/commands/      # カスタムスラッシュコマンド"
echo "  config/.mcp.json              # MCPサーバー設定"
echo "  mcp-servers/                  # カスタムMCPサーバーの配置先"
