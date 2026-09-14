#!/bin/sh
# TailGreen: Headless Mode & Framebuffer Console (TTY1) Setup Script for postmarketOS
set -e

echo "==> [TailGreen] Grafik Arayüz (Phosh/Greetd) Kapatılıyor..."
sudo systemctl stop greetd 2>/dev/null || true
sudo systemctl disable greetd 2>/dev/null || true
sudo systemctl set-default multi-user.target

echo "==> [TailGreen] Güç Tasarrufu / Uyku Modları Maskeleniyor (7/24 Kesintisiz)..."
sudo systemctl mask sleep.target suspend.target hibernate.target hybrid-sleep.target

echo "==> [TailGreen] Kernel Logları ve TTY Konsolu Ekrana Veriliyor..."
if [ -f /boot/extlinux/extlinux.conf ]; then
    sudo sed -i 's/quiet splash plymouth.ignore-serial-consoles plymouth.prefer-fbcon/console=tty0 console=tty1 fbcon=map:0/g' /boot/extlinux/extlinux.conf
fi
sudo systemctl mask plymouth-start plymouth-quit plymouth-quit-wait 2>/dev/null || true

echo "==> [TailGreen] Getty TTY1 Servisi Etkinleştiriliyor..."
sudo systemctl enable --now getty@tty1

echo "==> [TailGreen] TTY1 Konsoluna Durum Bilgisi Basılıyor..."
sudo sh -c 'cat << "EOF" > /dev/tty1

==============================================
   TAILGREEN: E-ATIKTAN LINUX AG GECIDINE
==============================================
 Cihaz       : Samsung Galaxy S4 (samsung-jflte)
 Kernel      : $(uname -r)
 Tailscale   : Aktif (galaxy-s4-gateway)
 Tor SOCKS5  : Aktif (Port: 9050)
 Durum       : 7/24 Kesintisiz (Dahili Pilli UPS)
==============================================
EOF'

echo "==> [TailGreen] Konsol Yapılandırması Tamamlandı!"
