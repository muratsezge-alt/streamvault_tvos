# StreamVault tvOS — Kurulum Kılavuzu (Mac olmadan)

Bu klasör, StreamVault'un Apple TV (tvOS) sürümünün v1 iskeletidir. Mac'e ihtiyaç
duymadan Codemagic ile build alıp TestFlight üzerinden Apple TV'nde test edersin.

## Bu sürümde ne var (v1)
- M3U liste adresi girme ekranı (adres cihazda saklanır, açılışta otomatik yüklenir)
- Canlı TV: kategori filtresi + kanal grid'i
- Filmler: kategori filtresi + poster grid + detay ekranı ("Şimdi İzle", "Favorilere Ekle")
- Diziler: poster grid + sezon/bölüm listesi
- Favoriler
- Ayarlar: 4 tema (Navy / Obsidian / Orman / Bordo), listeyi yenile/değiştir
- AVKit tabanlı oynatıcı (HLS/.m3u8 sorunsuz; ham .ts için kullanıcıya bilgi verir)

## Henüz YOK (sonraki adımlarda ekleyeceğiz)
- EPG (program rehberi), çoklu ekran (2x2)
- Xtream Codes girişi (şu an sadece M3U URL)
- RevenueCat ile ücretlendirme (Apple TV'de farklı olacak — ayrıca konuşacağız)
- AdMob (tvOS'ta AdMob yok; reklam stratejisini ayrıca değerlendireceğiz)

---

## Adım adım yayına alma

### 1. Git deposu
Bu klasörün TAMAMINI yeni ve boş bir Git deposuna (GitHub/GitLab/Bitbucket) yükle.
`.xcodeproj` YOK — Codemagic onu XcodeGen ile otomatik üretecek.

### 2. App Store Connect'te yeni uygulama
- App Store Connect → Apps → "+" → New App
- Platform olarak **tvOS** seç
- Bundle ID: önce Apple Developer portalında `com.murat.streamvault.tv` kimliğini
  oluştur (Identifiers → "+" → App ID → tvOS), sonra burada onu seç
- Uygulama oluşunca **Apple ID** (sayısal) değerini not al
  (App Information sayfasında). Buna `codemagic.yaml` içinde ihtiyacın var.

### 3. App Store Connect API anahtarı (Codemagic için)
- App Store Connect → Users and Access → Integrations → App Store Connect API → "+"
- Anahtarı indir (.p8), Key ID ve Issuer ID'yi al
- Codemagic'te: Teams/User settings → Integrations → App Store Connect → bu anahtarı ekle
- Ona bir **isim** ver. Bu ismi `codemagic.yaml` içindeki
  `integrations: app_store_connect:` satırına yaz (şu an `StreamVaultTV_ASC_Key`).
- (Önceki iOS uygulamanda kurduğun anahtar varsa onu da kullanabilirsin.)

### 4. codemagic.yaml içinde 2 değeri güncelle
- `APP_STORE_APPLE_ID: 0000000000` → 2. adımdaki sayısal Apple ID
- `app_store_connect: StreamVaultTV_ASC_Key` → 3. adımdaki anahtar ismi

### 5. Codemagic'te uygulamayı ekle ve build al
- Codemagic'te depoyu bağla → `codemagic.yaml` otomatik algılanır
- "tvos-testflight" workflow'unu çalıştır
- Build biter (~birkaç dk), TestFlight'a yüklenir, "Internal Testers"a düşer

### 6. Apple TV'de test
- Apple TV'nde App Store'dan **TestFlight** uygulamasını kur
- Aynı Apple Hesabıyla giriş yap → StreamVault görünür → yükle ve aç

---

## Çalışma döngümüz
Bir değişiklik istediğinde, ben güncel dosyaları veririm; sen depoya commit/push
edersin; Codemagic yeni build alır; TestFlight'tan Apple TV'ne düşer. Hata olursa
Codemagic'teki build log'unu (veya ekran görüntüsünü) bana yapıştır, düzeltip
tekrar veririm.

## Notlar
- IPTV akışları çoğu zaman http; bu yüzden Info.plist'te arbitrary loads açık.
- Film/dizi ayrımı tek M3U'da net olmadığı için sezgisel yapılıyor (grup adı,
  dosya uzantısı, SxxExx kalıbı). Senin gerçek listelerinde nasıl ayrıştığını
  görünce kuralları birlikte ince ayar yaparız (`M3UParser.swift`).
