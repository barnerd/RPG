class_name AbilityData extends Resource

@export var alias: String

enum State {IDLE, CHARGE_UP, ACTION, COOLDOWN}

@export_category("Timers")
@export var chargeUpTime: float
@export var actionTime: float
@export var coolDownTime: float
