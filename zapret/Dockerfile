FROM debian:bookworm-slim AS builder

RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential git ca-certificates \
    libnetfilter-queue-dev libcap-dev zlib1g-dev \
    && rm -rf /var/lib/apt/lists/*

RUN git clone --depth=1 https://github.com/bol-van/zapret.git /opt/zapret
WORKDIR /opt/zapret
RUN make -C nfq

FROM debian:bookworm-slim

RUN apt-get update && apt-get install -y --no-install-recommends \
    iptables libnetfilter-queue1 libcap2 \
    && rm -rf /var/lib/apt/lists/*

COPY --from=builder /opt/zapret/nfq/nfqws /usr/local/bin/nfqws
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
