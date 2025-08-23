package main

import "core:fmt"
import "core:math"
import "core:time"

// Constants
WIDTH :: 75
HEIGHT :: 30
AREA :: WIDTH * HEIGHT
SLEEP_TIME :: 1000
DISTANCE_FROM_CAM :: 50
CUBE_WIDTH :: 7.0
INCREMENT_SPEED :: 0.5
K1 :: 40.0
BACKGROUND_ASCII_CODE :rune: ' '

// Globals
buffer : [AREA]rune
z_buffer : [AREA]f64

// Structs
Cube :: struct {
    a, b, c: f64,
}

main :: proc() {
  cube := Cube{0,0,0}
  fmt.printf("\x1b[2J")

  for {
    for &ch in buffer {
      ch = BACKGROUND_ASCII_CODE
    }

    for &d in z_buffer {
      d = 0.0
    }

    for cube_x := -CUBE_WIDTH; cube_x < CUBE_WIDTH; cube_x += INCREMENT_SPEED {
      for cube_y := -CUBE_WIDTH; cube_y < CUBE_WIDTH; cube_y += INCREMENT_SPEED {
        calculateForSurface(&cube, cube_x, cube_y, -CUBE_WIDTH, '@');
        calculateForSurface(&cube, CUBE_WIDTH, cube_y, cube_x, '$');
        calculateForSurface(&cube, -CUBE_WIDTH, cube_y, -cube_x, '~');
        calculateForSurface(&cube, -cube_x, cube_y, CUBE_WIDTH, '#');
        calculateForSurface(&cube, cube_x, -CUBE_WIDTH, -cube_y, ';');
        calculateForSurface(&cube, cube_x, CUBE_WIDTH, cube_y, '+');
      }
    }

    fmt.printf("\x1b[H")
    for k: int = 0; k < AREA; k += 1 {
      if k % WIDTH != 0 {
        fmt.printf("%v", buffer[k])
      }
      else {
        fmt.printf("\n")
      }
    }
    
    increaseCubeAngle(&cube)
    time.sleep(SLEEP_TIME)
  }
}

calculateX :: proc(cube: ^Cube, i: f64, j: f64, k: f64) -> f64 {
  return j * math.sin(cube.a) * math.sin(cube.b) * math.cos(cube.c) - \
         k * math.cos(cube.a) * math.sin(cube.b) * math.cos(cube.c) + \
         j * math.cos(cube.a) * math.sin(cube.c) + k * math.sin(cube.a) * math.sin(cube.c) + \
         i * math.cos(cube.b) * math.cos(cube.c)
}

calculateY :: proc(cube: ^Cube, i: f64, j: f64, k: f64) -> f64 {
  return j * math.cos(cube.a) * math.cos(cube.c) + k * math.sin(cube.a) * math.cos(cube.c) - \
         j * math.sin(cube.a) * math.sin(cube.b) * math.sin(cube.c) + k * math.cos(cube.a) * math.sin(cube.b) * math.sin(cube.c) - \
         i * math.cos(cube.b) * math.sin(cube.c)
}

calculateZ :: proc(cube: ^Cube, i: f64, j: f64, k: f64) -> f64 {
  return k * math.cos(cube.a) * math.cos(cube.b) - j * math.sin(cube.a) * math.cos(cube.b) + i * math.sin(cube.b)
}

calculateForSurface :: proc(cube: ^Cube, cube_x: f64, cube_y: f64, cube_z: f64, ch: rune) {
    x := calculateX(cube, cube_x, cube_y, cube_z)
    y := calculateY(cube, cube_x, cube_y, cube_z)
    z := calculateZ(cube, cube_x, cube_y, cube_z) + DISTANCE_FROM_CAM

    ooz := 1.0/z

    xp: int = WIDTH / 2 + int(K1 * ooz * x * 2.0)
    yp: int = HEIGHT / 2 + int(K1 * ooz * y)

    idx_buffer := xp + yp * WIDTH

    if idx_buffer >= 0 && idx_buffer < AREA {
      if ooz > z_buffer[idx_buffer] {
        z_buffer[idx_buffer] = ooz
        buffer[idx_buffer] = ch
      }
    }
}

increaseCubeAngle :: proc(cube: ^Cube) {
        cube.a += 0.05
        cube.b += 0.05
        cube.c += 0.01
}