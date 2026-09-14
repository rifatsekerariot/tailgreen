# 🛠️ TailGreen: Ayrıntılı Derleme ve Yükleme Kılavuzu

Bu kılavuz, eski bir Samsung Galaxy S4 (GT-I9505 / `samsung-jflte`) cihazının **yerel bir Ubuntu sunucusu üzerinde nasıl derlendiğini, karşılaşılan macOS tuzaklarını ve cihaza nasıl yüklendiğini (flashing)** tüm teknik detaylarıyla açıklamaktadır.

---

## 🖥️ 1. Neden Yerel Sunucu (Ubuntu) Kullanıldı? (Kritik Teknik Detay)

İlk denemelerde macOS üzerinde Android Platform-Tools (Fastboot v35+) kullanıldığında, Android 15 SDK ile gelen **AVB (Android Verified Boot) footer denetimi** nedeniyle şu hata ile karşılaşılmıştır:

```text
fastboot: error: Failed reading from userdata (AVB footer check die)
```

Modern fastboot sürümleri, eski MBR tabanlı Android telefonların `userdata` bölümüne ham bir Linux disk imajı yazılmasına güvenlik gerekçesiyle engel olmaktadır.

### 💡 Çözüm: Yerel Linux Sunucusuna Geçiş
Bu engeli aşmak ve tam yerel donanım erişimi sağlamak için derleme ve yükleme işlemleri doğrudan ağdaki bir **Yerel Ubuntu/Debian Sunucusuna** taşınmıştır:
- **Yerel Sunucu:** Ubuntu Linux x86_64
- **Fastboot Sürümü:** Debian `34.0.4-debian` (AVB kısıtlamasından etkilenmeyen kararlı sürüm)
- **Flaşlayıcı:** `heimdall-flash v2.0.2`
- **Derleyici:** `pmbootstrap 3.11.1`

---

## 🔒 2. Adım: Orijinal Android Bölümlerinin Yedeklenmesi

Cihaz henüz orijinal halindeyken (TWRP veya rootlu Android üzerinden) kritik donanım bölümlerinin ham yedeği alınmıştır:

```bash
# EFS bölümü (IMEI, MAC adresleri ve radyo kalibrasyonu)
dd if=/dev/block/mmcblk0p10 of=/sdcard/backup/efs.img bs=4096

# Boot ve Recovery bölümleri
dd if=/dev/block/mmcblk0p20 of=/sdcard/backup/boot.img bs=4096
dd if=/dev/block/mmcblk0p21 of=/sdcard/backup/recovery.img bs=4096
```
> ⚠️ Bu yedekler `phone_backup/backup/` dizininde kalıcı olarak saklanmalıdır.

---

## 🏗️ 3. Adım: Yerel Sunucu Üzerinde postmarketOS Derlemesi

Yerel Linux sunucusu üzerinde `pmbootstrap` aracı kuruldu ve yapılandırıldı:

```bash
# 1. pmbootstrap kurulumu
pipx install pmbootstrap
export PATH=$PATH:$HOME/.local/bin

# 2. Cihaz hedefi yapılandırması
pmbootstrap init
# Hedef Üretici/Cihaz : samsung / jflte (Samsung Galaxy S4 LTE)
# Arayüz (UI)         : phosh (daha sonra tty/console'a çevrildi)
# Kullanıcı Adı       : linuxuser (veya tercih ettiğiniz kullanıcı)
# Şifre               : <GÜÇLÜ_BİR_ŞİFRE>
# Saat Dilimi         : Europe/Istanbul
# Klavye              : tr

# 3. Alpine Linux Chroot Derleme Süreci
pmbootstrap install
```

Bu işlem sonucunda sunucu üzerinde chroot içerisinde **2.9 GB boyutunda MBR formatlı** saf bir Linux disk imajı oluşturuldu:
```text
~/.local/var/pmbootstrap/chroot_native/home/pmos/rootfs/samsung-jflte.img
```

---

## ⚡ 4. Adım: İkincil Önyükleyici (`lk2nd`) Kurulumu (Heimdall)

Samsung Galaxy S4 (Qualcomm Snapdragon 600 - APQ8064), standart Samsung bootloader'ı ile mainline Linux çekirdeğini doğrudan başlatamaz. Bunun için cihazın `BOOT` bölümüne **`lk2nd` (Little Kernel ikincil önyükleyicisi)** yüklenir.

1. Telefon **Download Moduna** alındı:  
   `Ses Kısma + Ana Ekran (Home) + Güç Tuşu` kombinasyonuna basılı tutuldu, gelen ekranda `Ses Açma` ile onaylandı.
2. Telefon doğrudan **Yerel Sunucunun USB portuna** takıldı (`04e8:685d Samsung MSM8960` olarak algılandı).
3. Sunucu üzerinden Heimdall ile flaşlama yapıldı:

```bash
sudo heimdall flash --BOOT ~/lk2nd.img --no-reboot
```
`BOOT upload successful` yanıtından sonra cihaz otomatik olarak `lk2nd` ile yeniden başladı.

---

## 💾 5. Adım: Rootfs İmajının Userdata Bölümüne Flaşlanması

Cihaz yeniden başladığında `lk2nd` devreye girdi ve ekranda **Fastboot Modu** belirdi:

```bash
# 1. Sunucu üzerinde cihazın fastboot modunda olduğunu doğrulayın:
sudo fastboot devices
# Çıktı: d00f1628  fastboot

# 2. pmbootstrap ile rootfs imajını 'userdata' bölümüne flaşlayın:
pmbootstrap flasher flash_rootfs --partition userdata
```

**Gerçekleşen Flaşlama Süreci:**  
Sunucudaki Debian fastboot, 2.9GB'lık ham Linux disk imajını otomatik olarak 3 parçaya (sparse) böldü ve telefona aktardı:
- `Sending sparse 'userdata' 1/3 (784730 KB) -> OKAY [24.8s]`
- `Writing 'userdata' -> OKAY [203.5s]`
- `Sending sparse 'userdata' 2/3 (774442 KB) -> OKAY [24.3s]`
- `Writing 'userdata' -> OKAY [28.7s]`
- `Sending sparse 'userdata' 3/3 (80720 KB)  -> OKAY [2.5s]`
- `Writing 'userdata' -> OKAY [74.1s]`
- **Toplam Flaşlama Süresi:** ~360 saniye (6 dakika)

```bash
# 3. Cihazı postmarketOS ile yeniden başlatın:
sudo fastboot reboot
```

---

## 🔌 6. Adım: Yerel Sunucu İçin Otomatik USB Ağ Kuralı (Udev)

Telefon USB'den takılıyken bağlantının her kopup yeniden bağlanmasında sunucunun anında IP ataması için sunucuya kalıcı bir udev kuralı eklendi:

```bash
# /etc/udev/rules.d/99-phone-usb.rules
# (Gerektiğinde IP bloğunu kendi ağ yapılandırmanıza göre belirleyebilirsiniz)
SUBSYSTEM=="net", ACTION=="add", KERNEL=="enx*", RUN+="/bin/sh -c 'ip addr add 172.16.0.2/24 dev %k 2>/dev/null; ip link set dev %k up'"
```

Kurallar yeniden yüklendi:
```bash
sudo udevadm control --reload-rules
```
Böylece telefon sunucuya takıldığı anda sunucu ile cihaz arasında anında doğrudan bir USB ağ arayüzü ayağa kalkar ve doğrudan SSH erişimi kesintisiz sağlanır.

---

## 📺 7. Adım: Ekranın Saf TTY1 Konsoluna Çevrilmesi

Telefon ilk açıldığında Wayland tabanlı grafik arayüz (Phosh) çalışıyordu. Sunucu/Gateway modunda pil ve RAM tasarrufu sağlamak için grafik katmanı kapatıldı:

```bash
# 1. Grafik servislerini devre dışı bırak
sudo systemctl stop greetd
sudo systemctl disable greetd
sudo systemctl set-default multi-user.target

# 2. Uyku / Suspend modlarını engelle (7/24 kesintisiz çalışması için)
sudo systemctl mask sleep.target suspend.target hibernate.target hybrid-sleep.target

# 3. Kernel loglarını ve login istemini AMOLED ekrana yönlendir
# /boot/extlinux/extlinux.conf dosyasında 'quiet splash' parametreleri yerine:
# console=tty0 console=tty1 fbcon=map:0
sudo sed -i 's/quiet splash plymouth.ignore-serial-consoles plymouth.prefer-fbcon/console=tty0 console=tty1 fbcon=map:0/g' /boot/extlinux/extlinux.conf

# 4. TTY1 getty servisini başlat
sudo systemctl enable --now getty@tty1
```

Artık cihaz açılırken tüm Linux çekirdek logları doğrudan telefon ekranında akar ve açıldığında ekranda doğrudan `samsung-jflte login:` istemi yer alır.

---

## 🚀 8. Adım: Wi-Fi, Tailscale ve Tor Gateway Kurulumu

Telefon yerel Wi-Fi ağına bağlandı ve bağımsız bir ağ geçidi yapıldı:

```bash
# 1. Wi-Fi bağlantısı
sudo nmcli dev wifi connect "KABLOSUZ_AG_ADINIZ" password "KABLOSUZ_AG_SIFRENIZ"
# Cihaz yerel ağdan otomatik DHCP IP'sini alacaktır (Örn: 192.168.1.50)

# 2. IP Forwarding (Çekirdek yönlendirmesi)
echo 'net.ipv4.ip_forward = 1' | sudo tee /etc/sysctl.d/99-tailscale.conf
sudo sysctl -p /etc/sysctl.d/99-tailscale.conf

# 3. Tailscale ve Tor kurulumu
sudo apk add tailscale tailscale-systemd tor curl
sudo systemctl enable --now tailscaled

# 4. Tailscale Subnet Router ve Exit Node olarak başlatma
# (192.168.1.0/24 yerine kendi yerel alt ağınızı yazabilirsiniz)
sudo tailscale up --advertise-exit-node --advertise-routes=192.168.1.0/24 --hostname=galaxy-s4-gateway
```

Tailscale admin panelinden onay verilerek işlem tamamlandı!
