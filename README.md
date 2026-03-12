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


Proje ile ilgili sorularınız için lütfen iletişime geçin.

---

**Not:** Bu sistem, veritabanı programlama dersi için geliştirilmiş bir örnek projedir.
