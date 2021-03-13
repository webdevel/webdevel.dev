.PHONY: help

help: ## Show all make targets and help-messages [find=<topic>]
ifdef find
	@MAKEFILE_LIST="$(MAKEFILE_LIST)" tasks/help.sh -f printMakefileHelpTopic -p "$(find)"
else
	@tasks/help.sh -f printMakefileHelp -p "$(MAKEFILE_LIST)"
endif

help/db: ## Show Makefile.db targets and help-messages
	@tasks/help.sh -f printMakefileHelp -p "tasks/database.mk"

help/docker: ## Show Makefile.docker target and help-messages
	@tasks/help.sh -f printMakefileHelp -p "tasks/docker.mk"

help/go: ## Show Makefile.golang targets and help-messages
	@tasks/help.sh -f printMakefileHelp -p "tasks/golang.mk"

help/help: ## Show Makefile.help targets and help-messages
	@tasks/help.sh -f printMakefileHelp -p "tasks/help.mk"

help/help/script: ## Show Makefile.help shell-script help
	@tasks/help.sh

help/linode: ## Show Makefile.linode targets and help-messages
	@tasks/help.sh -f printMakefileHelp -p "tasks/linode.mk"

help/ssl: ## Show Makefile.ssl targets and help-messages
	@tasks/help.sh -f printMakefileHelp -p "tasks/ssl.mk"

help/sync: ## Show Makefile.sync targets and help-messages
	@tasks/help.sh -f printMakefileHelp -p "tasks/sync.mk"

help/web: ## Show Makefile.web targets and help-messages
	@tasks/help.sh -f printMakefileHelp -p "tasks/web.mk"
