#!/bin/sh
# TailGreen: Host Server USB Auto-Connect Udev Rule
# Telefon herhangi bir sunucuya USB kablosuyla takıldığında otomatik IP atayan udev kuralı.
set -e

echo "==> [TailGreen Host] Udev Kuralı Ekleniyor (/etc/udev/rules.d/99-tailgreen-usb.rules)..."
echo 'SUBSYSTEM=="net", ACTION=="add", KERNEL=="enx*", RUN+="/bin/sh -c \"ip addr add 172.16.42.2/24 dev %k 2>/dev/null; ip link set dev %k up\""' | sudo tee /etc/udev/rules.d/99-tailgreen-usb.rules

echo "==> [TailGreen Host] Udev Kuralları Yeniden Yükleniyor..."
sudo udevadm control --reload-rules

echo "==> [TailGreen Host] Başarılı! Telefon USB'den bağlandığında sunucu anında 172.16.42.2 IP'sini alacaktır."
