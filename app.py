from flask import Flask, render_template, request, redirect, url_for, flash, jsonify
import pyodbc
from datetime import datetime, date
import os

app = Flask(__name__)
app.secret_key = 'havayolu_gizli_anahtar_2026'

# Veritabanı bağlantı ayarları
DB_CONFIG = {
    'server': 'localhost\SQLEXPRESS',  # SQL Server adresi (örn: localhost veya IP)
    'database': 'HavayoluDB',
    'username': '',  # Windows Authentication kullanılıyorsa boş bırakın
    'password': '',
    'driver': '{ODBC Driver 17 for SQL Server}'  # veya {SQL Server}
}

def get_db_connection():
    """Veritabanı bağlantısı oluşturur"""
    try:
        if DB_CONFIG['username']:
            conn_str = (
                f"DRIVER={DB_CONFIG['driver']};"
                f"SERVER={DB_CONFIG['server']};"
                f"DATABASE={DB_CONFIG['database']};"
                f"UID={DB_CONFIG['username']};"
                f"PWD={DB_CONFIG['password']}"
            )
        else:
            # Windows Authentication
            conn_str = (
                f"DRIVER={DB_CONFIG['driver']};"
                f"SERVER={DB_CONFIG['server']};"
                f"DATABASE={DB_CONFIG['database']};"
                f"Trusted_Connection=yes;"
            )
        conn = pyodbc.connect(conn_str)
        return conn
    except Exception as e:
        print(f"Veritabanı bağlantı hatası: {e}")
        return None

# Ana Sayfa
@app.route('/')
def index():
    """Ana sayfa - Dashboard"""
    conn = get_db_connection()
    if not conn:
        flash('Veritabanı bağlantısı kurulamadı!', 'danger')
        return render_template('index.html', stats={})
    
    cursor = conn.cursor()
    
    # İstatistikler
    stats = {}
    
    # Toplam uçuş sayısı
    cursor.execute("SELECT COUNT(*) FROM Ucuslar")
    stats['toplam_ucus'] = cursor.fetchone()[0]
    
    # Toplam yolcu sayısı
    cursor.execute("SELECT COUNT(*) FROM Yolcular")
    stats['toplam_yolcu'] = cursor.fetchone()[0]
    
    # Aktif uçak sayısı
    cursor.execute("SELECT COUNT(*) FROM Ucaklar WHERE Durum = 'Aktif'")
    stats['aktif_ucak'] = cursor.fetchone()[0]
    
    # Bugünkü uçuşlar
    cursor.execute("SELECT COUNT(*) FROM Ucuslar WHERE UcusTarihi = CAST(GETDATE() AS DATE)")
    stats['bugunun_ucuslari'] = cursor.fetchone()[0]
    
    # Toplam rezervasyon sayısı
    cursor.execute("SELECT COUNT(*) FROM Rezervasyonlar WHERE Durum = 'Aktif'")
    stats['aktif_rezervasyon'] = cursor.fetchone()[0]
    
    # Son 5 uçuş
    cursor.execute("""
        SELECT TOP 5 
            UcusNumarasi, UcusTarihi, KalkisSehir, VarisSehir, Durum 
        FROM vw_UcusDetaylari 
        ORDER BY UcusTarihi DESC
    """)
    stats['son_ucuslar'] = cursor.fetchall()
    
    conn.close()
    
    return render_template('index.html', stats=stats)

# UÇUŞLAR
@app.route('/ucuslar')
def ucuslar():
    """Tüm uçuşları listeler"""
    conn = get_db_connection()
    if not conn:
        flash('Veritabanı bağlantısı kurulamadı!', 'danger')
        return redirect(url_for('index'))
    
    cursor = conn.cursor()
    cursor.execute("""
        SELECT * FROM vw_UcusDetaylari 
        ORDER BY UcusTarihi DESC, KalkisSaati DESC
    """)
    ucuslar = cursor.fetchall()
    conn.close()
    
    return render_template('ucuslar.html', ucuslar=ucuslar)

@app.route('/ucus/ekle', methods=['GET', 'POST'])
def ucus_ekle():
    """Yeni uçuş ekler"""
    conn = get_db_connection()
    if not conn:
        flash('Veritabanı bağlantısı kurulamadı!', 'danger')
        return redirect(url_for('ucuslar'))
    
    cursor = conn.cursor()
    
    if request.method == 'POST':
        try:
            ucus_numarasi = request.form['ucus_numarasi']
            kalkis_havalimani = request.form['kalkis_havalimani']
            varis_havalimani = request.form['varis_havalimani']
            ucak_id = request.form['ucak_id']
            ucus_tarihi = request.form['ucus_tarihi']
            kalkis_saati = request.form['kalkis_saati']
            varis_saati = request.form['varis_saati']
            ucus_suresi = request.form['ucus_suresi']
            fiyat = request.form['fiyat']
            
            cursor.execute("""
                INSERT INTO Ucuslar 
                (UcusNumarasi, KalkisHavaalaniID, VarisHavaalaniID, UcakID, 
                 UcusTarihi, KalkisSaati, VarisSaati, UcusSuresi, Fiyat, Durum)
                VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, 'Planlandı')
            """, (ucus_numarasi, kalkis_havalimani, varis_havalimani, ucak_id,
                  ucus_tarihi, kalkis_saati, varis_saati, ucus_suresi, fiyat))
            
            conn.commit()
            flash('Uçuş başarıyla eklendi!', 'success')
            return redirect(url_for('ucuslar'))
        except Exception as e:
            flash(f'Hata: {str(e)}', 'danger')
    
    # Havalimanları ve uçakları getir
    cursor.execute("SELECT HavaalaniID, HavaalaniAdi, Sehir FROM Havaalanlari WHERE Aktif = 1")
    havaalanlari = cursor.fetchall()
    
    cursor.execute("SELECT UcakID, KodNumarasi, Marka, Model FROM Ucaklar WHERE Durum = 'Aktif'")
    ucaklar = cursor.fetchall()
    
    conn.close()
    
    return render_template('ucus_ekle.html', havaalanlari=havaalanlari, ucaklar=ucaklar)

# YOLCULAR
@app.route('/yolcular')
def yolcular():
    """Tüm yolcuları listeler"""
    conn = get_db_connection()
    if not conn:
        flash('Veritabanı bağlantısı kurulamadı!', 'danger')
        return redirect(url_for('index'))
    
    cursor = conn.cursor()
    cursor.execute("SELECT * FROM Yolcular ORDER BY YolcuID DESC")
    yolcular = cursor.fetchall()
    conn.close()
    
    return render_template('yolcular.html', yolcular=yolcular)

@app.route('/yolcu/ekle', methods=['GET', 'POST'])
def yolcu_ekle():
    """Yeni yolcu ekler"""
    if request.method == 'POST':
        conn = get_db_connection()
        if not conn:
            flash('Veritabanı bağlantısı kurulamadı!', 'danger')
            return redirect(url_for('yolcular'))
        
        cursor = conn.cursor()
        
        try:
            yolcu_numarasi = request.form['yolcu_numarasi']
            ad = request.form['ad']
            soyad = request.form['soyad']
            telefon_ev = request.form.get('telefon_ev', '')
            telefon_is = request.form.get('telefon_is', '')
            telefon_cep = request.form['telefon_cep']
            email = request.form.get('email', '')
            adres = request.form.get('adres', '')
            dogum_tarihi = request.form.get('dogum_tarihi', None)
            tc_kimlik = request.form.get('tc_kimlik', '')
            
            cursor.execute("""
                INSERT INTO Yolcular 
                (YolcuNumarasi, Ad, Soyad, TelefonEv, TelefonIs, TelefonCep, 
                 Email, Adres, DogumTarihi, TCKimlikNo)
                VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
            """, (yolcu_numarasi, ad, soyad, telefon_ev or None, telefon_is or None,
                  telefon_cep, email or None, adres or None, dogum_tarihi or None, tc_kimlik or None))
            
            conn.commit()
            flash('Yolcu başarıyla eklendi!', 'success')
            return redirect(url_for('yolcular'))
        except Exception as e:
            flash(f'Hata: {str(e)}', 'danger')
        finally:
            conn.close()
    
    return render_template('yolcu_ekle.html')

# REZERVASYONLAR
@app.route('/rezervasyonlar')
def rezervasyonlar():
    """Tüm rezervasyonları listeler"""
    conn = get_db_connection()
    if not conn:
        flash('Veritabanı bağlantısı kurulamadı!', 'danger')
        return redirect(url_for('index'))
    
    cursor = conn.cursor()
    cursor.execute("SELECT * FROM vw_RezervasyonDetaylari ORDER BY UcusTarihi DESC")
    rezervasyonlar = cursor.fetchall()
    conn.close()
    
    return render_template('rezervasyonlar.html', rezervasyonlar=rezervasyonlar)

@app.route('/rezervasyon/ekle', methods=['GET', 'POST'])
def rezervasyon_ekle():
    """Yeni rezervasyon ekler"""
    conn = get_db_connection()
    if not conn:
        flash('Veritabanı bağlantısı kurulamadı!', 'danger')
        return redirect(url_for('rezervasyonlar'))
    
    cursor = conn.cursor()
    
    if request.method == 'POST':
        try:
            yolcu_id = request.form['yolcu_id']
            ucus_id = request.form['ucus_id']
            koltuk_numarasi = request.form['koltuk_numarasi']
            bilet_tipi = request.form['bilet_tipi']
            bilet_fiyati = request.form['bilet_fiyati']
            odeme_yontemi = request.form['odeme_yontemi']
            pnr_kodu = request.form['pnr_kodu']
            
            cursor.execute("""
                INSERT INTO Rezervasyonlar 
                (YolcuID, UcusID, KoltukNumarasi, BiletTipi, BiletFiyati, 
                 OdemeYontemi, PNRKodu, Durum)
                VALUES (?, ?, ?, ?, ?, ?, ?, 'Aktif')
            """, (yolcu_id, ucus_id, koltuk_numarasi, bilet_tipi, 
                  bilet_fiyati, odeme_yontemi, pnr_kodu))
            
            # Uçuştaki dolu koltuk sayısını güncelle
            cursor.execute("""
                UPDATE Ucuslar 
                SET DoluKoltukSayisi = DoluKoltukSayisi + 1 
                WHERE UcusID = ?
            """, (ucus_id,))
            
            conn.commit()
            flash('Rezervasyon başarıyla oluşturuldu!', 'success')
            return redirect(url_for('rezervasyonlar'))
        except Exception as e:
            flash(f'Hata: {str(e)}', 'danger')
    
    # Yolcular ve uçuşları getir
    cursor.execute("SELECT YolcuID, YolcuNumarasi, Ad, Soyad FROM Yolcular")
    yolcular = cursor.fetchall()
    
    cursor.execute("""
        SELECT UcusID, UcusNumarasi, 
               CONCAT(KalkisSehir, ' - ', VarisSehir, ' (', 
                      CONVERT(VARCHAR, UcusTarihi, 104), ')') AS UcusBilgisi
        FROM vw_UcusDetaylari 
        WHERE UcusTarihi >= CAST(GETDATE() AS DATE)
        ORDER BY UcusTarihi
    """)
    ucuslar = cursor.fetchall()
    
    conn.close()
    
    return render_template('rezervasyon_ekle.html', yolcular=yolcular, ucuslar=ucuslar)

# UÇAKLAR
@app.route('/ucaklar')
def ucaklar():
    """Tüm uçakları listeler"""
    conn = get_db_connection()
    if not conn:
        flash('Veritabanı bağlantısı kurulamadı!', 'danger')
        return redirect(url_for('index'))
    
    cursor = conn.cursor()
    cursor.execute("SELECT * FROM Ucaklar ORDER BY UcakID")
    ucaklar = cursor.fetchall()
    conn.close()
    
    return render_template('ucaklar.html', ucaklar=ucaklar)

@app.route('/ucak/ekle', methods=['GET', 'POST'])
def ucak_ekle():
    """Yeni uçak ekler"""
    if request.method == 'POST':
        conn = get_db_connection()
        if not conn:
            flash('Veritabanı bağlantısı kurulamadı!', 'danger')
            return redirect(url_for('ucaklar'))
        
        cursor = conn.cursor()
        
        try:
            kod_numarasi = request.form['kod_numarasi']
            marka = request.form['marka']
            model = request.form['model']
            yolcu_kapasitesi = request.form['yolcu_kapasitesi']
            menzil = request.form['menzil']
            durum = request.form['durum']
            uretim_yili = request.form.get('uretim_yili', None)
            son_bakim_tarihi = request.form.get('son_bakim_tarihi', None)
            
            cursor.execute("""
                INSERT INTO Ucaklar 
                (KodNumarasi, Marka, Model, YolcuKapasitesi, Menzil, Durum, 
                 UretimYili, SonBakimTarihi)
                VALUES (?, ?, ?, ?, ?, ?, ?, ?)
            """, (kod_numarasi, marka, model, yolcu_kapasitesi, menzil, durum,
                  uretim_yili or None, son_bakim_tarihi or None))
            
            conn.commit()
            flash('Uçak başarıyla eklendi!', 'success')
            return redirect(url_for('ucaklar'))
        except Exception as e:
            flash(f'Hata: {str(e)}', 'danger')
        finally:
            conn.close()
    
    return render_template('ucak_ekle.html')

# PERSONEL
@app.route('/personel')
def personel():
    """Tüm personeli listeler"""
    conn = get_db_connection()
    if not conn:
        flash('Veritabanı bağlantısı kurulamadı!', 'danger')
        return redirect(url_for('index'))
    
    cursor = conn.cursor()
    cursor.execute("SELECT * FROM Personel WHERE Aktif = 1 ORDER BY PersonelID")
    personel = cursor.fetchall()
    conn.close()
    
    return render_template('personel.html', personel=personel)

# HAVAALANLARI
@app.route('/havaalanlari')
def havaalanlari():
    """Tüm havalimanlarını listeler"""
    conn = get_db_connection()
    if not conn:
        flash('Veritabanı bağlantısı kurulamadı!', 'danger')
        return redirect(url_for('index'))
    
    cursor = conn.cursor()
    cursor.execute("SELECT * FROM Havaalanlari WHERE Aktif = 1 ORDER BY Sehir")
    havaalanlari = cursor.fetchall()
    conn.close()
    
    return render_template('havaalanlari.html', havaalanlari=havaalanlari)

# BAKIM KAYITLARI
@app.route('/bakim-kayitlari')
def bakim_kayitlari():
    """Tüm bakım kayıtlarını listeler"""
    conn = get_db_connection()
    if not conn:
        flash('Veritabanı bağlantısı kurulamadı!', 'danger')
        return redirect(url_for('index'))
    
    cursor = conn.cursor()
    cursor.execute("""
        SELECT 
            b.BakimID,
            u.KodNumarasi,
            u.Marka + ' ' + u.Model AS UcakModeli,
            b.BakimTipi,
            b.BaslangicTarihi,
            b.BitisTarihi,
            b.Aciklama,
            b.Maliyet,
            p.Ad + ' ' + p.Soyad AS SorumluPersonel,
            b.Durum
        FROM BakimKayitlari b
        INNER JOIN Ucaklar u ON b.UcakID = u.UcakID
        LEFT JOIN Personel p ON b.SorumluPersonelID = p.PersonelID
        ORDER BY b.BaslangicTarihi DESC
    """)
    bakim_kayitlari = cursor.fetchall()
    conn.close()
    
    return render_template('bakim_kayitlari.html', bakim_kayitlari=bakim_kayitlari)

# RAPORLAR
@app.route('/raporlar')
def raporlar():
    """Çeşitli raporları gösterir"""
    conn = get_db_connection()
    if not conn:
        flash('Veritabanı bağlantısı kurulamadı!', 'danger')
        return redirect(url_for('index'))
    
    cursor = conn.cursor()
    
    # En çok kullanılan havalimanları
    cursor.execute("""
        SELECT TOP 5 
            h.HavaalaniAdi, 
            h.Sehir,
            COUNT(*) AS UcusSayisi
        FROM Ucuslar u
        INNER JOIN Havaalanlari h ON u.KalkisHavaalaniID = h.HavaalaniID OR u.VarisHavaalaniID = h.HavaalaniID
        GROUP BY h.HavaalaniAdi, h.Sehir
        ORDER BY UcusSayisi DESC
    """)
    populer_havaalanlari = cursor.fetchall()
    
    # En çok uçuş yapan uçaklar
    cursor.execute("""
        SELECT TOP 5
            uc.KodNumarasi,
            uc.Marka + ' ' + uc.Model AS Model,
            COUNT(*) AS UcusSayisi
        FROM Ucuslar u
        INNER JOIN Ucaklar uc ON u.UcakID = uc.UcakID
        GROUP BY uc.KodNumarasi, uc.Marka, uc.Model
        ORDER BY UcusSayisi DESC
    """)
    en_cok_ucus_yapan = cursor.fetchall()
    
    # Aylık gelir raporu
    cursor.execute("""
        SELECT 
            YEAR(RezervasyonTarihi) AS Yil,
            MONTH(RezervasyonTarihi) AS Ay,
            COUNT(*) AS RezervasyonSayisi,
            SUM(BiletFiyati) AS ToplamGelir
        FROM Rezervasyonlar
        WHERE Durum = 'Aktif'
        GROUP BY YEAR(RezervasyonTarihi), MONTH(RezervasyonTarihi)
        ORDER BY Yil DESC, Ay DESC
    """)
    aylik_gelir = cursor.fetchall()
    
    conn.close()
    
    return render_template('raporlar.html', 
                         populer_havaalanlari=populer_havaalanlari,
                         en_cok_ucus_yapan=en_cok_ucus_yapan,
                         aylik_gelir=aylik_gelir)

# API - Uçuş Arama
@app.route('/api/ucus-ara')
def api_ucus_ara():
    """Uçuş arama API'si"""
    kalkis = request.args.get('kalkis', '')
    varis = request.args.get('varis', '')
    tarih = request.args.get('tarih', '')
    
    conn = get_db_connection()
    if not conn:
        return jsonify({'error': 'Veritabanı bağlantısı kurulamadı'}), 500
    
    cursor = conn.cursor()
    
    query = "SELECT * FROM vw_UcusDetaylari WHERE 1=1"
    params = []
    
    if kalkis:
        query += " AND KalkisSehir LIKE ?"
        params.append(f'%{kalkis}%')
    
    if varis:
        query += " AND VarisSehir LIKE ?"
        params.append(f'%{varis}%')
    
    if tarih:
        query += " AND UcusTarihi = ?"
        params.append(tarih)
    
    query += " ORDER BY UcusTarihi, KalkisSaati"
    
    cursor.execute(query, params)
    ucuslar = cursor.fetchall()
    conn.close()
    
    # Sonuçları dict listesine çevir
    results = []
    for ucus in ucuslar:
        results.append({
            'ucus_numarasi': ucus[0],
            'ucus_tarihi': str(ucus[1]),
            'kalkis_saati': str(ucus[2]),
            'varis_saati': str(ucus[3]),
            'kalkis_havaalanimi': ucus[4],
            'kalkis_sehir': ucus[5],
            'varis_havaalanimi': ucus[6],
            'varis_sehir': ucus[7],
            'ucak_kodu': ucus[8],
            'ucak_modeli': ucus[9],
            'yolcu_kapasitesi': ucus[10],
            'dolu_koltuk': ucus[11],
            'fiyat': float(ucus[12]),
            'durum': ucus[13]
        })
    
    return jsonify(results)

if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0', port=5000)
