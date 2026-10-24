extends RefCounted

const Configuration = preload("res://src/generation/level_configuration.gd")


static func get_configuration(difficulty: String) -> Configuration:
	match difficulty:
		"easy":
			return Configuration.new("easy_001", "Easy", 5, 5, 5, 104729)
		"medium":
			return Configuration.new("medium_001", "Medium", 7, 7, 10, 130363)
		"hard":
			return Configuration.new("hard_001", "Hard", 9, 9, 16, 155921)
	return null
