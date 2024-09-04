class_name State

var board_size: int
var stones: Array[Array] = [] # Array[Array[Tile.TileState]]

func _init(_board_size: int, _tiles: Array[Array]) -> void:
    # _tiles: Array[Array[Tile]]
    board_size = _board_size
    for arr: Array in _tiles:
        stones.append([])
        for tile: Tile in arr:
            stones[-1].append(tile.tile_state)

## Set a specific tile's stone to `new_stone`.
func set_stone(pos: Vector2i, new_stone: Tile.TileState) -> void:
    stones[pos.x][pos.y] = new_stone

## Returns `true` if the other state matches this
## state exactly, otherwise `false`.
## All tiles must have the same stones in the same positions.
func matches(other: State) -> bool:
    if other == self:
        return true
    for y: int in range(board_size):
        for x: int in range(board_size):
            if stones[x][y] != other.stones[x][y]:
                return false
    return true

## Clones the state, returning a deep copy.
func clone() -> State:
    var state: State = State.new(board_size, [])
    state.stones = stones.duplicate(true)
    return state

func _to_string() -> String:
    var lines: Array = []
    for y: int in range(board_size):
        var line: Array = []
        for x: int in range(board_size):
            line.append(stones[x][y])
        lines.append(" ".join(line))
    return "\n".join(lines)
