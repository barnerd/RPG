class_name Ability extends Node

@export var data: AbilityData

var state: AbilityData.State
@onready var timer: Timer = $Timer

var actor: BattleActor
var targets: Array[BattleActor]: set = set_targets

signal ability_finished()
signal ability_state_changed(ability: Ability, old_state: AbilityData.State, new_state: AbilityData.State)
signal ability_performed(actor: BattleActor, ability: Ability, targets: Array[BattleActor])


func _init() -> void:
	state = AbilityData.State.IDLE


func connect_battle_system_signals(_battle_system: BattleSystem) -> void:
	_battle_system.battle_paused.connect(_on_battle_system_battle_paused)


func _on_timer_timeout() -> void:
	var old_state: AbilityData.State = state
	match (state):
		AbilityData.State.CHARGE_UP:
			state = AbilityData.State.ACTION
			$Timer.start(data.actionTime)
		AbilityData.State.ACTION:
			perform_ability_action()
			state = AbilityData.State.COOLDOWN
			$Timer.start(data.coolDownTime)
			# choose new ability by emit signal
			ability_finished.emit()
		AbilityData.State.COOLDOWN:
			state = AbilityData.State.IDLE
	ability_state_changed.emit(self, old_state, state)


func start_ability() -> void:
	if(state == AbilityData.State.IDLE):
		state = AbilityData.State.CHARGE_UP
		$Timer.start(data.chargeUpTime)
		ability_state_changed.emit(self, AbilityData.State.IDLE, state)


func stop_ability() -> void:
	if(state == AbilityData.State.CHARGE_UP):
		state = AbilityData.State.IDLE
		$Timer.stop()
		ability_state_changed.emit(self, AbilityData.State.CHARGE_UP, state)


func perform_ability_action() -> void:
	ability_performed.emit(actor, self, targets)


func set_targets(_targets: Array[BattleActor]) -> void:
	targets = _targets;


func _on_battle_system_battle_paused(value: bool) -> void:
	$Timer.set_paused(value)
