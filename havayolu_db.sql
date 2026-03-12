-- Havayolu Firması Veritabanı Oluşturma Betiği
-- MS SQL Server

-- 1. Veritabanını oluştur
IF NOT EXISTS (SELECT * FROM sys.databases WHERE name = 'HavayoluDB')
BEGIN
    CREATE DATABASE HavayoluDB;
    PRINT 'HavayoluDB veritabanı oluşturuldu.';
END
GO

USE HavayoluDB;
GO

-- 2. Havalimanları Tablosu
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Havaalanlari]') AND type in (N'U'))
BEGIN
    CREATE TABLE Havaalanlari (
        HavaalaniID INT PRIMARY KEY IDENTITY(1,1),
        HavaalaniKodu NVARCHAR(10) NOT NULL UNIQUE,
        HavaalaniAdi NVARCHAR(100) NOT NULL,
        Sehir NVARCHAR(50) NOT NULL,
        Ulke NVARCHAR(50) NOT NULL,
        Aktif BIT DEFAULT 1
    );
END

-- 3. Uçaklar Tablosu
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Ucaklar]') AND type in (N'U'))
BEGIN
    CREATE TABLE Ucaklar (
        UcakID INT PRIMARY KEY IDENTITY(1,1),
        KodNumarasi NVARCHAR(20) NOT NULL UNIQUE,
        Marka NVARCHAR(50) NOT NULL,
        Model NVARCHAR(50) NOT NULL,
        YolcuKapasitesi INT NOT NULL CHECK (YolcuKapasitesi > 0),
        Menzil INT NOT NULL CHECK (Menzil > 0),
        Durum NVARCHAR(20) DEFAULT 'Aktif' CHECK (Durum IN ('Aktif', 'Bakimda', 'Onarımda', 'Devre Dışı')),
        UretimYili INT,
        SonBakimTarihi DATE
    );
END

-- 4. Yolcular Tablosu
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Yolcular]') AND type in (N'U'))
BEGIN
    CREATE TABLE Yolcular (
        YolcuID INT PRIMARY KEY IDENTITY(1,1),
        YolcuNumarasi NVARCHAR(20) NOT NULL UNIQUE,
        Ad NVARCHAR(50) NOT NULL,
        Soyad NVARCHAR(50) NOT NULL,
        TelefonEv NVARCHAR(20),
        TelefonIs NVARCHAR(20),
        TelefonCep NVARCHAR(20) NOT NULL,
        Email NVARCHAR(100),
        Adres NVARCHAR(250),
        DogumTarihi DATE,
        TCKimlikNo NVARCHAR(11),
        KayitTarihi DATETIME DEFAULT GETDATE()
    );
END

-- 5. Uçuşlar Tablosu
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Ucuslar]') AND type in (N'U'))
BEGIN
    CREATE TABLE Ucuslar (
        UcusID INT PRIMARY KEY IDENTITY(1,1),
        UcusNumarasi NVARCHAR(20) NOT NULL UNIQUE,
        KalkisHavaalaniID INT NOT NULL,
        VarisHavaalaniID INT NOT NULL,
        UcakID INT NOT NULL,
        UcusTarihi DATE NOT NULL,
        KalkisSaati TIME NOT NULL,
        VarisSaati TIME NOT NULL,
        UcusSuresi INT,
        Fiyat DECIMAL(10,2) NOT NULL CHECK (Fiyat >= 0),
        DoluKoltukSayisi INT DEFAULT 0,
        Durum NVARCHAR(20) DEFAULT 'Planlandı' CHECK (Durum IN ('Planlandı', 'İptal', 'Gerçekleşti', 'Gecikti', 'Aktif')),
        FOREIGN KEY (KalkisHavaalaniID) REFERENCES Havaalanlari(HavaalaniID),
        FOREIGN KEY (VarisHavaalaniID) REFERENCES Havaalanlari(HavaalaniID),
        FOREIGN KEY (UcakID) REFERENCES Ucaklar(UcakID),
        CHECK (KalkisHavaalaniID != VarisHavaalaniID)
    );
END

-- 6. Rezervasyonlar Tablosu
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Rezervasyonlar]') AND type in (N'U'))
BEGIN
    CREATE TABLE Rezervasyonlar (
        RezervasyonID INT PRIMARY KEY IDENTITY(1,1),
        YolcuID INT NOT NULL,
        UcusID INT NOT NULL,
        RezervasyonTarihi DATETIME DEFAULT GETDATE(),
        KoltukNumarasi NVARCHAR(10),
        BiletTipi NVARCHAR(20) DEFAULT 'Ekonomi' CHECK (BiletTipi IN ('Ekonomi', 'Business', 'First Class')),
        BiletFiyati DECIMAL(10,2) NOT NULL,
        OdemeYontemi NVARCHAR(20) CHECK (OdemeYontemi IN ('Kredi Kartı', 'Nakit', 'Havale')),
        PNRKodu NVARCHAR(10) UNIQUE,
        Durum NVARCHAR(20) DEFAULT 'Aktif' CHECK (Durum IN ('Aktif', 'İptal', 'Tamamlandı')),
        FOREIGN KEY (YolcuID) REFERENCES Yolcular(YolcuID),
        FOREIGN KEY (UcusID) REFERENCES Ucuslar(UcusID)
    );
END

-- 7. Personel Tablosu
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Personel]') AND type in (N'U'))
BEGIN
    CREATE TABLE Personel (
        PersonelID INT PRIMARY KEY IDENTITY(1,1),
        PersonelNumarasi NVARCHAR(20) NOT NULL UNIQUE,
        Ad NVARCHAR(50) NOT NULL,
        Soyad NVARCHAR(50) NOT NULL,
        Pozisyon NVARCHAR(50) NOT NULL CHECK (Pozisyon IN ('Pilot', 'Yardımcı Pilot', 'Kabin Görevlisi', 'Hostes', 'Mühendis')),
        TCKimlikNo NVARCHAR(11) NOT NULL UNIQUE,
        Telefon NVARCHAR(20) NOT NULL,
        Email NVARCHAR(100),
        DogumTarihi DATE,
        IseGirisTarihi DATE NOT NULL,
        Maas DECIMAL(10,2),
        LisansNo NVARCHAR(50),
        LisansGecerlilikTarihi DATE,
        Aktif BIT DEFAULT 1
    );
END

-- 8. Bakım Kayıtları Tablosu
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[BakimKayitlari]') AND type in (N'U'))
BEGIN
    CREATE TABLE BakimKayitlari (
        BakimID INT PRIMARY KEY IDENTITY(1,1),
        UcakID INT NOT NULL,
        BakimTipi NVARCHAR(50) NOT NULL CHECK (BakimTipi IN ('Rutin Bakım', 'Büyük Bakım', 'Onarım', 'Periyodik Kontrol')),
        BaslangicTarihi DATE NOT NULL,
        BitisTarihi DATE,
        Aciklama NVARCHAR(500),
        Maliyet DECIMAL(10,2),
        SorumluPersonelID INT,
        Durum NVARCHAR(20) DEFAULT 'Devam Ediyor' CHECK (Durum IN ('Devam Ediyor', 'Tamamlandı', 'Ertelendi')),
        FOREIGN KEY (UcakID) REFERENCES Ucaklar(UcakID),
        FOREIGN KEY (SorumluPersonelID) REFERENCES Personel(PersonelID)
    );
END

-- 9. Uçuş Personeli Tablosu
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[UcusPersoneli]') AND type in (N'U'))
BEGIN
    CREATE TABLE UcusPersoneli (
        UcusPersonelID INT PRIMARY KEY IDENTITY(1,1),
        UcusID INT NOT NULL,
        PersonelID INT NOT NULL,
        Gorev NVARCHAR(50) NOT NULL,
        FOREIGN KEY (UcusID) REFERENCES Ucuslar(UcusID),
        FOREIGN KEY (PersonelID) REFERENCES Personel(PersonelID),
        UNIQUE(UcusID, PersonelID)
    );
END
GO

--- [Görünümler (Views)] ---

-- Uçuş Detayları Görünümü
CREATE OR ALTER VIEW vw_UcusDetaylari AS
SELECT 
    u.UcusID,
    u.UcusNumarasi,
    u.UcusTarihi,
    u.KalkisSaati,
    u.VarisSaati,
    hk.HavaalaniAdi AS KalkisHavaalani,
    hk.Sehir AS KalkisSehir,
    hv.HavaalaniAdi AS VarisHavaalani,
    hv.Sehir AS VarisSehir,
    uc.KodNumarasi AS UcakKodu,
    uc.Marka + ' ' + uc.Model AS UcakModeli,
    uc.YolcuKapasitesi,
    u.DoluKoltukSayisi,
    u.Fiyat,
    u.Durum
FROM Ucuslar u
INNER JOIN Havaalanlari hk ON u.KalkisHavaalaniID = hk.HavaalaniID
INNER JOIN Havaalanlari hv ON u.VarisHavaalaniID = hv.HavaalaniID
INNER JOIN Ucaklar uc ON u.UcakID = uc.UcakID;
GO

-- Rezervasyon Detayları Görünümü
CREATE OR ALTER VIEW vw_RezervasyonDetaylari AS
SELECT 
    r.PNRKodu,
    y.Ad + ' ' + y.Soyad AS YolcuAdi,
    y.TelefonCep,
    u.UcusNumarasi,
    u.UcusTarihi,
    hk.Sehir AS Kalkis,
    hv.Sehir AS Varis,
    r.KoltukNumarasi,
    r.BiletTipi,
    r.BiletFiyati,
    r.Durum
FROM Rezervasyonlar r
INNER JOIN Yolcular y ON r.YolcuID = y.YolcuID
INNER JOIN Ucuslar u ON r.UcusID = u.UcusID
INNER JOIN Havaalanlari hk ON u.KalkisHavaalaniID = hk.HavaalaniID
INNER JOIN Havaalanlari hv ON u.VarisHavaalaniID = hv.HavaalaniID;
GO

PRINT 'Tablolar ve Görünümler kontrol edildi/oluşturuldu.';
GO

-- Örnek Veriler Ekle

-- Havalimanları
INSERT INTO Havaalanlari (HavaalaniKodu, HavaalaniAdi, Sehir, Ulke) VALUES
('IST', 'İstanbul Havalimanı', 'İstanbul', 'Türkiye'),
('SAW', 'Sabiha Gökçen Havalimanı', 'İstanbul', 'Türkiye'),
('ESB', 'Esenboğa Havalimanı', 'Ankara', 'Türkiye'),
('AYT', 'Antalya Havalimanı', 'Antalya', 'Türkiye'),
('IZM', 'Adnan Menderes Havalimanı', 'İzmir', 'Türkiye'),
('ADB', 'Gaziemir Havalimanı', 'İzmir', 'Türkiye'),
('DLM', 'Dalaman Havalimanı', 'Muğla', 'Türkiye'),
('BJV', 'Bodrum Havalimanı', 'Muğla', 'Türkiye');

-- Uçaklar
INSERT INTO Ucaklar (KodNumarasi, Marka, Model, YolcuKapasitesi, Menzil, Durum, UretimYili, SonBakimTarihi) VALUES
('TC-JRO', 'Airbus', 'A320', 180, 5700, 'Aktif', 2018, '2026-01-15'),
('TC-JRP', 'Airbus', 'A321', 220, 5950, 'Aktif', 2019, '2026-02-10'),
('TC-JRS', 'Boeing', '737-800', 189, 5765, 'Aktif', 2017, '2026-01-20'),
('TC-JRT', 'Boeing', '737-900', 215, 5925, 'Bakimda', 2020, '2026-02-28'),
('TC-JRU', 'Airbus', 'A330', 277, 13400, 'Aktif', 2016, '2025-12-15'),
('TC-JRV', 'Boeing', '787', 242, 14140, 'Aktif', 2021, '2026-02-05'),
('TC-JRW', 'Airbus', 'A319', 156, 6850, 'Aktif', 2015, '2026-01-25'),
('TC-JRX', 'Boeing', '777', 396, 13649, 'Onarımda', 2019, '2025-11-30');

-- Yolcular
INSERT INTO Yolcular (YolcuNumarasi, Ad, Soyad, TelefonEv, TelefonIs, TelefonCep, Email, Adres, DogumTarihi, TCKimlikNo) VALUES
('Y001', 'Ahmet', 'Yılmaz', '02121234567', '02129876543', '05551234567', 'ahmet.yilmaz@email.com', 'İstanbul, Kadıköy', '1985-05-15', '12345678901'),
('Y002', 'Ayşe', 'Kaya', '03121234567', NULL, '05559876543', 'ayse.kaya@email.com', 'Ankara, Çankaya', '1990-08-20', '23456789012'),
('Y003', 'Mehmet', 'Demir', '02422345678', '02429876543', '05558765432', 'mehmet.demir@email.com', 'Antalya, Muratpaşa', '1988-12-10', '34567890123'),
('Y004', 'Fatma', 'Şahin', '02323456789', NULL, '05557654321', 'fatma.sahin@email.com', 'İzmir, Bornova', '1992-03-25', '45678901234'),
('Y005', 'Ali', 'Çelik', '02124567890', '02129876540', '05556543210', 'ali.celik@email.com', 'İstanbul, Beşiktaş', '1987-07-30', '56789012345'),
('Y006', 'Zeynep', 'Aydın', '03125678901', NULL, '05555432109', 'zeynep.aydin@email.com', 'Ankara, Keçiören', '1995-11-05', '67890123456'),
('Y007', 'Can', 'Öztürk', '02426789012', NULL, '05554321098', 'can.ozturk@email.com', 'Antalya, Alanya', '1991-09-18', '78901234567'),
('Y008', 'Elif', 'Arslan', '02327890123', '02329876541', '05553210987', 'elif.arslan@email.com', 'İzmir, Karşıyaka', '1989-06-12', '89012345678'),
('Y009', 'Burak', 'Koç', '02128901234', NULL, '05552109876', 'burak.koc@email.com', 'İstanbul, Şişli', '1993-04-22', '90123456789'),
('Y010', 'Selin', 'Yıldız', '03129012345', NULL, '05551098765', 'selin.yildiz@email.com', 'Ankara, Mamak', '1994-01-08', '01234567890');

-- Personel
INSERT INTO Personel (PersonelNumarasi, Ad, Soyad, Pozisyon, TCKimlikNo, Telefon, Email, DogumTarihi, IseGirisTarihi, Maas, LisansNo, LisansGecerlilikTarihi) VALUES
('P001', 'Murat', 'Pilot', 'Pilot', '11223344556', '05559001234', 'murat.pilot@airline.com', '1980-03-15', '2010-06-01', 45000.00, 'CPL-12345', '2027-06-01'),
('P002', 'Deniz', 'Kaptan', 'Pilot', '22334455667', '05559002345', 'deniz.kaptan@airline.com', '1982-07-20', '2012-08-15', 42000.00, 'CPL-23456', '2027-08-15'),
('P003', 'Serkan', 'Uçar', 'Yardımcı Pilot', '33445566778', '05559003456', 'serkan.ucar@airline.com', '1988-11-10', '2015-03-20', 32000.00, 'CPL-34567', '2026-03-20'),
('P004', 'Gizem', 'Kanat', 'Hostes', '44556677889', '05559004567', 'gizem.kanat@airline.com', '1992-05-25', '2018-01-10', 18000.00, NULL, NULL),
('P005', 'Emre', 'Gökyüzü', 'Yardımcı Pilot', '55667788990', '05559005678', 'emre.gokyuzu@airline.com', '1990-09-08', '2016-11-05', 30000.00, 'CPL-45678', '2026-11-05'),
('P006', 'Aslı', 'Bulut', 'Kabin Görevlisi', '66778899001', '05559006789', 'asli.bulut@airline.com', '1994-02-14', '2019-05-12', 17000.00, NULL, NULL),
('P007', 'Kemal', 'Yüksek', 'Pilot', '77889900112', '05559007890', 'kemal.yuksek@airline.com', '1978-12-30', '2008-04-18', 48000.00, 'CPL-56789', '2027-04-18'),
('P008', 'Nazlı', 'Göçmen', 'Hostes', '88990011223', '05559008901', 'nazli.gocmen@airline.com', '1993-08-19', '2017-09-22', 18500.00, NULL, NULL),
('P009', 'Tolga', 'Motor', 'Mühendis', '99001122334', '05559009012', 'tolga.motor@airline.com', '1986-04-05', '2014-02-28', 35000.00, NULL, NULL),
('P010', 'Ceren', 'Hava', 'Kabin Görevlisi', '00112233445', '05559010123', 'ceren.hava@airline.com', '1996-10-11', '2020-07-15', 16500.00, NULL, NULL);

-- Uçuşlar
INSERT INTO Ucuslar (UcusNumarasi, KalkisHavaalaniID, VarisHavaalaniID, UcakID, UcusTarihi, KalkisSaati, VarisSaati, UcusSuresi, Fiyat, DoluKoltukSayisi, Durum) VALUES
('TK101', 1, 3, 1, '2026-03-10', '08:00', '09:15', 75, 450.00, 142, 'Planlandı'),
('TK102', 3, 1, 1, '2026-03-10', '10:30', '11:45', 75, 450.00, 135, 'Planlandı'),
('TK201', 1, 4, 2, '2026-03-11', '09:30', '11:00', 90, 550.00, 180, 'Planlandı'),
('TK202', 4, 1, 2, '2026-03-11', '12:00', '13:30', 90, 550.00, 165, 'Planlandı'),
('TK301', 2, 5, 3, '2026-03-12', '07:00', '08:15', 75, 400.00, 95, 'Planlandı'),
('TK302', 5, 2, 3, '2026-03-12', '09:30', '10:45', 75, 400.00, 88, 'Planlandı'),
('TK401', 1, 7, 7, '2026-03-13', '14:00', '15:30', 90, 600.00, 120, 'Planlandı'),
('TK402', 7, 1, 7, '2026-03-13', '16:30', '18:00', 90, 600.00, 110, 'Planlandı'),
('TK501', 3, 4, 5, '2026-03-14', '11:00', '12:30', 90, 500.00, 200, 'Planlandı'),
('TK502', 4, 3, 5, '2026-03-14', '13:30', '15:00', 90, 500.00, 195, 'Planlandı');

-- Rezervasyonlar
INSERT INTO Rezervasyonlar (YolcuID, UcusID, RezervasyonTarihi, KoltukNumarasi, BiletTipi, BiletFiyati, OdemeYontemi, PNRKodu, Durum) VALUES
(1, 1, '2026-02-20 10:30:00', '12A', 'Ekonomi', 450.00, 'Kredi Kartı', 'ABC123', 'Aktif'),
(2, 1, '2026-02-21 14:20:00', '12B', 'Ekonomi', 450.00, 'Kredi Kartı', 'ABC124', 'Aktif'),
(3, 3, '2026-02-22 09:15:00', '8C', 'Business', 850.00, 'Kredi Kartı', 'DEF125', 'Aktif'),
(4, 5, '2026-02-23 16:45:00', '15D', 'Ekonomi', 400.00, 'Nakit', 'GHI126', 'Aktif'),
(5, 7, '2026-02-24 11:30:00', '20A', 'Ekonomi', 600.00, 'Havale', 'JKL127', 'Aktif'),
(6, 2, '2026-02-25 13:20:00', '5B', 'Business', 750.00, 'Kredi Kartı', 'MNO128', 'Aktif'),
(7, 4, '2026-02-26 10:10:00', '18E', 'Ekonomi', 550.00, 'Kredi Kartı', 'PQR129', 'Aktif'),
(8, 6, '2026-02-27 15:50:00', '22C', 'Ekonomi', 400.00, 'Nakit', 'STU130', 'Aktif'),
(9, 8, '2026-02-28 12:40:00', '10F', 'First Class', 1200.00, 'Kredi Kartı', 'VWX131', 'Aktif'),
(10, 9, '2026-03-01 09:25:00', '14A', 'Ekonomi', 500.00, 'Havale', 'YZA132', 'Aktif'),
(1, 3, '2026-03-01 10:00:00', '9A', 'Ekonomi', 550.00, 'Kredi Kartı', 'BCD133', 'Aktif'),
(3, 5, '2026-03-02 14:30:00', '16B', 'Ekonomi', 400.00, 'Kredi Kartı', 'EFG134', 'Aktif');

-- Bakım Kayıtları
INSERT INTO BakimKayitlari (UcakID, BakimTipi, BaslangicTarihi, BitisTarihi, Aciklama, Maliyet, SorumluPersonelID, Durum) VALUES
(4, 'Rutin Bakım', '2026-02-28', '2026-03-05', 'Periyodik rutin bakım işlemleri', 25000.00, 9, 'Devam Ediyor'),
(8, 'Onarım', '2026-02-15', NULL, 'Motor arızası onarımı', 150000.00, 9, 'Devam Ediyor'),
(1, 'Periyodik Kontrol', '2026-01-15', '2026-01-16', 'Güvenlik kontrolleri', 5000.00, 9, 'Tamamlandı'),
(2, 'Periyodik Kontrol', '2026-02-10', '2026-02-11', 'Güvenlik ve teknik kontroller', 5500.00, 9, 'Tamamlandı'),
(5, 'Büyük Bakım', '2025-12-15', '2025-12-28', 'Yıllık büyük bakım', 80000.00, 9, 'Tamamlandı');

-- Uçuş Personeli
INSERT INTO UcusPersoneli (UcusID, PersonelID, Gorev) VALUES
(1, 1, 'Kaptan Pilot'),
(1, 3, 'Yardımcı Pilot'),
(1, 4, 'Kabin Amiri'),
(1, 6, 'Kabin Görevlisi'),
(2, 2, 'Kaptan Pilot'),
(2, 5, 'Yardımcı Pilot'),
(2, 8, 'Kabin Amiri'),
(3, 7, 'Kaptan Pilot'),
(3, 3, 'Yardımcı Pilot'),
(3, 4, 'Kabin Amiri'),
(3, 10, 'Kabin Görevlisi'),
(4, 1, 'Kaptan Pilot'),
(4, 5, 'Yardımcı Pilot'),
(4, 6, 'Kabin Amiri');

GO


