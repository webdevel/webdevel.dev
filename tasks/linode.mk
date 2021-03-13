TOKEN ?= $(shell cat tasks/linode/.api-token)
VERSION ?= v4

linode/api/get/types: ## Get available Linode types
	@tasks/linode.sh -f getTypes

linode/api/get/images: ## Get available Linode images
	@tasks/linode.sh -f getImages

linode/api/get/image/ids: ## Get available Linode image ids
	@tasks/linode.sh -f getImageIds