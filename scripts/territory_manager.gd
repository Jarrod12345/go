class_name TerritoryManager

enum Territory { UNASSIGNED, NEUTRAL, BLACK, WHITE }

signal update_score(black: int, white: int) # connected externally (via Game)

var tm: TileManager

func _init(tile_manager: TileManager) -> void:
    tm = tile_manager

# calculate territories and scores for both players
func calculate_scores() -> void:
    var black: int = 0
    var white: int = 0

    var chains: Set = Set.new() # Set[Chain]
    var territories: Array[Array] = [] # Array[Array[Territory]]
    for arr: Array in tm.tiles:
        territories.append([])
        for tile: Tile in arr:
            if tile.is_placed():
                chains.add(tile.chain)
                if tile.tile_state == Tile.TileState.BLACK:
                    territories[-1].append(Territory.BLACK)
                else:
                    territories[-1].append(Territory.WHITE)
            else:
                territories[-1].append(Territory.UNASSIGNED)

    if tm.num_stones > 1:
        for chain: Chain in chains.values():
            for liberty: Vector2i in chain.liberties.values():
                var temp: Vector2i = chain.tiles.values()[0]
                var is_black: bool = tm.tiles[temp.x][temp.y].tile_state == Tile.TileState.BLACK
                claim_territory(liberty.x, liberty.y, is_black, territories)

    for y: int in range(tm.board_size):
        for x: int in range(tm.board_size):
            if territories[x][y] == Territory.BLACK:
                black += 1
            elif territories[x][y] == Territory.WHITE:
                white += 1

    update_score.emit(black, white)

# update territory of tile at specified coordinate
func claim_territory(x: int, y: int, is_black: bool, territories: Array[Array]) -> void:
    var current: Territory = territories[x][y]
    if current == Territory.UNASSIGNED:
        territories[x][y] = Territory.BLACK if is_black else Territory.WHITE
    elif current == (Territory.WHITE if is_black else Territory.BLACK):
        territories[x][y] = Territory.NEUTRAL

    # recursively 
    for delta: Vector2i in tm.ADJACENT_CELLS:
        var dx: int = x + delta.x
        var dy: int = y + delta.y
        if dx >= 0 and dx < tm.board_size and dy >= 0 and dy < tm.board_size and \
            not tm.tiles[dx][dy].is_placed() and \
            territories[dx][dy] != Territory.NEUTRAL and \
            territories[dx][dy] != territories[x][y]:
            claim_territory(dx, dy, is_black, territories)
