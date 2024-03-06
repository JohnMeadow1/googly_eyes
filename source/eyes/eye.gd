@tool
extends Node2D
var previous_position  := Vector2.ZERO
var velocity           := Vector2.ZERO
var distance_threshold := 0.0

@export_range(0.1, 2048.0) var eye_radius  := 936.0  : set = set_eye_radius
@export_range(0.1, 2048.0) var iris_radius := 572.0  : set = set_iris_radius
@export_range(0.01, 0.5) var iris_edge_margin := 0.05 : set = set_iris_margin

@export_range(0.0, 10.0) var velocity_damping := 1.0
@export_range(0.0, 10.0) var iris_friction := 0.2
@export var gravity := Vector2(0, 1000)

func _ready():
	update_threshold()
	
func set_eye_radius(in_value):
	eye_radius = in_value
	if eye_radius < iris_radius:
		iris_radius = eye_radius
	if not Engine.is_editor_hint():
		await ready
	%white.scale = Vector2.ONE * (eye_radius / 936.0)  # magic number is actual radius of the white circle
	%gloss.scale = %white.scale
	update_threshold()
	
func set_iris_radius(in_value):
	iris_radius = min(in_value, eye_radius)
	if not Engine.is_editor_hint():
		await ready
	%black.scale = Vector2.ONE * (iris_radius / 572.0) # magic number is actual radius of the black circle in the sprite
	update_threshold()

func set_iris_margin(in_value):
	iris_edge_margin = in_value
	update_threshold()

func set_gravity(value):
	gravity = value
	
func update_threshold():
	previous_position = global_position 
	distance_threshold = -(iris_radius - eye_radius) * (0.5-iris_edge_margin)
	
func _process(delta):
	velocity += gravity * delta
	velocity -= ( previous_position - global_position ) * iris_friction
	%black.position += ( previous_position - global_position ) 
	%black.position += velocity * delta
	
	if %black.position.length() > distance_threshold:
		velocity -= (( %black.position.length() - distance_threshold) * %black.position.normalized()) / delta
		%black.position = distance_threshold * %black.position.normalized()
		
	velocity -= velocity * velocity_damping * delta
	previous_position = global_position
