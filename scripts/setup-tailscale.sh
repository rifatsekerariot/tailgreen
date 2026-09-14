#!/bin/sh
# TailGreen: Tailscale & Network Routing Setup Script for postmarketOS
set -e

echo "==> [TailGreen] IP Yönlendirme Etkinleştiriliyor..."
echo 'net.ipv4.ip_forward = 1' | sudo tee /etc/sysctl.d/99-tailscale.conf
echo 'net.ipv6.conf.all.forwarding = 1' | sudo tee -a /etc/sysctl.d/99-tailscale.conf
sudo sysctl -p /etc/sysctl.d/99-tailscale.conf

echo "==> [TailGreen] Tailscale ve Bağımlılıkları Yükleniyor..."
sudo apk update
sudo apk add tailscale tailscale-systemd iptables

echo "==> [TailGreen] Tailscale Servisi Başlatılıyor..."
sudo systemctl enable --now tailscaled

echo "==> [TailGreen] Tailscale Ağına Bağlanılıyor (Exit-Node & Subnet Route)..."
LOCAL_SUBNET="${1:-192.168.1.0/24}"
sudo tailscale up --advertise-exit-node --advertise-routes="$LOCAL_SUBNET" --hostname=galaxy-s4-gateway --reset

echo "==> [TailGreen] Kurulum Başarılı! (Alt ağ: $LOCAL_SUBNET)"
tailscale status
