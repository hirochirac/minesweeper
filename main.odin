package main

import "core:fmt"
import "core:math"
import "core:math/rand"
import ry "vendor:raylib"

SCREEN_WIDTH :: 400
SCREEN_HEIGHT :: 400
COLS :: 10
ROWS :: 10
CELL_WIDTH :: SCREEN_WIDTH / ROWS
CELL_HEIGHT :: SCREEN_HEIGHT / COLS
FLAG_IMG :: "assets/flag.png"
DIG_1_SND :: "assets/dig1.wav"
DIG_2_SND :: "assets/dig2.wav"
EXPLOSION_SND :: "assets/explosion.wav"
WIN_SND :: "assets/win.wav"

Cell :: struct {
	col:      int,
	row:      int,
	mine:     bool,
	revealed: bool,
	flagged:  bool,
	nearby:   int,
}

grid: [COLS][ROWS]Cell

flag_tex: ry.Texture2D


main :: proc() {

	ry.InitAudioDevice()
	ry.InitWindow(SCREEN_WIDTH, SCREEN_HEIGHT, "Mine Sweeper")

	flag_tex = ry.LoadTexture(FLAG_IMG)
	init_grid()
	mine_setting()
	mines_counter()


	for (!ry.WindowShouldClose()) {

		ry.ClearBackground(ry.RAYWHITE)

		mouse_handler()

		ry.BeginDrawing()
		draw_grid()
		ry.EndDrawing()
	}


	ry.CloseAudioDevice()
	ry.CloseWindow()
}

mine_setting :: proc() {

	r: rand.Rand = rand.create(10)
	indexC: int = 0
	indexR: int = 0


	mine_number: int = int(COLS * ROWS * 0.1)

	for mine_number > 0 {
		indexC = rand.int_max(10, &r)
		indexR = rand.int_max(10, &r)

		if (!grid[indexC][indexR].mine) {
			grid[indexC][indexR].mine = true
			mine_number -= 1
		}

	}

}


is_index_valid :: proc(c: int, r: int) -> bool {
	return c >= 0 && c < COLS && r >= 0 && r < ROWS
}

cell_mine_count :: proc(c: int, r: int) -> int {

	count: int = 0
	for cOff := -1; cOff <= 1; cOff += 1 {
		for rOff := -1; rOff <= 1; rOff += 1 {
			if (cOff == 0 && rOff == 0) {
				continue
			}
			if (!is_index_valid(c + cOff, r + rOff)) {
				continue
			}
			if (grid[c + cOff][r + rOff].mine == true) {
				count += 1
			}
		}
	}

	return count
}

mines_counter :: proc() {

	for c in 0 ..< len(grid) {
		for r in 0 ..< len(grid[c]) {
			if (!grid[c][r].mine) {
				grid[c][r].nearby = cell_mine_count(c, r)
			}
		}
	}
}

cell_revealed :: proc(c: i32, r: i32) {

	if (grid[c][r].flagged == true) {
		grid[c][r].revealed = false
		return
	}

	if (grid[c][r].mine) {
		// lose
	}
}

mouse_handler :: proc() {

	if (ry.IsMouseButtonPressed(ry.MouseButton.LEFT)) {
		row := ry.GetMouseX() / CELL_WIDTH
		col := ry.GetMouseY() / CELL_HEIGHT
		grid[col][row].revealed = true
		cell_revealed(col, row)
	} else if (ry.IsMouseButtonPressed(ry.MouseButton.RIGHT)) {
		row := ry.GetMouseX() / CELL_WIDTH
		col := ry.GetMouseY() / CELL_HEIGHT
		grid[col][row].flagged = !grid[col][row].flagged
		cell_revealed(col, row)
	}


}

init_grid :: proc() {
	for c in 0 ..< len(grid) {
		for r in 0 ..< len(grid[c]) {
			grid[c][r] = Cell {
				col      = c,
				row      = r,
				revealed = false,
				mine     = false,
				flagged  = false,
				nearby   = -1,
			}
		}
	}
}

draw_grid :: proc() {
	couleur: ry.Color = {}
	for c in 0 ..< len(grid) {
		for r in 0 ..< len(grid[c]) {
			if (grid[r][c].revealed && !grid[r][c].flagged) {
				if (grid[r][c].mine) {
					ry.DrawRectangle(
						i32(c * CELL_HEIGHT),
						i32(r * CELL_WIDTH),
						CELL_WIDTH,
						CELL_HEIGHT,
						ry.RED,
					)
				} else {
					ry.DrawRectangle(
						i32(c * CELL_HEIGHT),
						i32(r * CELL_WIDTH),
						CELL_WIDTH,
						CELL_HEIGHT,
						ry.LIGHTGRAY,
					)
					if (grid[r][c].nearby > 0) {
						ry.DrawText(
							ry.TextFormat("%d", grid[r][c].nearby),
							i32((c * CELL_HEIGHT) + (CELL_HEIGHT / 2)),
							i32((r * CELL_WIDTH) + (CELL_WIDTH / 2)),
							20,
							ry.DARKBROWN,
						)
					}
				}
			} else if (grid[r][c].flagged) {
				ry.DrawTexturePro(
					flag_tex,
					ry.Rectangle{0.0, 0.0, f32(flag_tex.width), f32(flag_tex.height)},
					ry.Rectangle{
						(f32(c * CELL_HEIGHT)),
						(f32(r * CELL_WIDTH)),
						f32(flag_tex.width),
						f32(flag_tex.height),
					},
					ry.Vector2{0.0, 0.0},
					0,
					ry.Color{255, 255, 255, 255},
				)
			} else {
				ry.DrawRectangleLines(
					i32(c * CELL_HEIGHT),
					i32(r * CELL_WIDTH),
					CELL_WIDTH,
					CELL_HEIGHT,
					ry.BLACK,
				)
			}
		}
	}
}
