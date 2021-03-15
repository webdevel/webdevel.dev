ACME_DEST = $(shell cat tasks/.sync-acme-dest)
SERVER_DEST = $(shell cat tasks/.sync-server-dest)
CLIENT_DEST = $(shell cat tasks/.sync-client-dest)
LOGS_SOURCE = $(shell cat tasks/.sync-logs-src)

# --recursive --links --perms --times --devices --specials --verbose --compress --human-readable --rsh=

sync/push/acme: ## Push acme code
	rsync -rlptDvzhe 'ssh' tasks/acme/acme.awk $(ACME_DEST)

sync/push/server: ## Push server code
	rsync -rlptDvzhe 'ssh' src/$(PACKAGE_NAME) $(SERVER_DEST)

sync/push/client: ## Push client code
	rsync -rlptDvzhe 'ssh' public/* $(CLIENT_DEST)

sync/pull/logs: ## Pull server logs
	rsync -rlptDvzhe 'ssh' $(LOGS_SOURCE) var/log/
