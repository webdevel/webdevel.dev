SSH_DEST ?= $(shell cat tasks/.ssh-dest)

ssh/log/resource: ## Make resource log directories
	mkdir -vp var/log/resource; \
	ssh $(SSH_DEST) "mkdir -vp /var/log/resource"

ssh/log/resource/packages: ssh/log/resource ## Log remote installed packages
	ssh $(SSH_DEST) "apk info -vv | sort -d | tee /var/log/resource/packages.log"

ssh/log/resource/memory: ## Log remote memory usage
	ssh $(SSH_DEST) "sync && echo '3' > /proc/sys/vm/drop_caches && free -m | tee /var/log/resource/memory.log"

ssh/log/resource/filesystem: ## Log remote filesystem usage
	ssh $(SSH_DEST) "df -h | tee /var/log/resource/filesystem.log"

ssh/log/resource/directories: ## Log remote directories usage
	ssh $(SSH_DEST) "du -s /* | sort -n | tee /var/log/resource/directories.log"
