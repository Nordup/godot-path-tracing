extends Control

@export var path_tracing: PathTracing

@onready var texture_rect = $RenderedImage as TextureRect
@onready var fps = $Panel/FpsValueLabel as Label
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
	fps.text = "FPS: " + str(Engine.get_frames_per_second())


func _on_button_pressed() -> void:
	path_tracing.render()


func _input(_event) -> void:
	if Input.is_action_just_pressed("ui_exit"):
		get_tree().quit()
