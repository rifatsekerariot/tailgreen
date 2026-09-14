#!/bin/sh
# TailGreen: Tor Anonymizing SOCKS5 Proxy Setup Script for postmarketOS
set -e

echo "==> [TailGreen] Tor Paketi Yükleniyor..."
sudo apk add tor curl

echo "==> [TailGreen] Tor Konfigürasyonu Oluşturuluyor (/etc/tor/torrc)..."
sudo mkdir -p /var/log/tor /var/lib/tor
sudo chown -R tor:tor /var/log/tor /var/lib/tor

sudo sh -c 'cat << "EOF" > /etc/tor/torrc
DataDirectory /var/lib/tor
SocksPort 0.0.0.0:9050
SocksPolicy accept 192.168.100.0/24
SocksPolicy accept 100.64.0.0/10
SocksPolicy accept 127.0.0.1
SocksPolicy reject *
Log notice stdout
EOF'

echo "==> [TailGreen] Tor Systemd Servis Birimi Tanımlanıyor..."
sudo sh -c 'cat << "EOF" > /etc/systemd/system/tor.service
[Unit]
Description=Tor Anonymizing Overlay Network
After=network.target

[Service]
Type=simple
User=tor
ExecStart=/usr/sbin/tor -f /etc/tor/torrc
Restart=on-failure
LimitNOFILE=65536

[Install]
WantedBy=multi-user.target
EOF'

echo "==> [TailGreen] Tor Servisi Yeniden Başlatılıyor..."
sudo systemctl daemon-reload
sudo systemctl reset-failed tor || true
sudo systemctl enable --now tor

echo "==> [TailGreen] Tor Bağlantısı Doğrulanıyor (SOCKS5)..."
sleep 3
curl --socks5-hostname 127.0.0.1:9050 -s https://check.torproject.org/api/ip || echo "Tor ağı ayağa kalkıyor, birkaç saniye içinde aktif olacaktır."

echo "==> [TailGreen] Tor Kurulumu Tamamlandı!"
