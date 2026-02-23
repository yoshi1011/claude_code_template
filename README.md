# Claude Code Docker開発環境テンプレート

> **⚠️ 開発中断のお知らせ**
>
> このテンプレートの開発は中断されており、今後のメンテナンスや更新の予定はありません。
> 新規プロジェクトでの利用は推奨しません。既存の利用者は、他のソリューションへの移行をご検討ください。

Claude Codeをほぼパーミッションフリーで実行するためのDocker環境テンプレートです。コンテナ内で`--dangerously-skip-permissions`フラグ付きでClaude Codeを実行します。ホスト環境への影響を最小限にするため、認証情報・SSH鍵はプロジェクトローカルで管理します。

## 前提条件

- Docker / Docker Compose
- Anthropic API Key、または初回起動時にコンテナ内で `claude login` を実行

## セットアップ

```bash
# 1. リポジトリをクローン
git clone <this-repo> && cd claude_code_template

# 2. 初回セットアップ（ディレクトリ作成、設定ファイル生成、イメージビルド）
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

初回起動時にコンテナ内で認証を行います:

```bash
make start
# コンテナ内で以下を実行
claude login
```

認証情報は `claude-auth/` ディレクトリに保存され、コンテナの再起動後も維持されます。`claude-auth/` は `.gitignore` に含まれており、リポジトリにはコミットされません。

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

プロジェクト専用のSSH鍵を `ssh-keys/` ディレクトリに配置して使用します。ホストのSSH鍵は共有されません。

### SSH鍵の設定

```bash
# 方法1: 専用の鍵ペアを生成（推奨）
ssh-keygen -t ed25519 -f ssh-keys/id_ed25519 -C "claude-code-project"

# 方法2: 既存の鍵をコピー
cp ~/.ssh/id_ed25519 ssh-keys/
cp ~/.ssh/id_ed25519.pub ssh-keys/
```

生成した公開鍵をGitHubの Deploy Keys 等に登録してください。

### Git設定

`config/.gitconfig` で名前・メールアドレスを設定してください（`make setup` で `.sample` から自動生成されます）:

```ini
[user]
    name = Your Name
    email = your-email@example.com
```

## 仕様書・設計ドキュメントの同期

`plans/` ディレクトリはコンテナ内の `/workspace/plans/` にマウントされます。Claude Code がコンテナ内で作成した仕様書や設計ドキュメントを、ホスト側でリアルタイムに閲覧できます。

```
plans/
├── api-spec.md          # Claude が作成した仕様書
├── architecture.md      # 設計ドキュメント
└── ...
```

CLAUDE.md のデフォルト設定により、Claude Code はドキュメントを `/workspace/plans/` に出力します。`plans/` の中身はGit管理外のため、`git pull` の影響を受けません。

## プロジェクト設定のカスタマイズ

`config/` ディレクトリでClaude Codeの動作をカスタマイズできます。設定ファイルは `.sample` テンプレートから生成され、**Git管理外**のためテンプレートの `git pull` で上書きされません。

```bash
# 初回セットアップ時に自動生成されます（make setup）
# 手動で生成する場合:
cp config/CLAUDE.md.sample config/CLAUDE.md
cp config/.mcp.json.sample config/.mcp.json
cp config/.gitconfig.sample config/.gitconfig
cp config/.claude/settings.json.sample config/.claude/settings.json
cp config/.claude/commands/review.md.sample config/.claude/commands/review.md
```

コンテナ起動時に `entrypoint.sh` が各ファイルを `/workspace` にシンボリックリンクとして配置します。**ワークスペースのプロジェクトに同名ファイルが存在する場合はリンクをスキップ**し、プロジェクト側の設定が優先されます。

| テンプレート | 生成ファイル | 用途 |
|------------|------------|------|
| `config/CLAUDE.md.sample` | `config/CLAUDE.md` | Claude Code のルール・指示設定 |
| `config/.claude/settings.json.sample` | `config/.claude/settings.json` | プロジェクト設定 |
| `config/.mcp.json.sample` | `config/.mcp.json` | MCPサーバー設定 |
| `config/.gitconfig.sample` | `config/.gitconfig` | Git設定（名前・メールアドレス） |

ホスト側で `config/CLAUDE.md` を編集すると、シンボリックリンク経由でコンテナ内にも即時反映されます。

## カスタムコマンド（Skills）の追加

`config/.claude/commands/` にMarkdownファイルを配置すると、Claude Code のスラッシュコマンドとして利用できます。

```
config/.claude/commands/
└── review.md    # /review コマンド
```

コマンドファイル内で `$ARGUMENTS` を使うと、スラッシュコマンドの引数が展開されます。

サンプルの `review.md.sample` が同梱されています。例: `config/.claude/commands/review.md`

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

## セキュリティ

このテンプレートはホスト環境への影響を最小限にする設計を採用しています。詳細は [SECURITY.md](SECURITY.md) を参照してください。

主なセキュリティ機能:
- ホストの `~/.claude`、`~/.ssh`、`~/.gitconfig` をマウントせず、プロジェクトローカルで管理
- SSH Agentソケット非共有（ホストの全SSH鍵へのアクセスを遮断）
- 設定ファイル・MCPサーバーの読み取り専用マウント
- Linux Capabilityの最小化と権限昇格防止

## トラブルシューティング

### Claude Codeが認証エラーになる

- コンテナ内で `claude login` を実行して認証してください
- `claude-auth/` ディレクトリが存在し、書き込み可能であることを確認してください
- API Key認証の場合は `.env` ファイルの `ANTHROPIC_API_KEY` を確認してください

### SSH接続が失敗する

- `ssh-keys/` にSSH秘密鍵が配置されているか確認してください
- `make shell` でコンテナに入り、`ssh -T git@github.com` で接続テスト
- 鍵のパーミッションは entrypoint.sh で自動設定されます
- macOSの `UseKeychain` 等のSSHオプションは entrypoint.sh で自動的に `IgnoreUnknown` が付与されます

### パーミッションエラーが発生する

- ホストとコンテナのUID/GIDの不一致が原因の場合があります
- `make shell`で入り、`sudo chown -R claude:claude /workspace`を実行

### 設定ファイルへの書き込みがエラーになる

- `config/` と `mcp-servers/` は読み取り専用でマウントされています
- 設定を変更する場合はホスト側で編集してください

### Dockerビルドが失敗する

- Docker Desktopが起動しているか確認してください
- `make clean`で既存のイメージを削除してから`make build`を再実行
