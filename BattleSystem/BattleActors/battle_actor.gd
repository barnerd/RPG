class_name BattleActor extends Node2D

@export var abilityScene: Resource

# used to store multiples. i.e. Skeleton A, Skeleton B
@export var alias: String

@export var data: BattleActorData
var abilities: Array[Ability]
var active_ability: Ability

var battle_group: BattleSystem.Battle_Group

signal battleUI_ability_required(actor: BattleActor)


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
	print("this is an " + BattleSystem.Battle_Group.keys()[battle_group])
	# if battle_group = Player, then pause battle and launch UI
	if battle_group == BattleSystem.Battle_Group.ENEMY:
		active_ability = AI_pick_ability()
		if not active_ability:
			print("no ability to pick")
		start_ability()
	else:
		print("battleUI_ability_required emit")
		battleUI_ability_required.emit(self)


func AI_pick_ability() -> Ability:
	var new_ability = null
	for i in abilities:
		if i.state == AbilityData.State.IDLE:
			new_ability = i
			print(data.alias + " picked " + new_ability.data.alias)
			break
	return new_ability


func start_ability() -> void:
	if active_ability:
		update_abilitybar_UI()
		active_ability.start_ability()


func update_abilitybar_UI() -> void:
	if active_ability:
		$AbilityPanel/ProgressBar.timer = active_ability.timer
		$AbilityPanel/Name.text = active_ability.data.alias


func update_state_UI(ability: Ability, _old_state: AbilityData.State, new_state: AbilityData.State) -> void:
	if ability == active_ability:
		$AbilityPanel/State.text = AbilityData.State.keys()[new_state].to_pascal_case()
