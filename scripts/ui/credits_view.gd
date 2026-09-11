class_name CreditsView
extends VBoxContainer

const COLOR_PANEL := Color(0.090196, 0.105882, 0.137255, 1.0)
const COLOR_PANEL_ALT := Color(0.121569, 0.137255, 0.172549, 1.0)
const COLOR_ACCENT := Color(0.87451, 0.168627, 0.164706, 1.0)
const COLOR_BLUE := Color(0.0, 0.501961, 0.705882, 1.0)
const COLOR_TEXT := Color(0.95, 0.96, 0.98, 1.0)
const COLOR_MUTED := Color(0.62, 0.66, 0.72, 1.0)
const COLOR_SUCCESS := Color(0.0, 0.588235, 0.431373, 1.0)

var source_label: Label
var policy_label: Label
var built: bool = false

func _ready() -> void:
	setup()

func setup() -> void:
	if built:
		return
	_build_ui()
	built = true

func _build_ui() -> void:
	custom_minimum_size = Vector2(880, 0)
	add_theme_constant_override("separation", 14)

	var header := VBoxContainer.new()
	add_child(header)
	header.add_child(_make_label("Credits & Veri Politikası", 24, COLOR_TEXT))
	header.add_child(_make_label("Bu prototipte hangi içeriklerin kullanıldığını ve lisans sınırlarını buradan görebilirsin.", 14, COLOR_MUTED))

	source_label = _add_info_panel(
		"KAYNAK KODU",
		"TSL2027'nin bu repoya ait özgün kaynak kodu MIT License kapsamındadır. MIT lisansı üçüncü taraf futbol verileri, kulüp logoları, fotoğraflar veya API çıktıları için kullanım hakkı vermez.",
		COLOR_ACCENT
	)
	policy_label = _add_info_panel(
		"BU BUILD'DE KULLANILAN VERİ",
		"Bu sürüm lisans güvenli prototip amacıyla sentetik takım, oyuncu, fikstür ve ekonomi verisi kullanır. Gerçek oyuncu adı/istatistiği, kulüp logosu, fotoğraf veya canlı veri sağlayıcısı entegrasyonu içermez.",
		COLOR_SUCCESS
	)
	_add_info_panel(
		"GERÇEK VERİ EKLEMEDEN ÖNCE",
		"Kaynak, kullanım hakkı, çekim tarihi, veri kapsamı ve dönüşüm sürümü kayıt altına alınmadan gerçek veri dağıtıma eklenmez. Ücretsiz ve özel kullanım sınırı aşılırsa entegrasyon durdurulur.",
		COLOR_BLUE
	)

	var links := _make_label("Motor: Godot 4 / GDScript • Godot lisansı: https://godotengine.org/license\nProje: https://github.com/mertcanakdogan/TSL2027", 13, COLOR_MUTED)
	links.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	add_child(links)

func _add_info_panel(title_text: String, body_text: String, border_color: Color) -> Label:
	var panel := PanelContainer.new()
	panel.add_theme_stylebox_override("panel", _make_panel_style(COLOR_PANEL, border_color))
	add_child(panel)
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 8)
	panel.add_child(box)
	box.add_child(_make_label(title_text, 11, COLOR_MUTED))
	var body := _make_label(body_text, 15, COLOR_TEXT)
	body.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	body.custom_minimum_size = Vector2(0, 54)
	box.add_child(body)
	return body

func _make_label(text_value: String, font_size: int = 16, font_color: Color = COLOR_TEXT) -> Label:
	var label := Label.new()
	label.text = text_value
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", font_color)
	return label

func _make_panel_style(background_color: Color, border_color: Color) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = background_color
	style.border_color = border_color
	style.border_width_left = 1
	style.border_width_top = 1
	style.border_width_right = 1
	style.border_width_bottom = 1
	style.corner_radius_top_left = 8
	style.corner_radius_top_right = 8
	style.corner_radius_bottom_left = 8
	style.corner_radius_bottom_right = 8
	style.content_margin_left = 16
	style.content_margin_top = 14
	style.content_margin_right = 16
	style.content_margin_bottom = 14
	return style
