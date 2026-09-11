class_name TransferView
extends VBoxContainer

signal transfer_requested(player_id: String)

const COLOR_PANEL := Color(0.090196, 0.105882, 0.137255, 1.0)
const COLOR_PANEL_ALT := Color(0.121569, 0.137255, 0.172549, 1.0)
const COLOR_ACCENT := Color(0.87451, 0.168627, 0.164706, 1.0)
const COLOR_BLUE := Color(0.0, 0.501961, 0.705882, 1.0)
const COLOR_TEXT := Color(0.95, 0.96, 0.98, 1.0)
const COLOR_MUTED := Color(0.62, 0.66, 0.72, 1.0)
const COLOR_SUCCESS := Color(0.0, 0.588235, 0.431373, 1.0)

var market_state
var economy_state
var squad_state
var team_name: String = "Kocaelispor"
var subtitle_label: Label
var finance_label: Label
var feedback_label: Label
var offer_list: VBoxContainer
var built: bool = false

func setup(market, economy, squad, managed_team_name: String = "Kocaelispor") -> void:
	market_state = market
	economy_state = economy
	squad_state = squad
	team_name = managed_team_name
	if not built:
		_build_ui()
		built = true
	else:
		subtitle_label.text = "%s için sentetik transfer teklifleri" % team_name
	_refresh_ui()

func refresh() -> void:
	_refresh_ui()

func apply_result(message: String) -> void:
	feedback_label.text = message
	_refresh_ui()

func _build_ui() -> void:
	custom_minimum_size = Vector2(880, 0)
	add_theme_constant_override("separation", 14)
	var header := VBoxContainer.new()
	add_child(header)
	header.add_child(_make_label("Transfer", 24, COLOR_TEXT))
	subtitle_label = _make_label("%s için sentetik transfer teklifleri" % team_name, 14, COLOR_MUTED)
	header.add_child(subtitle_label)
	feedback_label = _make_label("İmza işlemleri bütçe ve maaş bütçesiyle doğrulanır.", 13, COLOR_SUCCESS)
	header.add_child(feedback_label)

	var finance_panel := PanelContainer.new()
	finance_panel.add_theme_stylebox_override("panel", _make_panel_style(COLOR_PANEL, COLOR_BLUE))
	add_child(finance_panel)
	finance_label = _make_label("Ekonomi yükleniyor", 16, COLOR_TEXT)
	finance_panel.add_child(finance_label)

	var market_panel := PanelContainer.new()
	market_panel.add_theme_stylebox_override("panel", _make_panel_style(COLOR_PANEL, COLOR_ACCENT))
	add_child(market_panel)
	var market_box := VBoxContainer.new()
	market_box.add_theme_constant_override("separation", 8)
	market_panel.add_child(market_box)
	market_box.add_child(_make_label("TRANSFER PAZARI • İLK 12 TEKLİF", 11, COLOR_MUTED))
	market_box.add_child(_make_label("Değerler sentetik prototip ekonomisidir; resmi piyasa değeri değildir.", 13, COLOR_MUTED))
	offer_list = VBoxContainer.new()
	offer_list.add_theme_constant_override("separation", 4)
	market_box.add_child(offer_list)

func _refresh_ui() -> void:
	if market_state == null or economy_state == null or offer_list == null:
		return
	finance_label.text = "Bakiye: ₺%d  •  Maaş: ₺%d / ₺%d haftalık  •  Kayıtlı sözleşme: %d" % [
		economy_state.balance,
		economy_state.committed_wages,
		economy_state.weekly_wage_budget,
		economy_state.contracts.size()
	]
	for child in offer_list.get_children():
		child.free()
	var offers: Array = market_state.get_offers(12)
	if offers.is_empty():
		offer_list.add_child(_make_label("Uygun transfer teklifi kalmadı.", 14, COLOR_MUTED))
		return
	for offer in offers:
		_add_offer_row(offer)

func _add_offer_row(offer: Dictionary) -> void:
	var player: Dictionary = offer["player"]
	var row := HBoxContainer.new()
	row.custom_minimum_size = Vector2(0, 38)
	offer_list.add_child(row)
	var label := _make_label(
		"%s  |  %s  |  bonservis ₺%d  |  maaş ₺%d/hafta" % [
			String(player.get("display_name", "Oyuncu")),
			String(player.get("position", "?")),
			int(offer.get("asking_fee", 0)),
			int(offer.get("weekly_wage", 0))
		],
		13,
		COLOR_TEXT
	)
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(label)
	var button := Button.new()
	button.text = "İmzala"
	button.custom_minimum_size = Vector2(82, 30)
	button.pressed.connect(_on_sign_pressed.bind(String(player.get("id", ""))))
	row.add_child(button)

func _on_sign_pressed(player_id: String) -> void:
	if not player_id.is_empty():
		transfer_requested.emit(player_id)

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
