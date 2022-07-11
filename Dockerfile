
# rust 1.59 due to cargo-install-all getting solana-perf-v0.19.3.tgz
# this may not work on arm64?
FROM rust:1.59-slim-bullseye as build-tools
RUN rustup toolchain install nightly && rustup default nightly && rustup component add rustfmt
RUN apt-get update && apt-get install -y build-essential libssl-dev git pkg-config libudev-dev make libclang-dev clang cmake curl

FROM build-tools as build-validator

ARG SOLANA_VERSION
RUN git clone -b $SOLANA_VERSION --depth 1 https://github.com/solana-labs/solana
WORKDIR /solana
RUN --mount=type=cache,target=/usr/local/cargo/registry \
    --mount=type=cache,target=/solana/target/release/build \
    --mount=type=cache,target=/solana/target/release/deps \
    --mount=type=cache,target=/solana/target/release/incremental \
    ./scripts/cargo-install-all.sh /usr/local/

#cargo build --release

FROM build-validator as build-anchor

#RUN apt update && apt install -yq build-essential libssl-dev pkg-config
RUN cargo install --git https://github.com/project-serum/anchor avm --locked --force \
    && avm install latest \
    && avm use latest

FROM debian:bullseye-slim as minimal-validator

RUN apt-get update && apt-get install -y bzip2
VOLUME ["/var/lib/solana-ledger"]
COPY --from=build-validator /usr/local/bin/* /usr/local/bin

# Anchor and avm have a really weird relationship atm - so its complicated to just use an anchor binary
COPY --from=build-anchor /usr/local/cargo/bin/avm /usr/local/cargo/bin/anchor /usr/local/bin
COPY --from=build-anchor /root/.avm /root/.avm

# HACK: Temporary until we can figure out a way to install BPF tool
RUN anchor init bpf-install && cd bpf-install && anchor build && cd && rm -r bpf-install

FROM build-tools as rust-and-nodejs

# Set the SHELL to bash with pipefail option
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# Prevent dialog during apt install
ENV DEBIAN_FRONTEND noninteractive

# we need a .bashrc  for install.sh to work
RUN touch ~/.bashrc && chmod +x ~/.bashrc

RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.1/install.sh | bash ;

ENV NODE_VERSION=16.15.1

# relevant code I pasted from above link
# nvm
RUN echo 'export NVM_DIR="$HOME/.nvm"'                                       >> "$HOME/.bashrc"
RUN echo '[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"  # This loads nvm' >> "$HOME/.bashrc"
RUN echo '[ -s "$NVM_DIR/bash_completion" ] && . "$NVM_DIR/bash_completion" # This loads nvm bash_completion' >> "$HOME/.bashrc"


# nodejs and tools
RUN bash -c 'source $HOME/.nvm/nvm.sh   && \
    nvm install $NODE_VERSION && nvm use $NODE_VERSION && nvm alias default $NODE_VERSION       && \
    npm install -g doctoc urchin eclint dockerfile_lint && \
    npm install --prefix "$HOME/.nvm/"'

FROM rust-and-nodejs as amman-validator
# https://hub.docker.com/_/node/
# this is so we can use https://amman-explorer.metaplex.com/#/guide
RUN apt-get update && apt-get install -y bzip2
VOLUME ["/var/lib/solana-ledger"]

COPY --from=build-validator /usr/local/bin/* /usr/local/bin

# Anchor and avm have a really weird relationship atm - so its complicated to just use an anchor binary
COPY --from=build-anchor /usr/local/cargo/bin/avm /usr/local/cargo/bin/anchor /usr/local/bin
COPY --from=build-anchor /root/.avm /root/.avm

RUN bash -c 'source $HOME/.nvm/nvm.sh \
    && npm install --location=global @metaplex-foundation/amman'

WORKDIR /test-ledger

ENV BPF_SDK_PATH /usr/local/bin/bpf

ENTRYPOINT ["amman"]
CMD ["start"]

# TODO: need to set where the validator data goes - atm, it sits in /usr/local/bin/ :/
# TODO: infact, make the container readonly, and require a volume...

# TODO: need a default .ammanrc.json