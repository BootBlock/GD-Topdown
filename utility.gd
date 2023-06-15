# utility.gd

## A value that represents 90 degrees in Radians.
const NINETY_DEGREES_IN_RADIANS = 1.5707963267949

## Find the shortest path to the new angle.
static func shortestAngle(sprite: Sprite2D, direction: Vector2):
	return sprite.rotation + wrapf(direction.angle() - sprite.rotation, -PI, PI) + NINETY_DEGREES_IN_RADIANS

## Rotates around a central point.
static func rotate_around_point(central_point, angle, distance):
	return central_point + Vector2(sin(angle),cos(angle)) * distance

## Enumerates all sub-nodes of a specified node.
static func get_all_children(parent_node, arr := []):
	arr.push_back(parent_node)

	for child in parent_node.get_children():
		arr = get_all_children(child, arr)

	return arr

## Performs a queue_free() on all children contained within the specified node.
static func free_children(node):
	for n in node.get_children():
		n.queue_free()
