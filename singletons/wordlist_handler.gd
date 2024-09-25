## A singleton that manages wordlist loading.
extends Node

## List of words used for word validation.
var wordlist: PackedStringArray


func _ready() -> void:
	var gameplay_settings := ConfigHandler.load_settings("gameplay")
	load_wordlist(gameplay_settings.wordlist_path)


## Loads in the wordlist file at the given path.
func load_wordlist(path: String) -> void:
	var wordlist_file := FileAccess.open(path, FileAccess.READ)
	wordlist = wordlist_file.get_as_text().split("\n", false)
