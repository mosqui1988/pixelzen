# GNOME için PixelZen

PixelZen'in GNOME Shell sürümü, KDE Plasma sürümündeki iki temel özelliği GNOME masaüstüne taşır:

- **Güneşi izleyen hareketli arka plan:** Güneş ve ay, yerel saat ve konuma göre ilerler. Manzara gece, altın saat ve gündüz görünümleri arasında geçiş yapar. Bulutlar, kiraz çiçeği yaprakları, fenerler, ateş böcekleri, turnalar ve yıldız kaymaları canlanır.
- **Sistem bilgi paneli:** Ekranın sağında saat, ay evresi, işlemci, bellek, sıcaklık, pil, yük, disk, ağ, IP, VPN, bağlantı noktaları, Git depoları, yazılım sürümleri ve hizmet durumlarını gösterir.

Uzantı masaüstünün arka plan katmanında çalışır; pencerelerin ve masaüstü simgelerinin altında kalır. Birden fazla monitörde kullanılabilir.

## Ekran görüntüleri

| Gündüz | Gün batımı | Gece |
|---|---|---|
| ![Gündüz](../docs/capturas-gnome/gnome-dia.png) | ![Gün batımı](../docs/capturas-gnome/gnome-anochecer.png) | ![Gece](../docs/capturas-gnome/gnome-noche.png) |

Ekran görüntüleri Ubuntu 24.04, GNOME 46 ve X11 üzerinde alınmıştır. Paneldeki kişisel bilgiler gizlenmiştir.

> **Bakım ve uyumluluk:** Bu GNOME aktarımını @arnau-romero-hazas sürdürmektedir. Şu ana kadar yalnızca Ubuntu 24.04 / GNOME 46 / X11 üzerinde doğrulanmıştır. Wayland ve GNOME 47–48 desteği kodda bulunsa da sınanmamıştır.

## Kurulum

~~~bash
cd gnome
./instalar.sh
~~~

Konumu elle belirlemek için:

~~~bash
./instalar.sh --casa=39.5,-0.4,"Şehrim"
~~~

Kurulumdan sonra GNOME Shell'i yeniden başlatın:

- **X11:** Alt+F2 tuşlarına basın, r yazın ve Enter'a basın.
- **Wayland:** Oturumu kapatıp yeniden açın.

Kurulum betiği uzantıyı kullanıcı dizinine kopyalar, manzara katmanlarını üretir, piksel yazı tiplerini kurar ve GNOME için sabit bir arka plan ayarlar. Önceki arka planınız yedeklenir. Arka planın değiştirilmesini istemiyorsanız --sin-fondo seçeneğini kullanın.

Kurulum yalnızca kullanıcı hesabınızı etkiler; yönetici yetkisi kullanmaz.

## Kullanım

~~~bash
./hora.sh 21:30
./hora.sh demo
./hora.sh real
~~~

Komutlar arka plan saatini sabitler, hızlandırılmış gün döngüsünü başlatır veya gerçek saate geri döner.

## Gelişmiş ayarlar

Uzantı ayarları gsettings ile değiştirilebilir. Şema yolu:

~~~bash
S=~/.local/share/gnome-shell/extensions/pixelzen@mosqui1988.github.io/schemas
~~~

Örnekler:

~~~bash
gsettings --schemadir $S set org.gnome.shell.extensions.pixelzen fps 6
gsettings --schemadir $S set org.gnome.shell.extensions.pixelzen animar false
gsettings --schemadir $S set org.gnome.shell.extensions.pixelzen todos-monitores false
gsettings --schemadir $S set org.gnome.shell.extensions.pixelzen hud false
gsettings --schemadir $S set org.gnome.shell.extensions.pixelzen hud-monitor 1
~~~

Animasyon hızını düşürmek veya ikincil monitörlerde görüntülemeyi kapatmak kaynak tüketimini azaltır.

## Plasma sürümünden farkları

- GNOME sürümünde **Araçlar** kartı bulunmaz; masaüstü tıklamalarını GNOME/Ubuntu simge katmanı alır.
- **Paket** satırı, paket listesinin en son ne zaman güncellendiğini gösterir.
- Kilit ekranında hareketli sahne yerine sabit görüntü kullanılır.
- Pencere süslemeleri, simgeler, imleç ve üst panel bu GNOME aktarımına dahil değildir. Simgeler ve imleç, deponun kök dizininden ./instalar.sh --portable komutuyla kurulabilir.

## Kaldırma

~~~bash
./desinstalar.sh
~~~

Uzantı ve yazı tipleri kaldırılır, önceki arka plan geri yüklenir. ~/.config/pixelzen/ubicacion.json konum dosyası varsa korunur.
