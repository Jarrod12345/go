class_name Set

## Arbitrary value.
const X: Variant = 1

## Internal Dictionary to store unique items/values as keys.
var _inner: Dictionary = {}

## Create a set from an existing array of items.
static func from(arr: Array) -> Set:
    var new_set: Set = Set.new()
    for item: Variant in arr:
        new_set.add(item)
    return new_set

## Add an item to the set.
func add(item: Variant) -> void:
    _inner[item] = X

## Concat/merge another set with this set.
func concat(other: Set) -> void:
    _inner.merge(other._inner)

## Remove an item from the set.
## Returns `true` if the set was modified, otherwise `false`.
func remove(item: Variant) -> bool:
    return _inner.erase(item)

## Returns `true` if the set contains the specified item, otherwise `false`.
func contains(item: Variant) -> bool:
    return _inner.has(item) 

## Returns the number of items in the set.
func size() -> int:
    return _inner.size()

## Returns `true` if the set does not contain any items, otherwise `false`.
func is_empty() -> bool:
    return _inner.is_empty()

## Returns the set of items as an array.
func values() -> Array:
    return _inner.keys()

func _to_string() -> String:
    return str(values())
