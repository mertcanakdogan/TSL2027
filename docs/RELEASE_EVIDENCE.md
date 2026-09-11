# Release Evidence

Bu dosya yerel release doğrulamasının son ölçülebilir kanıtını tutar. Bu
kanıt, bağımsız başka bir Windows bilgisayarında uyumluluk veya imzalı
dağıtım iddiası değildir.

## Son doğrulama

- Tarih: 2026-09-11
- İşletim sistemi: Windows 11 Home, build 26200
- Godot: 4.7.2 stable
- Veri paketi: 18 takım, 324 sentetik oyuncu
- Godot testleri: 10/10 başarılı
- Sezon sonu özeti: hafta 35 sınırı ve 34 haftalık dashboard smoke akışı başarılı
- Editor headless parse/import: başarılı
- Python veri validator ve 9 kontrat testi: başarılı
- Windows export: başarılı, runtime smoke `exit 0`
- Portable ZIP: başarılı, fresh-directory runtime smoke `exit 0`
- Export/package verifier Windows preset'i tek argüman olarak iletiyor ve PowerShell wrapper'ının boş exit-code alanını log/artifact/runtime kanıtıyla doğruluyor.
- Release smoke cleanup transient dosya kilitlerine karşı retry döngüsü kullanıyor; son çalıştırmada cleanup warning oluşmadı.

Çalıştırılan tek komut:

```powershell
.\tools\verify_project.ps1 -GodotPath "C:\path\to\Godot_v4.7.2-stable_win64.exe"
```

## Son yerel artifact

- Executable: `build/TSL2027.exe`, 109485104 bytes
- Portable package: `dist/TSL2027-windows-x64.zip`, 38192186 bytes
- SHA256: `8C875573CB9CBFAC7A595E9CBF24DF0A43218E42E1177076531FEAE8C0ECCC85`

`build/` ve `dist/` generated output olduğu için Git'e eklenmez. ZIP'in içinde
executable, README, MIT LICENSE ve `docs/DATA_AND_LICENSING.md` bulunur.

Özel/offline kullanım için portable ZIP formatı seçilmiştir.

## Açık dış kapı

Bu ortamda bağımsız temiz Windows makinesi, installer derleyicisi ve code-signing
sertifikası bulunmadığı için public dağıtımın bu üç kabulü henüz doğrulanmadı.
