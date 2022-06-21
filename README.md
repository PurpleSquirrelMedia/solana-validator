# solana-validator

Solana validator container image built for x64, arm64, arm7 and maybe others.

will include solana validator and amman and some magic entrypoint code to assemble the amman config file

## ideas

I'm contemplating reducing the storage requirements further so I can run it on very small rpi's and laptops

It would rock for it to be possible to make a container image using an amman config, which can install mainnet programs from backed up `.so` files in the container.

