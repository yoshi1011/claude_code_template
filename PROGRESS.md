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

## 検証項目

- [ ] `make setup && make build` でエラーなくビルドできること
- [ ] `make start` でClaude Codeが起動すること
- [ ] コンテナ内で `ssh -T git@github.com` が成功すること
- [ ] コンテナ内で `git config user.name` がホストと同じ値を返すこと
- [ ] `--dangerously-skip-permissions` でパーミッション確認なしに動作すること
- [ ] コンテナ再起動後もOAuth認証が維持されること
