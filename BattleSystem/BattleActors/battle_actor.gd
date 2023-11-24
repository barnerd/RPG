class_name BattleActor extends Node2D

@export var abilityScene: Resource

# used to store multiples. i.e. Skeleton A, Skeleton B
@export var alias: String

@export var data: BattleActorData: set = set_data
var abilities: Array[Ability]
var active_ability: Ability

@export_group("Stats")
@export var current_health: int: set = set_current_health
@export var current_strength: int: set = set_current_strength
var str: int: 
	get: return current_strength
@export var current_dexterity: int: set = set_current_dexterity
var dex: int: 
	get: return current_dexterity
@export var current_constitution: int: set = set_current_constitution
var con: int:
	get: return current_constitution
var battle_group: BattleSystem.Battle_Group
var battle_system: BattleSystem

signal battleUI_ability_required(actor: BattleActor)
signal health_changed(old_value:int, new_value:int)
signal actor_died(actor: BattleActor)


func _ready() -> void:
	$Sprite2D.set_texture(data.sprite)
	$Sprite2D.set_hframes(3)
	$Sprite2D.set_vframes(4)


func set_data(_data: BattleActorData) -> void:
	data = _data
	current_health = data.max_health
	current_strength = data.max_strength
	current_dexterity = data.max_dexterity
	current_constitution = data.max_constitution


func set_current_health(_value: int) -> void:
	var old_health = current_health
	current_health = _value
	health_changed.emit(old_health, current_health)


func set_current_strength(_value: int) -> void:
	current_strength = _value


func set_current_dexterity(_value: int) -> void:
	current_dexterity = _value


func set_current_constitution(_value: int) -> void:
	current_constitution = _value


func take_damage(_damage: int) -> void:
	current_health -= _damage
	if current_health <= 0:
		_actor_death()


func _actor_death() -> void:
	actor_died.emit(self)
	queue_free()


func face_left(_left: bool = true) -> void:
	$Sprite2D.set_frame(3 if _left else 6) # 3 for left, 6 for right


func generate_ability_nodes(_battle_system: BattleSystem) -> void:
	# Add Ability nodes for each known ability
	for i in data.abilitiyLevels.keys():
		# i is ablityData; data.abilitiyLevels[i] is the level
		var instance = abilityScene.instantiate() as Ability
		instance.data = i
		instance.actor = self
		instance.connect_battle_system_signals(_battle_system)
		abilities.append(instance)
		instance.ability_finished.connect(pick_ability)
		instance.ability_state_changed.connect(update_state_UI)
		instance.ability_performed.connect(_battle_system.combat_calculator.ability_performed)
		add_child(instance)


func pick_ability() -> void:
	if battle_group == BattleSystem.Battle_Group.ENEMY:
		active_ability = AI_pick_ability()
		if not active_ability:
			print("no ability to pick")
		start_ability()
	else:
		# print("battleUI_ability_required emit")
		battleUI_ability_required.emit(self)


func AI_pick_ability() -> Ability:
	var new_ability = null
	for i in abilities:
		if i.state == AbilityData.State.IDLE:
			new_ability = i
			print(data.alias + " picked " + new_ability.data.alias)
			break
	
	# set targets
	var targets
	var all_actors = battle_system.get_battle_actors_by_group()
	for i in all_actors.keys():
		if i != battle_group:
			targets = all_actors[i]
	new_ability.set_targets(targets)

	return new_ability


func check_targets(_actor: BattleActor) -> void:
	if active_ability.targets.find(_actor) != -1 && active_ability.state == AbilityData.State.CHARGE_UP:
		active_ability.stop_ability()


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
