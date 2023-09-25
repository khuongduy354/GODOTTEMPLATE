extends CharacterBody2D
class_name Player

enum { MOVE, CLIMB, CAST,SWING }
var state = MOVE
var shaking = false 
@export var shake_density =1.0
@export var moveData = preload("res://Player/DefaultPlayMovementData.tres") as PlayerMovementData
@export var freeze=false 


@onready var ability_anim=$AbilityAnimationPlayer 
@onready var gun_anim = $GunAnimationPlayer
@onready var normal_anim = $AnimationPlayer
@onready var anim_p = normal_anim


@onready var ladderCheck: = $LadderCheck
@onready var jumpBufferTimer: = $JumpBufferTimer
@onready var coyoteJumpTimer: = $CoyoteJumpTimer

@onready var anim_p2 =$AnimationPlayer2
@onready var AbilityComponent = $AbilityComponent
@onready var TradeComp = $VendorInteract

var double_jump = 1
var on_door = false
var coyote_jump = false

@onready var HealthComponent = $HealthComponent
@onready var GunComp = $GunComponent
@onready var camera = $RemoteTransform2D.remote_path
var rng=RandomNumberGenerator.new()


func shake_screen(_shake_density=1.0,shake_duration=0.2): 
	shake_density=_shake_density
	shaking=true
	$shake_timer.wait_time=shake_duration
	$shake_timer.start()
func _process(delta):
	if shaking:
		camera_offset()
func camera_offset():
	camera.set_offset(Vector2(
		rng.randf_range(-1.0, 1.0) * shake_density, 
		rng.randf_range(-1.0, 1.0) * shake_density, 
	))
func buy_item(item:Item):
	$VendorInteract.buy_item(item)
func _ready(): 
	$PlayerUI._initialize(self)
	AbilityComponent._initialize(self)
	camera = get_node(camera)
	AbilityComponent.load_ability("incrementalgun")
	AbilityComponent.load_ability("shockwave")
	AbilityComponent.load_ability("floatinggun")
	AbilityComponent.load_ability("blessing")
	
	$Hurtbox.connect("hitted",Callable(self,"_hitted"))
	$HealthComponent.connect("out_of_health",Callable(self,"player_die"))
	GunComp.wield_gun(Global.GUN_TYPE.SHORTGUN)

func _hitted(): 
	print(HealthComponent.current_health)
	anim_p2.play("hurt")

func get_input(): 
	var input = Vector2.ZERO
	input.x = Input.get_axis("ui_left", "ui_right")
#	input.y = Input.get_axis("ui_up", "ui_down")
	return input

func _physics_process(delta):
	if freeze: 
		return
	var input = get_input()

	match state:
		MOVE: move_state(input, delta)
		CLIMB: climb_state(input)
		CAST: cast_state(delta)
func _on_shoot_finished():
	state=MOVE


func cast_state(delta): 
	apply_gravity(delta)
	AbilityComponent.cast()
	move_and_slide()
	
	

func pick_up(drop:Drop): 
	TradeComp.collect_loot(drop)
	pass

func spell_input(): 
	if Input.is_action_just_pressed("spell 1"): 
		AbilityComponent.active_spell=0
	elif Input.is_action_just_pressed("spell 2"): 
		AbilityComponent.active_spell=1
	elif Input.is_action_just_pressed("spell 3"): 
		AbilityComponent.active_spell=2
	elif Input.is_action_just_pressed("spell 4"): 
		AbilityComponent.active_spell=3
	else: 
		AbilityComponent.active_spell =-1
		return
	state = CAST
		
func move_state(input, delta):
	apply_gravity(delta)
	
	if is_on_ladder() and Input.is_action_just_pressed("jump"):
		state = CLIMB
	
	spell_input()

	velocity.x=input.x * moveData.MAX_SPEED
	if input.x>0: 
		$flip_pivot.scale.x=1
	elif input.x <0:
		$flip_pivot.scale.x=-1
		
	if Input.is_action_pressed("mouse_left"): 
		if GunComp.equipped: 
			var shoot_dir = Vector2.LEFT
			if $flip_pivot.scale.x==-1:
				shoot_dir=Vector2.LEFT
			else:
				shoot_dir =Vector2.RIGHT
			if velocity.x==0 and is_on_floor(): 
				gun_anim.play("recoil")

			GunComp.shoot(shoot_dir)
		
	elif input.x==0 and is_on_floor():
		apply_friction(delta)
		velocity=Vector2.ZERO
		if !GunComp.equipped: 
			anim_p.play("idle")
		else: 
			anim_p.play("RESET")
		
	if input.x!=0 and is_on_floor():
		anim_p.play("running")
	if !is_on_floor(): 
		anim_p.play("jumping")
		

				
	if is_on_floor():
		reset_double_jump()
	
	if can_jump():
		input_jump(delta)
	else:
		input_jump_release()
		input_double_jump()
#		buffer_jump()
		fast_fall(delta)
	
	var was_in_air = not is_on_floor()
	var was_on_floor = is_on_floor()
	
	move_and_slide()
	
	var just_landed = is_on_floor() and was_in_air
	if just_landed:
		anim_p.play("running")
	
	var just_left_ground = not is_on_floor() and was_on_floor
	if just_left_ground and velocity.y <= 0:
		coyote_jump = true
		coyoteJumpTimer.start()


#func _shock_wave_execute(): 
#	$AbilityComponent.execute("shockwave")
	


func climb_state(input):
	if not is_on_ladder(): state = MOVE
	var dir = Vector2.ZERO
	dir.x=input.x
	if Input.is_action_pressed("jump"):
		dir = Vector2.UP
	elif Input.is_action_pressed("down"):
		dir = Vector2.DOWN
	anim_p.play("idle")
	velocity = dir * moveData.CLIMB_SPEED
	move_and_slide()

func player_die():
#	SoundPlayer.play_sound(SoundPlayer.HURT)
	Events.emit_signal("player_died",self)
	Global.taco_lives-=1
	$PlayerUI.lose_taco_life()
	if Global.taco_lives <= 0: 
		queue_free()
		print("REAL DEATH, TO MAIN MENU")


#func _shockwave_finished(): 
#	GunComp.equip()
#	state = MOVE

func input_jump_release():
	if Input.is_action_just_released("jump") and velocity.y < moveData.JUMP_RELEASE_FORCE:
		velocity.y = moveData.JUMP_RELEASE_FORCE

func input_double_jump():
	if Input.is_action_just_pressed("jump") and double_jump > 0:
#		SoundPlayer.play_sound(SoundPlayer.JUMP)
		velocity.y = moveData.JUMP_FORCE
		double_jump -= 1


func fast_fall(delta):
	if velocity.y > 0:
		velocity.y += moveData.ADDITIONAL_FALL_GRAVITY * delta

func can_jump():
	return is_on_floor() or coyote_jump

func horizontal_move(input):
	return input.x != 0

func reset_double_jump():
	double_jump = moveData.DOUBLE_JUMP_COUNT

func input_jump(delta):
	if on_door: return
	if Input.is_action_pressed("jump") :
		velocity.y = moveData.JUMP_FORCE
#		buffered_jump = false
#
func is_on_ladder():
	var bodies = ladderCheck.get_overlapping_areas() 
	for collider in bodies: 
		if collider is Ladder: return true
	return false

func apply_gravity(delta):
	velocity.y += Global.GRAVITY * delta
	velocity.y = min(velocity.y, 300)

func apply_friction(delta):
	velocity.x = move_toward(velocity.x, 0, moveData.FRICION * delta)

func apply_acceleration(val, max, accel):
	val = move_toward(val, max, accel)
	return val
#



func _on_coyote_jump_timer_timeout():
	coyote_jump = false


func _on_shake_timer_timeout():
	shaking = false
