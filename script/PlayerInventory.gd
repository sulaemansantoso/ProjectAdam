extends Node

signal active_item_updated
signal weaponChanged(item)

const SlotClass = preload("res://script/Slot.gd")
const ItemClass = preload("res://script/Item.gd")
const NUM_INVENTORY_SLOTS = 40
const NUM_HOTBAR_SLOTS = 8

var active_item_slot = 0

var inventory = {
	0: ["Tree Branch", 1],  #--> slot_index: [item_name, item_quantity]
	1: ["Slime Potion", 98],
	2: ["Slime Potion", 45],
}

#var hotbar = {
#	0: ["Iron Sword", 1],  #--> slot_index: [item_name, item_quantity]
#	3: ["Slime Potion", 45],
#}

var equips = {
	0: ["Iron Sword", 1],  #--> slot_index: [item_name, item_quantity]
	1: ["Blue Jeans", 1],  #--> slot_index: [item_name, item_quantity]
	2: ["Brown Boots", 1],	
}

# TODO: First try to add to hotbar
func add_item(item_name, item_quantity):
	var slot_indices: Array = inventory.keys()
	slot_indices.sort()
	for item in slot_indices:
		if inventory[item][0] == item_name:
			var stack_size = int(JsonData.item_data[item_name]["StackSize"])
			var able_to_add = stack_size - inventory[item][1]
			if able_to_add >= item_quantity:
				inventory[item][1] += item_quantity
				update_slot_visual(item, inventory[item][0],inventory[item][1])
				return
			else:
				inventory[item][1] += able_to_add
				update_slot_visual(item, inventory[item][0],inventory[item][1])
				item_quantity = item_quantity - able_to_add
	
	# item doesn't exist in inventory yet, so add it to an empty slot
	for i in range(NUM_INVENTORY_SLOTS):
		if inventory.has(i) == false:
			inventory[i] = [item_name, item_quantity]
			update_slot_visual(i, inventory[i][0],inventory[i][1])
			return

# TODO: Make compatible with hotbar as well
func update_slot_visual(slot_index, itemName, itemQuantity):
	var slot = get_tree().root.get_node("/root/World/UserInterface/Inventory/GridContainer/Slot" + str(slot_index + 1))
	if slot.item != null:
		slot.item.set_item(itemName, itemQuantity)
	else:
		slot.initialize_item(itemName, itemQuantity)

func remove_item(slot: SlotClass):
	match slot.slotType:
#		SlotClass.SlotType.HOTBAR:
#			hotbar.erase(slot.slot_index)
		SlotClass.SlotType.INVENTORY:
			inventory.erase(slot.slot_index)
		_:
			equips.erase(slot.slot_index)

func add_item_to_empty_slot(item: ItemClass, slot: SlotClass):
#	print(slot.slotType == SlotClass.SlotType.INVENTORY)
	match slot.slotType:
#		SlotClass.SlotType.HOTBAR:
#			hotbar[slot.slot_index] = [item.item_name, item.item_quantity]
		SlotClass.SlotType.INVENTORY:
			inventory[slot.slot_index] = [item.item_name, item.item_quantity]
		_:
			equips[slot.slot_index] = [item.item_name, item.item_quantity]
			if(slot.slot_index == 0 and slot.slotType == 2):
				emit_signal("weaponChanged", item)

func add_item_quantity(slot: SlotClass, quantity_to_add: int):
	match slot.slotType:
#		SlotClass.SlotType.HOTBAR:
#			hotbar[slot.slot_index][1] += quantity_to_add
		SlotClass.SlotType.INVENTORY:
			inventory[slot.slot_index][1] += quantity_to_add
		_:
			pass
#			equips[slot.slot_index][1] += quantity_to_add

###
### Hotbar Related Functions
func active_item_scroll_up() -> void:
	active_item_slot = (active_item_slot + 1) % NUM_HOTBAR_SLOTS
	emit_signal("active_item_updated")

func active_item_scroll_down() -> void:
	if active_item_slot == 0:
		active_item_slot = NUM_HOTBAR_SLOTS - 1
	else:
		active_item_slot -= 1
	emit_signal("active_item_updated")





