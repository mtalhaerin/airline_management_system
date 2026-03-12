# Veritabanı Yapılandırma Rehberi

## MS SQL Server Kurulum Adımları

### 1. SQL Server İndirme ve Kurulum

#### SQL Server Express Edition (Ücretsiz)
1. https://www.microsoft.com/tr-tr/sql-server/sql-server-downloads adresine gidin
2. "Express" versiyonunu indirin
3. Kurulum sihirbazını çalıştırın
4. "Basic" kurulum tipini seçin
5. Lisans koşullarını kabul edin
6. Kurulum konumunu seçin
7. "Install" butonuna tıklayın

#### Kurulum Sonrası Notlar
- Instance Name: SQLEXPRESS
- Server Name: localhost\SQLEXPRESS veya .\SQLEXPRESS

### 2. SQL Server Management Studio (SSMS) Kurulum

1. https://docs.microsoft.com/en-us/sql/ssms/download-sql-server-management-studio-ssms adresine gidin
2. En son SSMS sürümünü indirin
3. Kurulum dosyasını çalıştırın
4. Kurulum tamamlandıktan sonra SSMS'i açın

### 3. ODBC Driver 17 for SQL Server Kurulum

#### Windows için:
1. https://learn.microsoft.com/en-us/sql/connect/odbc/download-odbc-driver-for-sql-server adresine gidin
2. "ODBC Driver 17 for SQL Server" indirin
3. msodbcsql.msi dosyasını çalıştırın
4. Kurulum sihirbazını takip edin

#### ODBC Driver Doğrulama
PowerShell'de şu komutu çalıştırın:
```powershell
Get-OdbcDriver | Where-Object {$_.Name -like "*SQL Server*"}
```

## Veritabanı Oluşturma

### Yöntem 1: SQL Server Management Studio ile

1. SSMS'i açın
2. Sunucuya bağlanın:
   - Server type: Database Engine
   - Server name: localhost\SQLEXPRESS (veya localhost)
   - Authentication: Windows Authentication
3. "File" > "Open" > "File" menüsünden `havayolu_db.sql` dosyasını açın
4. F5 tuşuna basarak veya "Execute" butonuna tıklayarak çalıştırın
5. Messages penceresinde "Veritabanı başarıyla oluşturuldu!" mesajını görmelisiniz

### Yöntem 2: Komut Satırı ile

```cmd
sqlcmd -S localhost\SQLEXPRESS -E -i "havayolu_db.sql"
```

Parametreler:
- `-S`: Server adı
- `-E`: Windows Authentication kullan
- `-i`: Input dosyası

## Bağlantı Yapılandırması

### app.py Dosyasındaki Yapılandırma

```python
DB_CONFIG = {
    'server': 'localhost\\SQLEXPRESS',  # veya sadece 'localhost'
    'database': 'HavayoluDB',
    'username': '',  # Boş bırakın (Windows Auth için)
    'password': '',  # Boş bırakın (Windows Auth için)
    'driver': '{ODBC Driver 17 for SQL Server}'
}
```

### Windows Authentication Kullanımı (Önerilen)

```python
DB_CONFIG = {
    'server': 'localhost\\SQLEXPRESS',
    'database': 'HavayoluDB',
    'username': '',  # BOŞ
    'password': '',  # BOŞ
    'driver': '{ODBC Driver 17 for SQL Server}'
}
```

### SQL Server Authentication Kullanımı

Önce SQL Server'da bir kullanıcı oluşturmalısınız:

```sql
-- SSMS'de çalıştırın
USE master;
CREATE LOGIN havayolu_user WITH PASSWORD = 'StrongPassword123!';

USE HavayoluDB;
CREATE USER havayolu_user FOR LOGIN havayolu_user;
ALTER ROLE db_owner ADD MEMBER havayolu_user;
```

Sonra app.py'de:

```python
DB_CONFIG = {
    'server': 'localhost\\SQLEXPRESS',
    'database': 'HavayoluDB',
    'username': 'havayolu_user',
    'password': 'StrongPassword123!',
    'driver': '{ODBC Driver 17 for SQL Server}'
}
```

## Bağlantı Testi

### Python ile Test

```python
import pyodbc

conn_str = (
    "DRIVER={ODBC Driver 17 for SQL Server};"
    "SERVER=localhost\\SQLEXPRESS;"
    "DATABASE=HavayoluDB;"
    "Trusted_Connection=yes;"
)

try:
    conn = pyodbc.connect(conn_str)
    print("Bağlantı başarılı!")
    conn.close()
except Exception as e:
    print(f"Bağlantı hatası: {e}")
```

### SSMS ile Test

1. SSMS'i açın
2. "Connect" butonuna tıklayın
3. Bağlantı başarılıysa Object Explorer'da veritabanlarınızı görebilirsiniz
4. HavayoluDB veritabanını genişletin
5. Tables klasörünü açın - 8 tablo görmelisiniz

## Veritabanı Bilgileri

### Tablolar ve Kayıt Sayıları

| Tablo Adı | Açıklama | Örnek Kayıt Sayısı |
|-----------|----------|---------------------|
| Havaalanlari | Havalimanı bilgileri | 8 |
| Ucaklar | Uçak filosu | 8 |
| Yolcular | Yolcu kayıtları | 10 |
| Ucuslar | Uçuş planları | 10 |
| Rezervasyonlar | Bilet rezervasyonları | 12 |
| Personel | Çalışan bilgileri | 10 |
| BakimKayitlari | Bakım kayıtları | 5 |
| UcusPersoneli | Uçuş-Personel atamaları | 13 |

### View'ler

- **vw_UcusDetaylari**: Uçuş detaylarını havalimanı ve uçak bilgileriyle birlikte gösterir
- **vw_RezervasyonDetaylari**: Rezervasyon bilgilerini yolcu ve uçuş detaylarıyla birlikte gösterir

## Sorun Giderme

### Problem 1: SQL Server'a Bağlanamıyorum

**Çözüm:**
1. SQL Server servisinin çalıştığını kontrol edin:
   ```powershell
   Get-Service -Name "*SQL*" | Where-Object {$_.Status -eq "Running"}
   ```

2. SQL Server Configuration Manager'ı açın
3. SQL Server Network Configuration > Protocols for SQLEXPRESS
4. TCP/IP'nin "Enabled" olduğundan emin olun

### Problem 2: ODBC Driver Bulunamıyor

**Hata:**
```
[Microsoft][ODBC Driver Manager] Data source name not found
```

**Çözüm:**
1. ODBC Driver 17'yi kurun (yukarıdaki adımları takip edin)
2. Alternatif driver kullanın: `{SQL Server}`
3. app.py'de driver değiştirin:
   ```python
   'driver': '{SQL Server}'
   ```

### Problem 3: Login Failed

**Hata:**
```
Login failed for user
```

**Çözüm:**
1. Windows Authentication kullanıyorsanız, username ve password boş olmalı
2. SQL Server'ın Mixed Mode Authentication'ı desteklediğinden emin olun
3. SSMS'de: Server Properties > Security > SQL Server and Windows Authentication mode

### Problem 4: Port 1433 Erişim Hatası

**Çözüm:**
1. Firewall'da SQL Server için istisna oluşturun
2. Windows Defender Firewall > Advanced Settings
3. Inbound Rules > New Rule
4. Port > TCP > 1433
5. Allow the connection

### Problem 5: Veritabanı Oluşturma Hatası

**Hata:**
```
Database 'HavayoluDB' already exists
```

**Çözüm:**
Önce var olan veritabanını silin:
```sql
USE master;
DROP DATABASE HavayoluDB;
```

Sonra yeniden havayolu_db.sql dosyasını çalıştırın.

## PostgreSQL Alternatifi

Eğer PostgreSQL kullanmak isterseniz:

### 1. PostgreSQL Kurulumu
- https://www.postgresql.org/download/
- pgAdmin 4'ü kurun

### 2. SQL Dosyası Düzenlemeleri
SQL dosyasını PostgreSQL syntax'ına çevirmek gerekir:
- `IDENTITY(1,1)` → `SERIAL`
- `NVARCHAR` → `VARCHAR`
- `BIT` → `BOOLEAN`
- `GETDATE()` → `CURRENT_TIMESTAMP`

### 3. Python Bağlantısı
```python
import psycopg2

conn = psycopg2.connect(
    host="localhost",
    database="havayoludb",
    user="postgres",
    password="your_password"
)
```

## Yedekleme

### Manuel Yedek Alma

SSMS'de:
1. Database'e sağ tık > Tasks > Back Up
2. Backup type: Full
3. Destination: Disk
4. OK

### Komut Satırından:

```cmd
sqlcmd -S localhost\SQLEXPRESS -E -Q "BACKUP DATABASE HavayoluDB TO DISK='C:\Backup\HavayoluDB.bak'"
```

## Performans İyileştirme

### İndeks Önerileri

```sql
-- Sık kullanılan sorgular için indeksler
CREATE INDEX idx_ucuslar_tarih ON Ucuslar(UcusTarihi);
CREATE INDEX idx_rezervasyonlar_pnr ON Rezervasyonlar(PNRKodu);
CREATE INDEX idx_yolcular_numara ON Yolcular(YolcuNumarasi);
```

## Güvenlik Tavsiyeleri

1. Prodüksiyon ortamı için güçlü şifreler kullanın
2. Gereksiz kullanıcılara yetki vermeyin
3. Düzenli yedek alın
4. SQL injection'a karşı parametreli sorgular kullanın (zaten uygulanmış)
5. Hassas verileri şifreleyip saklayın

---

**Not:** Bu rehber Windows 10/11 işletim sistemi için hazırlanmıştır.
