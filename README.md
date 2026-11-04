# PixelZen

> **KDE Plasma 6 için piksel sanatlı masaüstü teması.** Japon esintili, güneşi izleyen hareketli manzara; sistem bilgi paneli, simgeler ve imleç.

![PixelZen gece görünümü](capturas/animacion-noche.gif)

PixelZen; KDE Plasma 6 için hazırlanmış, eski Japonya estetiğinden ilham alan bütünlüklü bir masaüstü temasıdır. Güneş ve ay, bulunduğunuz konuma ve gerçek saate göre gökyüzünde ilerler. Manzara gece, altın saat ve gündüz görünümleri arasında yumuşakça geçiş yapar.

## Ekran görüntüleri

![Gündüz görünümü](capturas/escritorio-dia.png)

| Şafak | Gece |
|---|---|
| ![Şafak](capturas/escritorio-amanecer.png) | ![Gece](capturas/escritorio-noche.png) |

## Öne çıkan özellikler

- **Hareketli duvar kâğıdı:** Güneş doğudan yükselir, gökyüzünü geçer ve batıdan batar. Gece ay, yıldızlar, tapınak ışıkları ve ateş böcekleri görünür.
- **Sistem paneli (HUD):** Saat, ay evresi, işlemci, bellek, sıcaklık, pil, ağ, IP, VPN, açık bağlantı noktaları, Git depoları ve geliştirme araçları.
- **Piksel simgeler:** KDE için yaklaşık 3.000 simge eşlemesi; desteklenmeyen simgeler Breeze simgelerine döner.
- **İmleç:** Torii kapısından esinlenen kırmızı uçlu piksel imleci.
- **Pencere ve panel görünümü:** Piksel çerçeveler, uyumlu renkler ve sade üst panel.
- **Uçbirim görünümü:** Alacritty ve Konsole renkleri ile fish komut istemi.

Bilgi paneli yalnızca yerel sistem bilgilerini okur. Ağ bağlantısı kurmaz ve yönetici yetkisi istemez. Konum, saat dilimi verisinden hesaplanır; istenirse elle belirlenebilir.

## Gereksinimler

- KDE Plasma 6 (Wayland veya X11)
- python3, qdbus6, kwriteconfig6, fc-cache
- Alacritty ve fish isteğe bağlıdır.

## Kurulum

En kolay yöntem, Sürümler bölümünden paketi indirip arşivi açmak ve **PixelZen'i Kur** simgesine çift tıklamaktır.

Uçbirimden kurulum:

~~~bash
tar xzf pixelzen-1.0.tar.gz
cd pixelzen-1.0
./instalar.sh
~~~

Konumu elle belirlemek için:

~~~bash
./instalar.sh --casa=39.5,-0.4,"Şehrim"
~~~

KDE Plasma 6 kullanmıyorsanız yalnızca simgeleri, imleci ve yazı tiplerini kurmayı deneyebilirsiniz:

~~~bash
./instalar.sh --portable
~~~

Bu taşınabilir kurulum deneyseldir ve Plasma dışındaki masaüstlerinde sınanmamıştır.

### GNOME

GNOME Shell için hareketli arka plan ve bilgi paneli içeren ayrı bir uzantı bulunur:

~~~bash
cd gnome
./instalar.sh
~~~

Bu sürüm Ubuntu 24.04, GNOME 46 ve X11 üzerinde sınanmıştır. Ayrıntılar için GNOME kurulum kılavuzuna bakın: gnome/LEEME.md.

Kurulum yalnızca kullanıcı hesabınızı etkiler; yönetici yetkisi kullanmaz. Değişikliklerden önce mevcut ayarlarınızın yedeği alınır.

## Kullanım

Arka plan saatini sabitlemek, hızlandırılmış gösterimi açmak veya gerçek saate dönmek için:

~~~bash
~/.local/share/pixelzen/src/hora.sh 21:30
~/.local/share/pixelzen/src/hora.sh demo
~/.local/share/pixelzen/src/hora.sh real
~~~

Temanın tek bir bölümünü yeniden uygulamak için:

~~~bash
~/.local/share/pixelzen/aplicar.sh iconos
~~~

Gösterim verilerini kullanmak için:

~~~bash
touch ~/.config/pixelzen/demo
~~~

Bu seçenek bilgi panelindeki kişisel ağ ve sistem bilgilerini örnek verilerle değiştirir.

## Geri alma ve kaldırma

Önceki masaüstü ayarlarını geri yüklemek için:

~~~bash
~/.local/share/pixelzen/revertir.sh
~~~

Temayı kaldırmak için:

~~~bash
~/.local/share/pixelzen/desinstalar.sh
~~~

## Teknik yapı

- src/fondo3.py: Manzara çizimlerini üretir.
- src/capas.py: Gökyüzü ve sahne katmanlarını oluşturur.
- src/iconos.py: KDE simge adlarını piksel simgelerle eşleştirir.
- src/cursor.py: Xcursor biçiminde imleç üretir.
- src/construir.py: Renk şemasını, Plasma temasını, pencereleri ve uçbirim ayarlarını oluşturur.
- hud/: Plasma bilgi panelini ve salt okunur veri motorunu içerir.
- gnome/: GNOME Shell uzantısını içerir.

## Lisanslar

Kod ve üretilen çizimler GPL-3.0-or-later lisanslıdır. Yazı tipleri SIL Open Font License 1.1, Pixelarticons simgeleri MIT lisansını kullanır. Ayrıntılar licencias/ dizinindedir.

Projenin özgün tanıtım yazısı: https://ralcaniz.dev/posts/pixelzen-escritorio-kde-pixel-art/
