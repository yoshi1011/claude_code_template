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

# claude-auth ディレクトリの作成（Claude Code 認証データ保存用）
if [ ! -d "$PROJECT_DIR/claude-auth" ]; then
    mkdir -p "$PROJECT_DIR/claude-auth"
    echo "[OK] claude-auth ディレクトリを作成しました"
else
    echo "[OK] claude-auth ディレクトリは既に存在します"
fi

# ssh-keys ディレクトリの作成（プロジェクト専用SSH鍵配置用）
if [ ! -d "$PROJECT_DIR/ssh-keys" ]; then
    mkdir -p "$PROJECT_DIR/ssh-keys"
    echo "[OK] ssh-keys ディレクトリを作成しました"
else
    echo "[OK] ssh-keys ディレクトリは既に存在します"
fi

# .envファイルのコピー
if [ ! -f "$PROJECT_DIR/.env" ]; then
    cp "$PROJECT_DIR/.env.example" "$PROJECT_DIR/.env"
    echo "[OK] .env ファイルを作成しました（.env.example からコピー）"
    echo "     必要に応じて .env を編集してください"
else
    echo "[OK] .env ファイルは既に存在します"
fi

# 設定ファイルの生成（.sample からコピー）
generate_from_sample() {
    local sample="$1"
    local target="${sample%.sample}"
    if [ -f "$sample" ] && [ ! -f "$target" ]; then
        cp "$sample" "$target"
        echo "[OK] $(basename "$target") を作成しました（$(basename "$sample") からコピー）"
    elif [ -f "$target" ]; then
        echo "[OK] $(basename "$target") は既に存在します"
    fi
}

# config/ 配下の設定ファイルを生成
echo ""
echo "--- 設定ファイルの生成 ---"
generate_from_sample "$PROJECT_DIR/config/CLAUDE.md.sample"
generate_from_sample "$PROJECT_DIR/config/.mcp.json.sample"
generate_from_sample "$PROJECT_DIR/config/.gitconfig.sample"
mkdir -p "$PROJECT_DIR/config/.claude/commands"
generate_from_sample "$PROJECT_DIR/config/.claude/settings.json.sample"
for sample_file in "$PROJECT_DIR/config/.claude/commands"/*.md.sample; do
    [ -f "$sample_file" ] || continue
    generate_from_sample "$sample_file"
done

# plansディレクトリの作成
if [ ! -d "$PROJECT_DIR/plans" ]; then
    mkdir -p "$PROJECT_DIR/plans"
    echo "[OK] plans ディレクトリを作成しました"
else
    echo "[OK] plans ディレクトリは既に存在します"
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
echo "=== 初回起動時の認証 ==="
echo "  make start で起動後、コンテナ内で claude login を実行して認証してください。"
echo "  認証情報は claude-auth/ に保存され、コンテナ再起動後も維持されます。"
echo ""
echo "=== SSH鍵の設定 ==="
echo "  Git over SSH を使用する場合は、プロジェクト専用のSSH鍵を配置してください:"
echo "    cp ~/.ssh/id_ed25519 ssh-keys/"
echo "    cp ~/.ssh/id_ed25519.pub ssh-keys/"
echo "  または、専用の鍵ペアを生成:"
echo "    ssh-keygen -t ed25519 -f ssh-keys/id_ed25519 -C \"claude-code-project\""
echo ""
echo "=== カスタマイズ ==="
echo "  config/CLAUDE.md              # Claude Code のルール設定"
echo "  config/.claude/commands/      # カスタムスラッシュコマンド"
echo "  config/.mcp.json              # MCPサーバー設定"
echo "  config/.gitconfig             # Git設定（名前・メールアドレス）"
echo "  mcp-servers/                  # カスタムMCPサーバーの配置先"
echo "  plans/                        # 仕様書・設計ドキュメント（コンテナと同期）"
