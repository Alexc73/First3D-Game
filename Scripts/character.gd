extends CharacterBody3D


const JUMP_VELOCITY = 4.5

@export var _walking_speed : float = 1
@export var _acceleration : float = 2
@export var _deceleration : float = 4
@export var _rotation_speed : float = PI * 2
var _angle_difference : float
var _xz_velocity : Vector3

@onready var _animation : AnimationTree = $AnimationTree
@onready var _rig : Node3D = $Rig

var _direction : Vector3

func move(direction : Vector3):
	_direction = direction

func _physics_process(delta: float) -> void:
#		If the Player is giving movement input, face that direction
	if _direction:
		_angle_difference = wrapf(atan2(_direction.x, _direction.z) - _rig.rotation.y, -PI, PI)
		_rig.rotation.y += clamp(_rotation_speed * delta, 0, abs(_angle_difference)) * sign(_angle_difference)
#	Copy the character's x and z velocity to isolate from y.
	_xz_velocity = Vector3(velocity.x, 0, velocity.z)
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	#var input_dir := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	#var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
#	Apply movement input to the xz velocity
	if _direction:
		_xz_velocity = _xz_velocity.move_toward(_direction * _walking_speed, _acceleration * delta)
	else:
		_xz_velocity = _xz_velocity.move_toward(Vector3.ZERO, _deceleration * delta)
	
	_animation.set("parameters/Locomotion/blend_position", _xz_velocity.length() / _walking_speed)
	
#	Apply adjusted xz velocity to the character
	velocity.x = _xz_velocity.x
	velocity.z = _xz_velocity.z
	move_and_slide()
