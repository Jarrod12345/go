class_name Chain

var tiles: Set = Set.new() # Set[Vector2i]
var liberties: Set = Set.new() # Set[Vector2i]

func _init(pos: Vector2i) -> void:
    tiles.add(pos)

## Combine another chain with this chain.
func combine(other: Chain) -> Chain:
    if other != self:
        tiles.concat(other.tiles)
        liberties.concat(other.liberties)
        for tile: Vector2i in tiles.values():
            liberties.remove(tile)
    return self

## Add a liberty at the specified position.
func add_liberty(pos: Vector2i) -> void:
    liberties.add(pos)

## Remove a liberty at the specified position.
## If all liberties are removed, return all tile
## positions in the chain. Otherwise returns an empty set.
func remove_liberty(pos: Vector2i, simulate: bool) -> Set:
    if simulate:
        if liberties.size() == 1 and liberties.contains(pos):
            return tiles
        return Set.new()

    liberties.remove(pos)
    if liberties.is_empty():
        print("capture chain at ", pos)
        return tiles
    return Set.new()
