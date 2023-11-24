class_name CombatCalculator extends Node

var rng = RandomNumberGenerator.new()

signal combat_activity_report_generated(report: CombatActivityReport)


func ability_performed(_actor: BattleActor, _ability: Ability, _targets: Array[BattleActor]) -> void:
	var report: CombatActivityReport = CombatActivityReport.new(_actor, _ability, _targets)
	
	# calculator ability effect
	var hitChance: float = CombatCalculator.get_hit_chance(_actor.dex, _targets[0].dex)
	var criticalChance: float = CombatCalculator.get_critical_chance(_actor.dex);
	var criticalStrength: float = CombatCalculator.get_critical_strength(_actor.str);
	report.hitSuccess = rng.randf_range(0, 1) <= hitChance
	report.critSuccess = rng.randf_range(0, 1) <= criticalChance
	report.totalDamage = (report.abilityData.damage + report.attacker.str) - _targets[0].con
	report.killShot = _targets[0].current_health <= report.totalDamage
	
	if report.critSuccess:
		print("critical hit!")
		report.totalDamage *= criticalStrength

	if report.killShot:
		print("finish him!")

	# perform ability effect on actors
	if report.hitSuccess:
		print("hit")
		print(report.attacker.alias + " used "+report.abilityData.alias+" for "+str(report.totalDamage)+" damage to " + _targets[0].alias)
		_targets[0].take_damage(report.totalDamage)
	else:
		print("miss")

	# send out combat report
	combat_activity_report_generated.emit(report)

static func get_hit_chance(_attacker: float, _defender: float) -> float:
	# TODO: this can divide by 0
	return _attacker / (_attacker + _defender * 0.66) # 0-100%


static func get_critical_chance(_attacker: float) -> float:
	return .25 * _attacker / 100 # 1-100 => 1-25%


static func get_critical_strength(_attacker: float) -> float:
	return .1 + pow(1.01, _attacker) # min: 1.11


class CombatActivityReport:
	# Attacker
	var attacker: BattleActor
	#AgentData.AgentType attackerType;
	#AgentData.AgentSubType attackerSubType;

	#WeaponData.WeaponType[] attackerWeaponType; 
	#WeaponData.DamageWeight[] attackerDamageWeight;

	var totalDamage: float
	#float physicalDamage;
	#float bludgeoningDamage;
	#float pierceDamage;
	#float slashDamage;
	#float elementalDamage;
	#float earthDamage;
	#float fireDamage;
	#float waterDamage;
	#float windDamage;

	# Defender
	var defender: BattleActor
	#AgentData.AgentType defenderType;
	#AgentData.AgentSubType defenderSubType;

	#float totalArmor;
	#float physicalArmor;
	#float bludgeoningArmor;
	#float pierceArmor;
	#float slashArmor;
	#float elementalArmor;
	#float earthResistance;
	#float fireResistance;
	#float waterResistance;
	#float windResistance;

	var abilityData: AbilityData

	var hitSuccess: bool
	var critSuccess: bool

	var killShot: bool

	func _init(_actor: BattleActor, _ability: Ability, _targets: Array[BattleActor]) -> void:
		self.attacker = _actor
		
		self.abilityData = _ability.data
		
		self.defender = _targets[0]

