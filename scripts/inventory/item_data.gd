class_name ItemData
extends Resource

enum Kind {
	TOOL,
	KEY,
	CONSUMABLE,
	INSECT,
	FISH,
	OTHER,
}

@export var item_id: StringName
@export var display_name: String = ""
@export var kind: Kind = Kind.OTHER
@export var icon: Texture2D


func is_valid_item() -> bool:
	return not item_id.is_empty() and not display_name.strip_edges().is_empty()
