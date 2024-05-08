FROM rustlang/rust:nightly


ARG PROFILE=release
WORKDIR /aya

# Upcd dates core parts
RUN apt-get update -y && \
	apt-get install -y cmake pkg-config libssl-dev git gcc build-essential clang libclang-dev protobuf-compiler

# Install rust wasm. Needed for substrate wasm engine
RUN rustup target add wasm32-unknown-unknown
RUN rustup component add rust-src

# Download Frontier repo
RUN git clone https://github.com/worldmobilegroup/aya-node /aya
RUN cd /aya && git submodule init && git submodule update

# Download rust dependencies and build the rust binary
RUN cargo build "--$PROFILE"

# 303033 for p2p traffic
# 9933 for RPC call
# 9944 for Websocket
# 9615 for Prometheus (metrics)
EXPOSE 30333 9933 9944 9615


ENV PROFILE ${PROFILE}

# The execution will re-compile the project to run it
# This allows to modify the code and not have to re-compile the
# dependencies.
CMD cargo run --bin aya-node "--$PROFILE" -- --dev