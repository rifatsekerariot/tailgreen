# 📐 TailGreen Sistem ve Ağ Mimarisi

TailGreen, eski bir mobil cihazın tüm donanım bileşenlerini (SoC, RAM, Wi-Fi, LTE Modem, Pil, AMOLED Ekran) bir Linux sunucusuna dönüştürerek maksimum verim elde eder.

---

## 🏗️ 1. Genel Topoloji

```
┌─────────────────────────────────────────────────────────┐
│                    UZAKTAKİ KULLANICI                  │
│       (Laptop, Tablet veya Mobil Cihaz - Tailscale)     │
└────────────────────────────┬────────────────────────────┘
                             │
                  Şifreli WireGuard Tüneli
                   (Tailscale Mesh Network)
                             │
                             ▼
┌─────────────────────────────────────────────────────────┐
│              TAILGREEN GATEWAY (GALAXY S4)              │
│  ┌───────────────────────────────────────────────────┐  │
│  │ OS: postmarketOS edge (Alpine Linux 3.20+)        │  │
│  │ Kernel: Linux 7.1.x mainline (apq8064)            │  │
│  │ IP: 100.72.43.121 (Tailscale) / 192.168.100.8     │  │
│  └─────────────────────────┬─────────────────────────┘  │
│                            │                            │
│         ┌──────────────────┴──────────────────┐         │
│         ▼                                     ▼         │
│  ┌──────────────┐                      ┌──────────────┐ │
│  │ Subnet Route │                      │  Tor Proxy   │ │
│  │ (192.168.x.x)│                      │ (Port: 9050) │ │
│  └──────┬───────┘                      └──────┬───────┘ │
└─────────┼─────────────────────────────────────┼─────────┘
          │                                     │
          ▼                                     ▼
┌──────────────────┐                  ┌──────────────────┐
│ Yerel Ağ / Cihaz │                  │ Anonim İnternet  │
│  - Sunucular     │                  │  - Tor Çıkış     │
│  - Modeller/Kam. │                  │  - İz Bırakmayan │
└──────────────────┘                  └──────────────────┘
```

---

## ⚙️ 2. Temel Katmanlar

### A. Donanım & Çekirdek (Hardware & Kernel)
- **SoC:** Qualcomm Snapdragon 600 (APQ8064T) - 4x Krait 300 çekirdek.
- **Bootloader Zinciri:** `Samsung SBL` ➔ `lk2nd` (Little Kernel ikincil önyükleyici) ➔ `extlinux` ➔ `Mainline Linux 7.1.x`.
- **Dahili UPS:** 2600 mAh Lityum İyon batarya. Şebeke elektriği kesilse dahi sistem 6-10 saat boyunca kapanmadan çalışmaya devam eder.

### B. Ağ ve Tünelleme (Networking & Tunneling)
1. **Tailscale (WireGuard Tabanlı Mesh VPN):**
   - NAT aşma (NAT Traversal - STUN/DERP) özelliği sayesinde port açmaya gerek duymaz.
   - CGNAT arkasındaki kurumsal ağlarda bile dışarıdan doğrudan çift yönlü bağlantı kurar.
   - `--advertise-exit-node`: Cihazı tüm internet trafiğinin çıkış noktası yapar.
   - `--advertise-routes=192.168.100.0/24`: Dışarıdaki kullanıcının ofisteki tüm yerel sunuculara erişmesini sağlar.

2. **Tor SOCKS5 Anonymizer:**
   - `0.0.0.0:9050` portunda dinler.
   - Güvenlik duvarı arkasından veya Tailscale tüneli üzerinden gelen istekleri 3 düğümlü Tor devresine yönlendirir.

### C. Konsol ve Çıktı Katmanı (Headless TTY & Framebuffer)
- X11 veya Wayland (Phosh) gibi yüksek kaynak tüketen grafik arayüzler kapatılmıştır.
- Linux Framebuffer Konsolu (`fbcon`) AMOLED ekrana yönlendirilmiştir (`console=tty0 console=tty1`).
- Sistem durumu, ağ bilgisi ve Tailscale durumu ekran üzerinde canlı olarak izlenebilir.
