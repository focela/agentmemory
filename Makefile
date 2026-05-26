.PHONY: help up down logs secret

help:
	@printf '%s\n' \
		'Targets:' \
		'  make up      Build and start the stack' \
		'  make down    Stop the stack' \
		'  make logs    Follow container logs' \
		'  make secret  Print AGENTMEMORY_SECRET'

up:
	./scripts/up.sh

down:
	./scripts/down.sh

logs:
	./scripts/logs.sh

secret:
	./scripts/secret.sh
