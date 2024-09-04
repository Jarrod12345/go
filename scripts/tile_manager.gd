class_name TileManager

const ADJACENT_CELLS: Array[Vector2i] = [
    Vector2i.LEFT, Vector2i.UP, Vector2i.RIGHT, Vector2i.DOWN
]

var board_size: int
var tiles: Array[Array] # Array[Array[Tile]]
var black_move: bool = true
var paused: bool = false # set externally

var num_stones: int = 0
# states are indexed by the number of stones on the board for faster access
var states: Array[Array] = [] # Array[Array[State]]
var current_state: State

var territory_manager: TerritoryManager
var timeline: Array[SGFNode] = []


func _init(_board_size: int, _tiles: Array[Array]) -> void:
    board_size = _board_size
    tiles = _tiles
    territory_manager = TerritoryManager.new(self)
    init_tiles()

## Set neighbours for all tiles.
## Also sets manager reference to self.
func init_tiles() -> void:
    for y: int in range(board_size):
        for x: int in range(board_size):
            var adj: Array[Tile] = []
            for delta: Vector2i in ADJACENT_CELLS:
                var dx: int = x + delta.x
                var dy: int = y + delta.y
                if dx >= 0 and dx < board_size and dy >= 0 and dy < board_size:
                    adj.append(tiles[dx][dy])
            tiles[x][y].adj_tiles = adj
            tiles[x][y].manager = self
    current_state = State.new(board_size, tiles)

## Checks if the current tile is a valid stone placement.
## Placements that would result in self-capture are illegal
## unless it captures enemy stones.
func can_place(tile: Tile) -> bool:
    return not paused and tile.adj_tiles.any(func(t: Tile) -> bool:
        return not t.is_placed() or \
            (t.tile_state == current_colour() and t.chain.liberties.size() > 1) or \
            (t.tile_state != current_colour() and t.chain.liberties.size() == 1)
    ) and check_next_state(tile)
    # TODO: add option to allow self-capture


## Get the corresponding stone colour (tile state) for the current move
func current_colour() -> Tile.TileState:
    return Tile.TileState.BLACK if black_move else Tile.TileState.WHITE


## Rule 8. Check that the next board state does not match any previous states.
func check_next_state(tile: Tile) -> bool:
    var temp_state: State = current_state.clone()
    temp_state.set_stone(tile.grid_pos, current_colour())
    var temp_num_stones: int = num_stones + 1

    var unlib: Set = Set.new() # Set[Chain]
    for adj: Tile in tile.adj_tiles:
        if adj.is_placed() and adj.tile_state != current_colour():
            unlib.add(adj.chain)

    # remove adjacent enemy liberties
    for rm: Chain in unlib.values():
        for rm_pos: Vector2i in rm.remove_liberty(tile.grid_pos, true).values():
            temp_state.set_stone(rm_pos, Tile.TileState.EMPTY)
            temp_num_stones -= 1

    # positional superko
    return states.size() < temp_num_stones or states[temp_num_stones - 1].all(
        func(s: State) -> bool:
            return not temp_state.matches(s)
    )


## Place a stone on the tile.
func place_stone(tile: Tile) -> void:
    # add node to timeline
    timeline.append(
        SGFNode.new().add_prop(
            SGFProperty.new("B" if black_move else "W").add_value(
                String.chr(tile.grid_pos.x + 97) + String.chr(tile.grid_pos.y + 97)
            )
        )
    )

    var temp_state: State = current_state.clone()
    temp_state.set_stone(tile.grid_pos, current_colour())

    tile.tile_state = current_colour()
    black_move = not black_move
    num_stones += 1

    var chain: Chain = Chain.new(tile.grid_pos)
    var unlib: Set = Set.new() # Set[Chain]
    for adj: Tile in tile.adj_tiles:
        if not adj.is_placed():
            chain.add_liberty(adj.grid_pos)
        elif adj.tile_state == tile.tile_state:
            chain.combine(adj.chain)
        else:
            unlib.add(adj.chain)

    # update all tiles in chain
    for pos: Vector2i in chain.tiles.values():
        tiles[pos.x][pos.y].chain = chain

    # remove adjacent enemy liberties
    for rm: Chain in unlib.values():
        for rm_pos: Vector2i in rm.remove_liberty(tile.grid_pos, false).values():
            temp_state.set_stone(rm_pos, Tile.TileState.EMPTY)
            tiles[rm_pos.x][rm_pos.y].remove_stone()
            num_stones -= 1

    # add new board state to states
    while states.size() < num_stones:
        states.append([])
    states[num_stones - 1].append(temp_state)
    current_state = temp_state

    territory_manager.calculate_scores()


func pass_turn() -> void:
    # add node to timeline, empty string denotes a pass
    timeline.append(
        SGFNode.new().add_prop(
            SGFProperty.new("B" if black_move else "W").add_value("")
        )
    )

    black_move = not black_move
