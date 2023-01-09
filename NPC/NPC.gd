extends KinematicBody

onready var agent: NavigationAgent = $NavigationAgent
onready var collision_area: Area = $Area
export var speed = 3.0

export var texture: Texture

export(NodePath) var player_path = "Player"
onready var player: Node = get_node(player_path)

export(NodePath) var gui_path = "GUI"
onready var gui: Node = get_node(gui_path)

export(NodePath) var animation_path = "AnimationPlayer"
onready var animation_player: AnimationPlayer = get_node(animation_path)

export(NodePath) var env_path = "WorldEnvironment"
onready var env: WorldEnvironment = get_node(env_path)

export(NodePath) var end_sound_path = "EndSound"
onready var end_sound: AudioStreamPlayer = get_node(end_sound_path)

export(NodePath) var die_sound_path = "DieSound"
onready var die_sound: AudioStreamPlayer = get_node(die_sound_path)

export var subtitles = "test1/test2/test3"
var sub_row = 0
var is_player_collides = false
var is_npc_dead = false
var billboard_direction = Vector3(0, 1, 0)
var mesh: MeshInstance

func _ready():
	mesh = get_node("MeshInstance")
	mesh.get_active_material(0).set_shader_param("is_black", false)

func _physics_process(delta):
	if agent:
		#agent.set_target_location(player.transform.origin)	
		var next = agent.get_next_location()
		var velocity = (next - transform.origin).normalized() * speed * delta
		#move_and_collide(velocity)
	
	# billboard sprite 
	var camera_pos = get_viewport().get_camera().global_transform.origin
	camera_pos.y = 0
	mesh.look_at(camera_pos, billboard_direction)
	mesh.rotation_degrees.x = 0
	
	# subs triggers
	var collisions = collision_area.get_overlapping_bodies()
	is_player_collides = collisions.has(player)
	
	# win animation
	

func _input(event):
   if event is InputEventMouseButton and Input.is_action_just_pressed("next_sub") and is_player_collides and !is_npc_dead:
	   change_subtitle()

func change_subtitle():
	var sub1: Label = gui.get_node("CanvasLayer/CenterContainer/Sub1")
	var sub2: Label = gui.get_node("CanvasLayer/CenterContainer/Sub1/Sub2")

	var text_array = subtitles.split('/')
	var text = text_array[sub_row]

	sub1.text = text
	sub2.text = text
	
	if sub_row >= text_array.size() - 1:
		is_npc_dead = true
		
		die()
	else:
		sub_row += 1

func die():
	mesh.get_active_material(0).set_shader_param("is_black", true)
	
	var count: Label = gui.get_node("CanvasLayer/Count")
	
	die_sound.play()	
	
	#win()
	
	if count.text == "":
		count.text = "01/09"
	else:
		# мне некогда разбираться со строками в годоте, у меня время поджимает
		var score = int(count.text.split('/').join('').split('0')[1])
		score += 1
		count.text = "0" + String(score) + "/09"
		
		if score == 8:
			win()
	
func win():
	var count: Label = gui.get_node("CanvasLayer/Count")
	var sub1: Label = gui.get_node("CanvasLayer/CenterContainer/Sub1")
	var sub2: Label = gui.get_node("CanvasLayer/CenterContainer/Sub1/Sub2")
	
	yield(get_tree().create_timer(6.0), "timeout")
	
	end_sound.play()
	
	player.is_win = true	
	animation_player.play("Win")
	
	count.text = ""
	sub1.text = ""
	sub2.text = ""
	
	yield(get_tree().create_timer(8), "timeout")

	env.environment.fog_depth_end = 35.0	

	get_tree().reload_current_scene()

