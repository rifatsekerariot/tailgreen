# 🛠️ TailGreen: Adım Adım Kurulum Kılavuzu

Bu belge, eski bir Samsung Galaxy S4 (GT-I9505 / `samsung-jflte`) veya uyumlu herhangi bir Android cihazı saf bir **postmarketOS (Alpine Linux)** sunucusuna ve **TailGreen VPN/Tor Gateway**'e dönüştürme adımlarını anlatır.

---

## 📋 1. Gereksinimler

- **Cihaz:** Samsung Galaxy S4 LTE (`GT-I9505` / Qualcomm Snapdragon 600 - APQ8064T)
- **Host Bilgisayar:** Linux (Ubuntu/Debian önerilir) veya macOS
- **Yazılımlar:**
  - `pmbootstrap` (postmarketOS derleme aracı)
  - `heimdall-flash` (Samsung Download modu flaşlayıcı)
  - `fastboot` (Android Platform-Tools)
  - USB 2.0 / Micro-USB Veri Kablosu

---

## 🔒 2. Adım: Orijinal Bölüm Yedekleri (Önlem)

Cihaza herhangi bir müdahale yapmadan önce `EFS`, `BOOT` ve `RECOVERY` bölümlerinin yedeğini mutlaka alın:

```bash
# EFS (IMEI ve radyo kalibrasyon verileri)
dd if=/dev/block/mmcblk0p10 of=/sdcard/backup/efs.img bs=4096

# Boot ve Recovery
dd if=/dev/block/mmcblk0p20 of=/sdcard/backup/boot.img bs=4096
dd if=/dev/block/mmcblk0p21 of=/sdcard/backup/recovery.img bs=4096
```

---

## ⚙️ 3. Adım: postmarketOS İmajının Hazırlanması

`pmbootstrap` kullanarak cihaz için optimize edilmiş imaj oluşturulur:

```bash
# pmbootstrap kurulumu
pip install --user pmbootstrap

# Başlatma ve yapılandırma
pmbootstrap init
# Cihaz: samsung-jflte
# Arayüz (UI): phosh veya console
# Kullanıcı adı: ariot
# Şifre / PIN: 1453

# İmajın derlenmesi
pmbootstrap install
```

---

## ⚡ 4. Adım: İkincil Önyükleyici (`lk2nd`) Kurulumu

Qualcomm MSM8960 / APQ8064 cihazlarda saf mainline Linux çekirdeğini başlatabilmek için `lk2nd` ikincil önyükleyicisi gereklidir.

1. Telefonu **Download Moduna** alın (`Ses Kısma + Ana Ekran (Home) + Güç`).
2. USB ile bilgisayara bağlayın.
3. Heimdall ile `lk2nd.img` dosyasını `BOOT` bölümüne flaşlayın:

```bash
heimdall flash --BOOT /path/to/lk2nd.img --no-reboot
```

---

## 💾 5. Adım: postmarketOS Rootfs İmajının Yüklenmesi

Telefon yeniden başladığında `lk2nd` devreye girer ve ekranda **Fastboot Modu** görünür:

```bash
# Cihazın fastboot modunda algılandığını doğrulayın:
fastboot devices
# Çıktı: d00f1628  fastboot

# Rootfs imajını 'userdata' bölümüne flaşlayın:
pmbootstrap flasher flash_rootfs --partition userdata

# Cihazı yeniden başlatın:
fastboot reboot
```

---

## 🌐 6. Adım: Wi-Fi ve Otomasyon Yapılandırması

Cihaz açıldığında USB ağ arayüzü (`172.16.42.1`) üzerinden SSH ile bağlanın:

```bash
ssh ariot@172.16.42.1
# Şifre: 1453
```

Wi-Fi ağınıza bağlanın:
```bash
sudo nmcli dev wifi connect "AG_ADINIZ" password "SIFRENIZ"
```

Artık cihazın USB kablosuna bağımlılığı kalmamıştır; yerel ağınızdaki IP üzerinden (örneğin `192.168.100.8`) çalışır.

---

## 🚀 7. Adım: TailGreen Servislerinin Kurulması

Depoyu cihaza çekin veya betikleri çalıştırın:

```bash
# 1. Konsol ve TTY moduna geçiş (Arayüzsüz / Enerji tasarruflu)
sudo sh scripts/setup-tty-console.sh

# 2. Tailscale ve Ağ Yönlendirme kurulumu
sudo sh scripts/setup-tailscale.sh

# 3. Tor SOCKS5 Anonimleştirme servisi
sudo sh scripts/setup-tor.sh
```

Terminalde ve telefonun kendi AMOLED ekranında beliren Tailscale linkini tarayıcınızda açıp onaylayarak kurulumu tamamlayın.
