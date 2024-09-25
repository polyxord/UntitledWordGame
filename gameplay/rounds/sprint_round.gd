class_name SprintRound
extends Round


@export var sprint_time := 120

var description: String:
	get:
		return "Sprint " + str(sprint_time) + "s"
