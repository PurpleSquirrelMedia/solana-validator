[![Docker](https://img.shields.io/badge/Docker-Image-green)](https://hub.docker.com/r/daonetes/solana-amman/tags)

# solana-amman

Solana validator container image built for x64, arm64, arm7 and maybe others.

includes solana validator and amman and later, some magic entrypoint code to assemble the amman config file

## ideas

I'm contemplating reducing the storage requirements further so I can run it on very small rpi's and laptops

It would rock for it to be possible to make a container image using an amman config, which can install mainnet programs from backed up `.so` files in the container.

