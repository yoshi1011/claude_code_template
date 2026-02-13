# Claude Code Docker開発環境テンプレート

Claude Codeをほぼパーミッションフリーで実行するためのDocker環境テンプレートです。コンテナ内で`--dangerously-skip-permissions`フラグ付きでClaude Codeを実行し、ホストの認証情報・SSH設定をシームレスに共有します。

## 前提条件

- Docker / Docker Compose
- Claude Code のOAuth認証済み（ホストの`~/.claude`に認証情報が保存されている状態）
  - または Anthropic API Key

## セットアップ

```bash
# 1. リポジトリをクローン
git clone <this-repo> && cd claude_code_template

# 2. 初回セットアップ（workspace作成、.envコピー、イメージビルド）
make setup
```

API Keyを使用する場合は、`.env`ファイルに`ANTHROPIC_API_KEY`を設定してください。

## 使い方

### インタラクティブモードで起動

```bash
make start
```

### プロンプト付きで実行

```bash
make run PROMPT="Hello, Claude!"
```

### コンテナ内にシェルで入る

```bash
make shell
```

### 後片付け

```bash
make clean
```

## 認証方法

### OAuth認証（推奨）

ホストマシンで事前にClaude Codeにログインしておけば、`~/.claude`ディレクトリがコンテナにマウントされるため、追加設定なしで認証が共有されます。

### API Key認証

`.env`ファイルに以下を設定：

```
ANTHROPIC_API_KEY=sk-ant-xxxxx
```

## プロジェクトでの使い方

1. `workspace/`ディレクトリ内にプロジェクトをクローンまたは作成
2. `make start`でClaude Codeを起動
3. コンテナ内の`/workspace`で作業

```bash
# 例: workspace内にプロジェクトをクローン
cd workspace
git clone git@github.com:your/project.git
```

## SSH/Git連携

- ホストの`~/.ssh`がコンテナに読み取り専用でマウントされます
- ホストの`~/.gitconfig`が共有されます
- macOSのSSH Agent Forwardingに対応しています

## プロジェクト設定のカスタマイズ

`config/` ディレクトリでClaude Codeの動作をカスタマイズできます。コンテナ起動時に `entrypoint.sh` が各ファイルを `/workspace` にシンボリックリンクとして配置します。

**ワークスペースのプロジェクトに同名ファイルが存在する場合はリンクをスキップ**し、プロジェクト側の設定が優先されます。

| ファイル | 用途 |
|---------|------|
| `config/CLAUDE.md` | Claude Code のルール・指示設定 |
| `config/.claude/settings.json` | プロジェクト設定 |
| `config/.mcp.json` | MCPサーバー設定 |

ホスト側で `config/CLAUDE.md` を編集すると、シンボリックリンク経由でコンテナ内にも即時反映されます。

## カスタムコマンド（Skills）の追加

`config/.claude/commands/` にMarkdownファイルを配置すると、Claude Code のスラッシュコマンドとして利用できます。

```
config/.claude/commands/
└── review.md    # /review コマンド
```

コマンドファイル内で `$ARGUMENTS` を使うと、スラッシュコマンドの引数が展開されます。

例: `config/.claude/commands/review.md`

```markdown
以下のコードをレビューしてください。

レビュー観点:
- バグや潜在的な問題がないか
- セキュリティ上の懸念がないか

対象: $ARGUMENTS
```

使い方: Claude Code で `/review src/main.js` と入力

## MCPサーバーの構成

3つのパターンでMCPサーバーを構成できます。

### パターンA: NPX/UVX（公開MCPサーバーの利用）

`config/.mcp.json` に設定を追加するだけで、自動的にダウンロード・実行されます。

```json
{
  "mcpServers": {
    "filesystem": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-filesystem", "/workspace"]
    },
    "fetch": {
      "command": "uvx",
      "args": ["mcp-server-fetch"]
    }
  }
}
```

### パターンB: カスタムMCPサーバー（stdio）

`mcp-servers/` にソースコードを配置し、`config/.mcp.json` で参照します。

```json
{
  "mcpServers": {
    "my-server": {
      "command": "node",
      "args": ["/home/claude/mcp-servers/my-server/index.js"]
    }
  }
}
```

詳細は `mcp-servers/README.md` を参照してください。

### パターンC: サイドカーコンテナ（SSE/Streamable HTTP）

独立した環境が必要なMCPサーバーは、`docker-compose.override.yml` でサイドカーコンテナとして起動します。

```bash
# サンプルをコピーして編集
cp docker-compose.override.yml.example docker-compose.override.yml
```

`config/.mcp.json` でHTTPエンドポイントを指定:

```json
{
  "mcpServers": {
    "remote-server": {
      "type": "sse",
      "url": "http://mcp-example:3001/sse"
    }
  }
}
```

## トラブルシューティング

### Claude Codeが認証エラーになる

- ホストで`claude`コマンドを実行してOAuth認証を完了してください
- `~/.claude`ディレクトリが存在することを確認してください

### SSH接続が失敗する

- macOSの場合、Docker Desktopで「Allow the default Docker socket to be used」が有効か確認
- `make shell`でコンテナに入り、`ssh -T git@github.com`で接続テスト
- macOSの`UseKeychain`等のSSHオプションはentrypoint.shで自動的に`IgnoreUnknown`が付与されるため、通常は問題になりません

### パーミッションエラーが発生する

- ホストとコンテナのUID/GIDの不一致が原因の場合があります
- `make shell`で入り、`sudo chown -R claude:claude /workspace`を実行

### Dockerビルドが失敗する

- Docker Desktopが起動しているか確認してください
- `make clean`で既存のイメージを削除してから`make build`を再実行
