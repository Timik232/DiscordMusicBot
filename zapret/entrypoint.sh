#!/bin/bash
set -e

QNUM=${ZAPRET_QNUM:-200}
MARK=0x40000000

echo "Setting up iptables rules for DPI bypass..."

# TCP 443 (Discord REST, Gateway, Voice WebSocket signaling)
iptables -t mangle -I POSTROUTING -p tcp --dport 443 \
    -m connbytes --connbytes-dir=original --connbytes-mode=packets --connbytes 1:6 \
    -m mark ! --mark $MARK/$MARK \
    -j NFQUEUE --queue-num $QNUM --queue-bypass

# UDP all ports (Discord voice uses dynamic ports)
iptables -t mangle -I POSTROUTING -p udp \
    -m connbytes --connbytes-dir=original --connbytes-mode=packets --connbytes 1:6 \
    -m mark ! --mark $MARK/$MARK \
    -j NFQUEUE --queue-num $QNUM --queue-bypass

# IPv6 rules (if available)
if ip6tables -L -n >/dev/null 2>&1; then
    ip6tables -t mangle -I POSTROUTING -p tcp --dport 443 \
        -m connbytes --connbytes-dir=original --connbytes-mode=packets --connbytes 1:6 \
        -m mark ! --mark $MARK/$MARK \
        -j NFQUEUE --queue-num $QNUM --queue-bypass 2>/dev/null || true

    ip6tables -t mangle -I POSTROUTING -p udp \
        -m connbytes --connbytes-dir=original --connbytes-mode=packets --connbytes 1:6 \
        -m mark ! --mark $MARK/$MARK \
        -j NFQUEUE --queue-num $QNUM --queue-bypass 2>/dev/null || true
fi

echo "Starting nfqws (queue $QNUM)..."

# Cleanup iptables on exit
cleanup() {
    echo "Cleaning up iptables rules..."
    iptables -t mangle -D POSTROUTING -p tcp --dport 443 \
        -m connbytes --connbytes-dir=original --connbytes-mode=packets --connbytes 1:6 \
        -m mark ! --mark $MARK/$MARK \
        -j NFQUEUE --queue-num $QNUM --queue-bypass 2>/dev/null || true
    iptables -t mangle -D POSTROUTING -p udp \
        -m connbytes --connbytes-dir=original --connbytes-mode=packets --connbytes 1:6 \
        -m mark ! --mark $MARK/$MARK \
        -j NFQUEUE --queue-num $QNUM --queue-bypass 2>/dev/null || true
    ip6tables -t mangle -D POSTROUTING -p tcp --dport 443 \
        -m connbytes --connbytes-dir=original --connbytes-mode=packets --connbytes 1:6 \
        -m mark ! --mark $MARK/$MARK \
        -j NFQUEUE --queue-num $QNUM --queue-bypass 2>/dev/null || true
    ip6tables -t mangle -D POSTROUTING -p udp \
        -m connbytes --connbytes-dir=original --connbytes-mode=packets --connbytes 1:6 \
        -m mark ! --mark $MARK/$MARK \
        -j NFQUEUE --queue-num $QNUM --queue-bypass 2>/dev/null || true
}
trap cleanup EXIT

# nfqws strategies:
# Profile 1: TLS (TCP 443) — fake + multidisorder with split at midsld
# Profile 2: Discord voice (UDP, L7 detection) — fake desync
# Profile 3: QUIC (UDP 443) — fake desync
#
# Tune these params with blockcheck.sh if needed for your ISP
exec nfqws \
    --qnum=$QNUM \
    --filter-tcp=443 \
    --dpi-desync=fake,multidisorder \
    --dpi-desync-split-pos=1,midsld \
    --dpi-desync-fooling=md5sig \
    --new \
    --filter-l7=discord,stun \
    --dpi-desync=fake \
    --dpi-desync-repeats=6 \
    --new \
    --filter-udp=443 \
    --dpi-desync=fake \
    --dpi-desync-repeats=6
