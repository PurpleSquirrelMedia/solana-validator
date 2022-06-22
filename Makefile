

# https://github.com/solana-labs/solana/releases
#SOLANA_VERSION=v1.9.20
SOLANA_VERSION=v1.10.26


build:
	# linux/arm/v6: has no rust image
	# linux/386: 'Failed to find the protoc binary. The PROTOC environment variable is not set, there is no bundled protoc for this platform, and protoc is not in the PATH', /usr/local/cargo/registry/src/github.com-1285ae84e5963aae/prost-build-0.9.0/build.rs:105:10
	# linux/arm/v7: 'Failed to find the protoc binary. The PROTOC environment variable is not set, there is no bundled protoc for this platform, and protoc is not in the PATH', /usr/local/cargo/registry/src/github.com-1285ae84e5963aae/prost-build-0.9.0/build.rs:105:10
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
