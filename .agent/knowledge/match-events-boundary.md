# Maç Olayları ve İstatistikleri Sınırı

2026-09-11 itibarıyla `MatchEngine.simulate()` skor/xG alanlarına ek olarak
seed'li `events` ve `match_stats` döndürür. Olaylar gol ve sarı kart gibi temel
özetlerdir; tam fiziksel maç simülasyonu değildir.

`LeagueState` sonucu değiştirmeden fixture içine taşır. `FixtureView` ve ana maç
merkezi yeni alanları yalnızca oynanmış yönetilen maçın okunabilir özetinde
gösterir. Değerler sentetik oyun modeli olarak etiketlenmeye devam eder.
