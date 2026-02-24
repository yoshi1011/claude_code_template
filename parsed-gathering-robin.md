# Claude Code Docker開発環境テンプレート

## Context

Claude Codeをほぼパーミッションフリーで実行するために、Docker環境を手軽に構築できるテンプレートを作成する。コンテナ内でClaude Codeを`--dangerously-skip-permissions`で実行し、OAuth認証はホストの`~/.claude`をマウントして共有する。SSH/Git設定もシームレスに利用可能にする。

## 作成ファイル一覧

### 1. `Dockerfile`
- ベースイメージ: `ubuntu:24.04`
- インストールするもの:
  - git, curl, openssh-client, zsh, ripgrep, jq, sudo
  - Node.js 20 (NodeSource経由)
  - Claude Code (`curl -fsSL https://claude.ai/install.sh | bash`)
  - GitHub CLI (gh)
- SSHのknown_hosts事前設定 (github.com)
- 非rootユーザー `claude` を作成（sudo権限付き）
- WORKDIR: `/workspace`

### 2. `docker-compose.yml`
- サービス: `claude-dev`
- ボリュームマウント:
  - `${HOME}/.claude:/home/claude/.claude` — 認証情報・設定の共有
  - `${HOME}/.ssh:/home/claude/.ssh:ro` — SSH鍵（読み取り専用）
  - `${HOME}/.gitconfig:/home/claude/.gitconfig:ro` — Git設定
  - `./workspace:/workspace` — 作業ディレクトリ
  - SSH_AUTH_SOCKフォワーディング（macOS対応）
- 環境変数: `.env`ファイルから読み込み
- `stdin_open: true`, `tty: true` でインタラクティブ対応

### 3. `.env.example`
- `ANTHROPIC_API_KEY=` (OAuth使用時は空でOK、API Key使用時用)
- macOSのSSH_AUTH_SOCK パスの説明コメント

### 4. `scripts/start.sh`
- Claude Codeの起動スクリプト
- `--dangerously-skip-permissions`フラグ付きで起動
- プロンプト引数の受け渡し対応（`-p`オプション）
- 引数なしの場合はインタラクティブモードで起動

### 5. `scripts/setup.sh`
- 初回セットアップスクリプト
- workspaceディレクトリの作成
- `.env`ファイルのコピー（存在しない場合）
- Dockerイメージのビルド

### 6. `CLAUDE.md`（テンプレート用）
- プロジェクト用のCLAUDE.mdテンプレート
- コンテナ内での作業を前提とした基本設定

### 7. `.gitignore`
- `.env`, `workspace/`, `.DS_Store` 等

### 8. `README.md`
- セットアップ手順
- 使い方（起動方法、認証方法、プロジェクト作成方法）
- トラブルシューティング

### 9. `Makefile`
- `make setup` — 初回セットアップ
- `make build` — Dockerイメージビルド
- `make start` — Claude Code起動（インタラクティブ）
- `make run PROMPT="..."` — プロンプト付き実行
- `make shell` — コンテナ内にシェルで入る
- `make clean` — コンテナ・イメージの削除

## ディレクトリ構成

```
claude_code_template/
├── Dockerfile
├── docker-compose.yml
├── .env.example
├── .gitignore
├── CLAUDE.md
├── Makefile
├── README.md
├── scripts/
│   ├── start.sh
│   └── setup.sh
└── workspace/          # (gitignore対象、作業用)
```

## macOS SSH対応

macOSではSSH_AUTH_SOCKのパスが特殊(`/run/host-services/ssh-auth.sock`)なので、docker-compose.ymlでmacOS/Linux両対応にする。

## 検証方法

1. `make setup && make build` でエラーなくビルドできること
2. `make start` でClaude Codeが起動すること
3. コンテナ内で `ssh -T git@github.com` が成功すること
4. コンテナ内で `git config user.name` がホストと同じ値を返すこと
5. `--dangerously-skip-permissions` でパーミッション確認なしに動作すること
6. コンテナ再起動後もOAuth認証が維持されること
