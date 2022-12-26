run:
	GITHUB_USER_TOKEN=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 \
	PGUSER=andreymiskov \
  PGPASSWORD= \
  PGHOST=localhost \
  PGPORT=5432 \
  PGDATABASE=awex \
	iex -S mix phx.server

du:
	docker compose up --build

dlog:
	docker-compose logs awex