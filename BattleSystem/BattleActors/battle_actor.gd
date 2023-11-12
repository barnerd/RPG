extends Node2D
class_name BattleActor

const abilityScene = preload("res://BattleSystem/Abilities/ability.tscn")

# used to store multiples. i.e. Skeleton A, Skeleton B
@export var alias: String

@export var data: BattleActorData
var abilities: Array[Ability]
var active_ability: Ability


func _ready() -> void:
	$Sprite2D.set_texture(data.sprite)
	$Sprite2D.set_hframes(3)
	$Sprite2D.set_vframes(4)


func face_left(_left: bool = true) -> void:
	$Sprite2D.set_frame(3 if _left else 6) # 3 for left, 6 for right


func generate_ability_nodes(_battle_system: BattleSystem) -> void:
	# Add Ability nodes for each known ability
	for i in data.abilitiyLevels.keys():
		# i is ablityData; data.abilitiyLevels[i] is the level
		var instance = abilityScene.instantiate() as Ability
		instance.data = i
		instance.connect_battle_system_signals(_battle_system)
		abilities.append(instance)
		instance.ability_finished.connect(pick_ability)
		instance.ability_state_changed.connect(update_state_UI)
		add_child(instance)


func pick_ability() -> void:
	active_ability = null
	for i in abilities:
		if i.state == AbilityData.State.IDLE:
			active_ability = i
			print(data.alias + " picked " + active_ability.data.alias)
			break
	if not active_ability:
		print("no ability to pick")
	update_UI()
	active_ability.start_ability()


func update_UI() -> void:
	if active_ability:
		$AbilityPanel/ProgressBar.timer = active_ability.timer
		$AbilityPanel/Name.text = active_ability.data.alias


func update_state_UI(ability: Ability, _old_state: AbilityData.State, new_state: AbilityData.State) -> void:
	if ability == active_ability:
		$AbilityPanel/State.text = AbilityData.State.keys()[new_state].to_pascal_case()
