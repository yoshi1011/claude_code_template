.PHONY: setup build start run shell clean

# 初回セットアップ
setup:
	@bash scripts/setup.sh

# Dockerイメージのビルド
build:
	docker compose build

# Claude Code起動（インタラクティブモード）
start:
	docker compose run --rm claude-dev

# プロンプト付き実行（例: make run PROMPT="Hello"）
run:
	docker compose run --rm claude-dev $(PROMPT)

# コンテナ内にシェルで入る（entrypoint経由でSSH設定が初期化される）
shell:
	docker compose run --rm claude-dev /bin/zsh

# コンテナ・イメージの削除
clean:
	docker compose down --rmi local --volumes --remove-orphans
