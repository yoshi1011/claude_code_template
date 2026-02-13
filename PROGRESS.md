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

## 検証項目

- [ ] `make setup && make build` でエラーなくビルドできること
- [ ] `make start` でClaude Codeが起動すること
- [ ] コンテナ内で `ssh -T git@github.com` が成功すること
- [ ] コンテナ内で `git config user.name` がホストと同じ値を返すこと
- [ ] `--dangerously-skip-permissions` でパーミッション確認なしに動作すること
- [ ] コンテナ再起動後もOAuth認証が維持されること
- [ ] `make shell` で `python3 --version`, `uv --version` が動作すること
- [ ] ワークスペース空の状態でシンボリックリンクが作成されること
- [ ] ワークスペースに既存ファイルがある場合はリンクがスキップされること
- [ ] ホスト側 config/ の編集がコンテナ内に即時反映されること
- [ ] `/review` カスタムコマンドが利用可能なこと
- [ ] `make setup` で .sample から設定ファイルが生成されること
- [ ] `git pull` で config/ のユーザー設定が上書きされないこと
