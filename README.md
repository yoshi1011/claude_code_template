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

## トラブルシューティング

### Claude Codeが認証エラーになる

- ホストで`claude`コマンドを実行してOAuth認証を完了してください
- `~/.claude`ディレクトリが存在することを確認してください

### SSH接続が失敗する

- macOSの場合、Docker Desktopで「Allow the default Docker socket to be used」が有効か確認
- `make shell`でコンテナに入り、`ssh -T git@github.com`で接続テスト

### パーミッションエラーが発生する

- ホストとコンテナのUID/GIDの不一致が原因の場合があります
- `make shell`で入り、`sudo chown -R claude:claude /workspace`を実行

### Dockerビルドが失敗する

- Docker Desktopが起動しているか確認してください
- `make clean`で既存のイメージを削除してから`make build`を再実行
