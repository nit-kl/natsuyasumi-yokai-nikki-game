extends Node

signal inventory_changed(item_id: StringName, count: int)
signal money_changed(money: int)

const CATALOG_DIR := "res://resources/items/"
const STARTING_ITEMS := {
	&"bug_net": 1,
}

var _items: Dictionary = {}
var _money: int = 0
var _catalog: Dictionary = {}


func _ready() -> void:
	_load_catalog()
	reset_state()


func add(item_id: StringName, amount: int = 1) -> bool:
	if item_id.is_empty() or amount <= 0 or not _catalog.has(item_id):
		return false
	var next_count := count(item_id) + amount
	_items[item_id] = next_count
	inventory_changed.emit(item_id, next_count)
	return true


func remove(item_id: StringName, amount: int = 1) -> bool:
	if item_id.is_empty() or amount <= 0 or count(item_id) < amount:
		return false
	var next_count := count(item_id) - amount
	if next_count == 0:
		_items.erase(item_id)
	else:
		_items[item_id] = next_count
	inventory_changed.emit(item_id, next_count)
	return true


func count(item_id: StringName) -> int:
	return int(_items.get(item_id, 0))


func has(item_id: StringName, amount: int = 1) -> bool:
	return amount > 0 and count(item_id) >= amount


func get_money() -> int:
	return _money


func add_money(amount: int) -> bool:
	if amount == 0:
		return false
	var next_money := _money + amount
	if next_money < 0:
		return false
	return set_money(next_money)


func set_money(value: int) -> bool:
	if value < 0:
		return false
	if value == _money:
		return true
	_money = value
	money_changed.emit(_money)
	return true


func debug_give_item(item_id: StringName, amount: int = 1) -> bool:
	return add(item_id, amount)


func debug_set_money(value: int) -> bool:
	return set_money(value)


func get_item_data(item_id: StringName) -> ItemData:
	return _catalog.get(item_id, null) as ItemData


func get_known_item_ids() -> Array[StringName]:
	var ids: Array[StringName] = []
	for item_id: Variant in _catalog.keys():
		ids.append(StringName(item_id))
	ids.sort_custom(func(a: StringName, b: StringName) -> bool: return String(a) < String(b))
	return ids


func get_owned_item_ids() -> Array[StringName]:
	var ids: Array[StringName] = []
	for item_id: Variant in _items.keys():
		if int(_items[item_id]) > 0:
			ids.append(StringName(item_id))
	ids.sort_custom(func(a: StringName, b: StringName) -> bool: return String(a) < String(b))
	return ids


func serialize() -> Dictionary:
	var items := {}
	var keys := _items.keys()
	keys.sort()
	for item_id: Variant in keys:
		items[String(item_id)] = int(_items[item_id])
	return {
		"items": items,
		"money": _money,
	}


func deserialize(data: Variant) -> void:
	if not data is Dictionary:
		reset_state()
		return
	_items.clear()
	var items: Variant = data.get("items", {})
	if items is Dictionary:
		for item_id: Variant in items:
			var amount := int(items[item_id])
			if StringName(item_id).is_empty() or amount <= 0:
				continue
			_items[StringName(item_id)] = amount
	_money = maxi(int(data.get("money", 0)), 0)
	inventory_changed.emit(&"", 0)
	money_changed.emit(_money)


func reset_state() -> void:
	_items.clear()
	for item_id: Variant in STARTING_ITEMS:
		_items[StringName(item_id)] = int(STARTING_ITEMS[item_id])
	_money = 0
	inventory_changed.emit(&"", 0)
	money_changed.emit(_money)


func _load_catalog() -> void:
	_catalog.clear()
	var directory := DirAccess.open(CATALOG_DIR)
	if directory == null:
		return
	directory.list_dir_begin()
	var file_name := directory.get_next()
	while not file_name.is_empty():
		if not directory.current_is_dir() and file_name.ends_with(".tres"):
			var item := load(CATALOG_DIR.path_join(file_name)) as ItemData
			if item != null and item.is_valid_item():
				_catalog[item.item_id] = item
		file_name = directory.get_next()
	directory.list_dir_end()
