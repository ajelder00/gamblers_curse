extends Resource
class_name Damage

@export var damage_number := 0
@export var status := Global.Status.NOTHING
@export var duration := 0
@export var type := Dice.Type.STANDARD

# Factory method to quickly create a Damage instance
static func create(damage_number: int, status: Global.Status, duration: int, type: Dice.Type) -> Damage:
	var dmg = Damage.new()
	dmg.damage_number = damage_number
	dmg.status = status
	dmg.duration = duration
	dmg.type = type
	return dmg
