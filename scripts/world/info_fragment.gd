class_name InfoFragment
extends Resource

## A piece of information discovered by Future-Lena.

@export var id: String
@export var type: String
@export var content: String
@export var source_location: String


## Create a new InfoFragment.
static func create(frag_id: String, frag_type: String, frag_content: String, source: String = "") -> InfoFragment:
	var frag := InfoFragment.new()
	frag.id = frag_id
	frag.type = frag_type
	frag.content = frag_content
	frag.source_location = source
	return frag
