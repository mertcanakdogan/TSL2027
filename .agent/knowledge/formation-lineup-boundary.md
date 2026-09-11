# Formasyon ve İlk 11 Sınırı

2026-09-11 itibarıyla `FormationRules` desteklenen beş formasyonun GK/DF/MF/FW
pozisyon ihtiyaçlarını tek kaynaktan verir. `SquadState` kadro yeterliliğini ve
aktif ilk 11 dağılımını doğrular; starter/bench değişimi aktif dağılımı bozacaksa
atomik olarak reddedilir.

Taktikler ekranı formasyonu taslak olarak seçer. Gerçek state değişimi yalnızca
“Dizilişi Kadroya Uygula” eylemiyle olur; başarılı uygulama SquadState,
TacticsState ve LeagueState takım context'ini aynı değerde tutar.

Oyuncu alt rolleri henüz veri paketinde kanıtlanmış ayrı alanlar değildir. Bu
nedenle uygunluk yalnızca mevcut dört pozisyon grubuna dayanır; alt rol çıkarımı
yapılmaz.

Aktif formasyon save payload'una dahil edilir ve save schema sürümü 2'dir.
SquadState ile TacticsState formasyonları uyuşmayan kayıtlar yüklenmez.
