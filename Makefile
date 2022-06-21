

# https://github.com/solana-labs/solana/releases
SOLANA_VERSION=v1.9.20
#SOLANA_VERSION=v1.10.26


build:
	# linux/386,linux/arm/v7,linux/arm/v6 fail
	docker buildx build \
		--pull \
		--push \
		--platform linux/amd64,linux/arm64 \
		--build-arg SOLANA_VERSION=$(SOLANA_VERSION) \
		-t daonetes/solana-validator:$(SOLANA_VERSION) \
		.


# docker context create my-context --description "some description" --docker "host=tcp://myserver:2376,ca=~/ca-file,cert=~/cert-file,key=~/key-file"

# TODO: this is something that daonetes could magically bootstrap :)
setup-buildx:
	#docker context create xeon --description "Sven's Xeon box" --docker "host=ssh://xeon"
	#docker context create softiron --description "Sven's arm64 box" --docker "host=ssh://softiron"
	
	#docker buildx create --use --name workbenchbuild default
	docker buildx create --use --name workbenchbuild xeon
	docker buildx create --append --name workbenchbuild softiron
