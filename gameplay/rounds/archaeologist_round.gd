class_name ArchaeologistRound
extends Round


@export var percent_to_find := 50

var description: String:
	get:
		return "Archaeologist " + str(percent_to_find) + "%"
