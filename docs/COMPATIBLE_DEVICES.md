# 📱 Desteklenen Donanımlar ve Alternatif Cihazlar

TailGreen mimarisi sadece Samsung Galaxy S4'e özgü değildir; elinizdeki atıl telefonlardan tek kart bilgisayarlara ve hatta mikrodenetleyicilere kadar geniş bir donanım yelpazesinde uygulanabilir.

---

## 📊 Donanım Uyumluluk ve Yetenek Matrisi

| Donanım Kategorisi | Örnek Cihazlar | İşletim Sistemi | Tailscale | Tor Proxy | Dahili Pil (UPS) | USB Ethernet (Dongle Modu) |
| :--- | :--- | :--- | :---: | :---: | :---: | :---: |
| **Eski Akıllı Telefonlar (Önerilen)** | Samsung S3/S4/S5, Nexus 4/5, Redmi 2/4X, OnePlus One | postmarketOS / Linux | ✅ Tam | ✅ Tam | ✅ Var (Dahili) | ✅ Var (Tam Destek) |
| **Eski Android Tabletler** | Nexus 7, Galaxy Tab, LG G Pad | postmarketOS / Mobian | ✅ Tam | ✅ Tam | ✅ Var (Büyük Pil) | ✅ Var |
| **Mini SBC (Tek Kart PC)** | Raspberry Pi Zero W, Zero 2 W | Raspberry Pi OS / Alpine | ✅ Tam | ✅ Tam | ❌ Harici Gerekir | ✅ Var (USB OTG Portu) |
| **Standart SBC'ler** | Raspberry Pi 3/4/5, Orange Pi Zero 2/3 | Linux (Armbian/Debian) | ✅ Tam | ✅ Tam | ❌ Harici Gerekir | ⚠️ Modele Göre Değişir |
| **Eski Android TV Box'lar** | Amlogic S905/S912 işlemcili kutular | Armbian Linux | ✅ Tam | ✅ Tam | ❌ Harici Gerekir | ⚠️ USB-Ethernet ile |
| **Mikrodenetleyiciler (MCU)** | ESP32, ESP32-S3 | FreeRTOS / ESP-IDF | ⚠️ Hafif WG | ❌ Yetersiz RAM | ⚠️ Harici LiPo ile | ✅ ESP32-S3 USB TinyUSB |

---

## 🔍 1. Eski Akıllı Telefonlar ve Tabletler (En Yüksek Verim)

Akıllı telefonlar bu proje için **dünyadaki en mükemmel mini sunucu donanımlarıdır**. Neden? Çünkü işlemci, RAM, depolama, Wi-Fi, 4G modem, şarj devresi, batarya (UPS) ve ekran tek bir gövdede hazır gelir.

- **Samsung Serisi:** Galaxy S3 (`i9300`), S4 (`i9505`), S5 (`klte`), Note 3 (`hlte`), Note 4.
- **Google Nexus:** Nexus 4 (`mako`), Nexus 5 (`hammerhead`), Nexus 7 2013 (`flo`).
- **Xiaomi Serisi:** Redmi 2 (`wt88047`), Redmi 4X (`santoni`), Redmi Note 4, Poco F1 (`beryllium`).
- **OnePlus:** OnePlus One (`bacon`), OnePlus 3/3T, 5/5T, 6.
- **Motorola:** Moto G (1, 2, 3. nesil), Moto E serisi.

> 💡 **postmarketOS Cihaz Listesi:** Telefonunuzun doğrudan desteklenip desteklenmediğini görmek için [postmarketOS Wiki Devices](https://wiki.postmarketos.org/wiki/Devices) sayfasını kontrol edebilirsiniz. (Linux desteklemeyen cihazlarda ise **Termux** üzerinden kullanıcı seviyesinde Tailscale ve Tor çalıştırılabilir).

---

## 🍓 2. Raspberry Pi Zero W & Pi Zero 2 W (Cep Boyutu Dongle)

Raspberry Pi Zero serisi, $15-$20 bandında sıfır maliyete en yakın SBC alternatifidir:
- **USB OTG Desteği:** Pi Zero'nun micro-USB veri portu donanımsal olarak **USB Gadget (Ethernet/RNDIS)** modunu destekler.
- **Nasıl Çalışır:** Sunucunun arkasındaki herhangi bir USB portuna taktığınızda, sunucu Pi Zero'yu bir ağ kartı olarak görür. Pi Zero kendi dahili Wi-Fi'ı üzerinden Tailscale ağına bağlanır ve sunucuyu dışarıya açar.
- **Farkı:** Ekranı ve pili yoktur, ancak boyut olarak bir flash bellek kadardır.

---

## ⚡ 3. Mikrodenetleyiciler: ESP32 ve ESP32-S3 (IoT Sınırı)

ESP32 bir Linux işletim sistemi çalıştırmaz (bellek 520 KB SRAM / 8 MB PSRAM ile sınırlıdır). Dolayısıyla doğrudan resmi Go tabanlı Tailscale uygulamasını çalıştıramaz. 

**Ancak ESP32 ile neler yapılabilir?**
1. **Gömülü WireGuard (`esp32-wireguard`):**  
   ESP32 içine saf C/C++ ile yazılmış hafif bir WireGuard istemcisi gömülebilir. ESP32, evinizdeki/ofisinizdeki WireGuard veya TailGreen sunucusuna güvenli bir VPN tüneliyle bağlanarak sensör verilerini şifreli olarak iletebilir.
2. **ESP32-S3 USB Ethernet Gadget:**  
   ESP32-S3'ün yerel USB OTG donanımı sayesinde sunucuya takıldığında bir CDC-Ethernet kartı gibi davranabilir ve Wi-Fi köprüsü vazifesi görebilir.
3. **IoT Sensör Ağ Geçidi:**  
   ESP32, ofisteki klima, sıcaklık veya kavşak sensörlerini okuyup TailGreen (Galaxy S4) üzerindeki yerel MQTT broker'a aktarabilir.

---

## 📺 4. Eski TV Box'lar (Android TV Box / TV Stick)

Çekmecede duran eski Amlogic veya Allwinner işlemcili Android TV kutularına bir SD kart ile **Armbian Linux** kurulabilir:
- Ethernet portları (100M/1G) ve güçlü 4 çekirdekli işlemcileri vardır.
- 7/24 prizde kalarak ofis veya ev için mükemmel bir **TailGreen Sabit Gateway** olurlar.

---

## 🎯 Hangi Cihazı Ne Zaman Seçmelisiniz?

- **Elektrik kesintisine dayanıklılık & Dahili Ekran istiyorsanız:** 👉 **Eski Akıllı Telefon / Tablet**
- **Sunucunun arkasında görünmeyecek kadar minik bir dongle istiyorsanız:** 👉 **Raspberry Pi Zero 2 W**
- **Sabit kablolu Ethernet bağlantısı istiyorsanız:** 👉 **Eski TV Box veya Raspberry Pi 3/4**
- **Sadece sensör ve telemetri şifrelemek istiyorsanız:** 👉 **ESP32 (Embedded WireGuard)**
