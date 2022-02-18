extends Control

@export_node_path var path_tracing_node

@onready var path_tracing = get_node(path_tracing_node) as PathTracing
@onready var texture_rect = $RenderedImage as TextureRect
@onready var fps = $FpsValueLabel as Label
@onready var button = $RenderButton as Button


func _ready() -> void:
	if (path_tracing.loop):
		button.hide()
	else:
		button.pressed.connect(_on_button_pressed)
		fps.hide()
	
	path_tracing.rendered.connect(_on_rendered)


func _on_rendered(texture: Texture, _render_time: int) -> void:
	texture_rect.texture = texture
	fps.text = str(1000 / _render_time)


func _on_button_pressed() -> void:
	path_tracing.render()


func _input(_event) -> void:
	if Input.is_action_just_pressed("ui_exit"):
		get_tree().quit()
