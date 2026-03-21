class_name AgingSimulation
extends RefCounted

## Calculates time-decay effects on objects over the 50-year gap.

## Age a FutureDelta by the given number of years.
static func age(delta: FutureDelta, years: int) -> FutureDelta:
	if delta.add_object_properties.has("container_type"):
		delta.add_object_properties = _age_container(
			delta.add_object_properties, years
		)

	if delta.add_object_properties.has("sapling_type"):
		delta.add_object_properties = _age_tree(
			delta.add_object_properties, years
		)

	if delta.add_object_properties.has("structure_type"):
		delta.add_object_properties = _age_structure(
			delta.add_object_properties, years
		)

	return delta


## Age a hidden container based on its type.
static func _age_container(props: Dictionary, years: int) -> Dictionary:
	var container_type: String = props.get("container_type", "cloth_wrap")
	match container_type:
		"glass_jar_with_silica":
			props["condition"] = "pristine"
		"metal_box":
			props["condition"] = "intact"
		"wooden_box":
			props["condition"] = "degraded"
		"cloth_wrap":
			props["condition"] = "destroyed"
	props["aged_years"] = years
	return props


## Age a tree based on years passed.
static func _age_tree(props: Dictionary, years: int) -> Dictionary:
	if years <= 10:
		props["growth_stage"] = "young"
		props["climbable"] = false
	elif years <= 25:
		props["growth_stage"] = "mature"
		props["climbable"] = true
	else:
		props["growth_stage"] = "old"
		props["climbable"] = true
		props["hollow"] = true

	var size: float = props.get("size_multiplier", 1.0)
	if size > 1.2:
		props["climbable"] = true

	props["aged_years"] = years
	return props


## Age a structure based on maintenance events.
static func _age_structure(props: Dictionary, years: int) -> Dictionary:
	var maintained: bool = props.get("maintained", false)
	if maintained:
		props["condition"] = "weathered"
		props["functional"] = true
	else:
		props["condition"] = "partially_collapsed"
		props["functional"] = false
	props["aged_years"] = years
	return props
