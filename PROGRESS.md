# 開発進捗

## 完了済み

- [x] プロジェクト構成の設計
- [x] Dockerfile の作成
- [x] docker-compose.yml の作成
- [x] .env.example の作成
- [x] scripts/start.sh の作成
- [x] scripts/setup.sh の作成
- [x] CLAUDE.md テンプレートの作成
- [x] .gitignore の作成
- [x] Makefile の作成
- [x] README.md の作成

### 設定ファイル・Skills・MCPサーバーの管理構造

- [x] Dockerfile に Python 3 + uv を追加
- [x] config/ ディレクトリの作成（CLAUDE.md, settings.json, commands/review.md, .mcp.json）
- [x] mcp-servers/ ディレクトリの作成（.gitkeep, README.md）
- [x] entrypoint.sh にシンボリックリンク処理を追加
- [x] docker-compose.yml にボリュームマウント追加
- [x] docker-compose.override.yml.example の作成
- [x] setup.sh の更新
- [x] README.md のドキュメント追加
- [x] .gitignore に docker-compose.override.yml を追加
- [x] config ファイルを .sample テンプレート方式に変更（git pull 安全化）

### セキュリティ強化

- [x] docker-compose.yml: ホストマウント（~/.claude, ~/.ssh, ~/.gitconfig, SSH Agent）を削除
- [x] docker-compose.yml: プロジェクトローカルマウント（claude-auth/, ssh-keys/, config/.gitconfig）に置換
- [x] docker-compose.yml: config/ と mcp-servers/ を読み取り専用（:ro）に変更
- [x] docker-compose.yml: cap_drop/cap_add/security_opt によるコンテナ権限制限を追加
- [x] config/.gitconfig.sample の新規作成
- [x] scripts/setup.sh: claude-auth/, ssh-keys/ ディレクトリ作成、.gitconfig 生成を追加
- [x] scripts/entrypoint.sh: コメントをプロジェクトローカル鍵に合わせて更新
- [x] .env.example: SSH Agent Forwarding説明の削除、機密情報注意書きの追加
- [x] .gitignore: claude-auth/, ssh-keys/, config/.gitconfig を追加
- [x] SECURITY.md の新規作成（セキュリティアーキテクチャ・残存リスク・推奨事項）
- [x] README.md: 認証方法・SSH/Git連携・トラブルシューティングの全面更新

## 検証項目

- [ ] `make setup` で claude-auth/, ssh-keys/ ディレクトリが作成されること
- [ ] `make setup` で config/.gitconfig が .sample から生成されること
- [ ] `make build` でDockerイメージがビルドできること
- [ ] `make start` で正常に起動し、コンテナ内で `claude login` で認証できること
- [ ] `ssh-keys/` にSSH鍵を配置し、コンテナ内から `ssh -T git@github.com` が成功すること
- [ ] コンテナ再起動後も `claude-auth/` 経由で認証が維持されること
- [ ] `make clean` 後も `claude-auth/` が残ること（bind mountのため）
- [ ] コンテナ内から `config/` への書き込みが拒否されること（:ro マウント）
- [ ] コンテナ内から `mcp-servers/` への書き込みが拒否されること（:ro マウント）
- [ ] `make shell` で `python3 --version`, `uv --version` が動作すること
- [ ] ワークスペース空の状態でシンボリックリンクが作成されること
- [ ] ワークスペースに既存ファイルがある場合はリンクがスキップされること
- [ ] ホスト側 config/ の編集がコンテナ内に即時反映されること
