FROM rust:1.61-slim-buster as build-tools
RUN rustup toolchain install nightly && rustup default nightly && rustup component add rustfmt
RUN apt-get update && apt-get install -y git pkg-config libudev-dev make libclang-dev clang cmake

FROM build-tools as build-validator

ARG SOLANA_VERSION
RUN git clone -b $SOLANA_VERSION --depth 1 https://github.com/solana-labs/solana
WORKDIR solana
RUN --mount=type=cache,target=/usr/local/cargo/registry \
    --mount=type=cache,target=/solana/target/release/build \
    --mount=type=cache,target=/solana/target/release/deps \
    --mount=type=cache,target=/solana/target/release/incremental \
    cargo build --release

FROM debian:bullseye-slim as final

RUN apt-get update && apt-get install -y bzip2
VOLUME ["/var/lib/solana-ledger"]
COPY --from=build-validator /solana/target/release/* /usr/local/bin
