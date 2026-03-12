# Havayolu Yönetim Sistemi

Bu proje, bir havayolu firması için geliştirilmiş kapsamlı bir veritabanı yönetim sistemidir. Python Flask framework'ü kullanılarak geliştirilmiş olup, MS SQL Server veritabanı kullanmaktadır.

## Proje Özellikleri

### Veritabanı Yapısı (8 Tablo)
1. **Havaalanlari** - Havalimanı bilgileri
2. **Ucaklar** - Uçak filosu yönetimi
3. **Ucuslar** - Uçuş planları ve bilgileri
4. **Yolcular** - Yolcu kayıtları
5. **Rezervasyonlar** - Bilet rezervasyonları (Yolcu-Uçuş ilişki tablosu)
6. **Personel** - Pilot ve kabin görevlileri
7. **BakimKayitlari** - Uçak bakım ve onarım kayıtları
8. **UcusPersoneli** - Uçuş-Personel görev atamaları

### Sistem Özellikleri
- ✅ Uçuş yönetimi (Ekleme, listeleme, durum takibi)
- ✅ Rezervasyon sistemi (Bilet rezervasyonu, PNR kodu)
- ✅ Yolcu bilgileri yönetimi
- ✅ Uçak filosu takibi
- ✅ Personel yönetimi
- ✅ Havalimanı bilgileri
- ✅ Bakım kayıtları
- ✅ Detaylı raporlama ve istatistikler
- ✅ Modern ve kullanıcı dostu arayüz

## Kurulum

### Gereksinimler
- Python 3.8 veya üzeri
- MS SQL Server (2016 veya üzeri)
- ODBC Driver 17 for SQL Server

### 1. Python Paketlerini Yükleme

```bash
pip install -r requirements.txt
```

### 2. MS SQL Server Kurulumu

1. MS SQL Server'ı indirin ve kurun (Express veya Developer Edition)
2. SQL Server Management Studio (SSMS) yükleyin
3. ODBC Driver 17 for SQL Server'ı yükleyin

**ODBC Driver İndirme:**
- https://learn.microsoft.com/en-us/sql/connect/odbc/download-odbc-driver-for-sql-server

### 3. Veritabanı Oluşturma

1. SQL Server Management Studio'yu açın
2. `havayolu_db.sql` dosyasını açın
3. F5 tuşuna basarak veritabanını oluşturun

Alternatif olarak komut satırından:
```bash
sqlcmd -S localhost -i havayolu_db.sql
```

### 4. Veritabanı Bağlantı Ayarları

`app.py` dosyasındaki veritabanı bağlantı ayarlarını düzenleyin:

```python
DB_CONFIG = {
    'server': '',  # SQL Server adresi
    'database': 'HavayoluDB',
    'username': '',  # SQL Server Authentication için kullanıcı adı
    'password': '',  # SQL Server Authentication için şifre
    'driver': '{ODBC Driver 17 for SQL Server}'
}
```

**Windows Authentication Kullanımı:**
- `username` ve `password` alanlarını boş bırakın

**SQL Server Authentication Kullanımı:**
- `username` ve `password` alanlarını doldurun

### 5. Uygulamayı Çalıştırma

```bash
python app.py
```

Tarayıcınızda şu adresi açın: http://localhost:5000

## Kullanım

### Ana Sayfa (Dashboard)
- Sistem istatistikleri
- Hızlı erişim menüleri
- Son uçuşlar listesi

### Uçuşlar
- Tüm uçuşları görüntüleme
- Yeni uçuş ekleme
- Uçuş detayları (kalkış, varış, havalimanları, uçak bilgileri)

### Rezervasyonlar
- Bilet rezervasyonu oluşturma
- PNR kodu ile rezervasyon takibi
- Koltuk ve sınıf seçimi
- Ödeme yöntemi kaydı

### Yolcular
- Yolcu kayıt sistemi
- Yolcu bilgileri (ad, soyad, iletişim bilgileri, TC kimlik)
- Yolcu geçmişi

### Uçaklar
- Uçak filosu yönetimi
- Uçak durumu (Aktif, Bakımda, Onarımda)
- Kapasite ve menzil bilgileri

### Personel
- Pilot ve kabin görevlisi kayıtları
- Lisans bilgileri
- Görev atamaları

### Havalimanları
- Havalimanı bilgileri
- Şehir ve ülke bazlı listeleme

### Bakım Kayıtları
- Uçak bakım geçmişi
- Rutin bakım, onarım kayıtları
- Maliyet takibi

### Raporlar
- En çok kullanılan havalimanları
- En çok uçuş yapan uçaklar
- Aylık gelir raporları
- Rezervasyon istatistikleri

## Veritabanı Diyagramı

### İlişkiler
- Ucuslar ➜ Havaalanlari (Kalkış ve Varış)
- Ucuslar ➜ Ucaklar
- Rezervasyonlar ➜ Yolcular
- Rezervasyonlar ➜ Ucuslar
- BakimKayitlari ➜ Ucaklar
- BakimKayitlari ➜ Personel
- UcusPersoneli ➜ Ucuslar
- UcusPersoneli ➜ Personel

## Teknolojiler

### Backend
- Python 3.x
- Flask 3.0.0
- PyODBC 5.0.1

### Frontend
- HTML5
- CSS3 (Bootstrap 5.3)
- JavaScript (jQuery)
- Font Awesome Icons

### Veritabanı
- MS SQL Server
- T-SQL
- Views ve Stored Procedures

## Güvenlik

- SQL Injection koruması (Parametreli sorgular)
- Form validasyonu
- Session yönetimi

## Örnek Veriler

Veritabanı oluşturulurken aşağıdaki örnek veriler otomatik olarak eklenir:
- 8 Havalimanı
- 8 Uçak
- 10 Yolcu
- 10 Personel
- 10 Uçuş
- 12 Rezervasyon
- 5 Bakım Kaydı
- 13 Uçuş-Personel Ataması

## Sorun Giderme

### ODBC Driver Hatası
```
[Microsoft][ODBC Driver Manager] Data source name not found
```
**Çözüm:** ODBC Driver 17 for SQL Server'ı yükleyin.

### Bağlantı Hatası
```
Login failed for user
```
**Çözüm:** 
- Windows Authentication kullanıyorsanız username ve password boş olmalı
- SQL Server Authentication kullanıyorsanız doğru kullanıcı adı ve şifre girdiğinizden emin olun

### Port Hatası
```
[WinError 10061] No connection could be made
```
**Çözüm:** 
- SQL Server'ın çalıştığından emin olun
- SQL Server Browser servisinin açık olduğunu kontrol edin
- Firewall ayarlarını kontrol edin

## Lisans

Bu proje eğitim amaçlı geliştirilmiştir.

## İletişim

Proje ile ilgili sorularınız için lütfen iletişime geçin.

---

**Not:** Bu sistem, veritabanı programlama dersi için geliştirilmiş bir örnek projedir.
