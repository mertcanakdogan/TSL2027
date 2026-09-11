# Release Evidence

Bu dosya yerel release doğrulamasının son ölçülebilir kanıtını tutar. Bu
kanıt, bağımsız başka bir Windows bilgisayarında uyumluluk veya imzalı
dağıtım iddiası değildir.

## Son doğrulama

- Tarih: 2026-09-11
- İşletim sistemi: Windows 11 Home, build 26200
- Godot: 4.7.2 stable
- Veri paketi: 18 takım, 324 sentetik oyuncu
- Godot testleri: 9/9 başarılı
- Editor headless parse/import: başarılı
- Python veri validator ve 9 kontrat testi: başarılı
- Windows export: başarılı, runtime smoke `exit 0`
- Portable ZIP: başarılı, fresh-directory runtime smoke `exit 0`

Çalıştırılan tek komut:

```powershell
.\tools\verify_project.ps1 -GodotPath "C:\path\to\Godot_v4.7.2-stable_win64.exe"
```

## Son yerel artifact

- Executable: `build/TSL2027.exe`, 109464984 bytes
- Portable package: `dist/TSL2027-windows-x64.zip`, 39352750 bytes
- SHA256: `F4D16EF963195AC2163906D2A10E0E33C58EDD02D8141DC590220EDFC5F6A2C7`

`build/` ve `dist/` generated output olduğu için Git'e eklenmez. ZIP'in içinde
executable, README, MIT LICENSE ve `docs/DATA_AND_LICENSING.md` bulunur.

## Açık dış kapı

Bu ortamda bağımsız temiz Windows makinesi, installer derleyicisi ve code-signing
sertifikası bulunmadığı için public dağıtımın bu üç kabulü henüz doğrulanmadı.
Özel/offline kullanım için portable ZIP formatı seçilmiştir.
