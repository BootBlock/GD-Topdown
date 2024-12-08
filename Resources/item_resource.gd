# item_resource.gd
class_name ItemResource extends Resource

## The name of the item.
@export var item_name: String

## A short description of the item.
@export var item_description: String

## The image that represents the item within the world (e.g. on the ground and ready to be picked up) or displayed in the HUD.
@export var world_image: Texture2D

## The sound effect to play when the item is picked up.
@export var pickup_sound: AudioStream

## Determines the stance the item places the player into.
@export var stance: Player.stances = Player.stances.none

# The checks below would be better with a unit testing framework, but
# we're not adding that right now and so this will have to do instead.
## Perform some basic checks to ensure that the item is valid.
func throw_if_invalid():
	assert(self.item_name, "The item needs a name.")
	assert(self.item_description, "The item needs a description.")
	assert(self.world_image, "The item needs an image that represents it within the world/HUD.")
