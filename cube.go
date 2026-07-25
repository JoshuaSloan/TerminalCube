package main

import (
	"fmt"
	"math"
	"time"
)

const width int = 75
const height int = 30
const area int = width * height
const sleepTime int = 10
const cameraDistance float64 = 50
const cubeWidth float64 = 7
const incrementSpeed float64 = 0.5
const k1 float64 = 40
const backgroundSymbol rune = ' '

var buffer [area]rune
var zBuffer [area]float64

type Cube struct {
	a float64
	b float64
	c float64
}

func main() {
	cube := Cube{a: 0.0, b: 0.0, c: 0.0}
	fmt.Print("\x1b[2J")

	for {
		for i := range buffer {
			buffer[i] = backgroundSymbol
		}

		for i := range zBuffer {
			zBuffer[i] = 0.0
		}

		for cubeX := -cubeWidth; cubeX < cubeWidth; cubeX += incrementSpeed {
			for cubeY := -cubeWidth; cubeY < cubeWidth; cubeY += incrementSpeed {
				CalculateForSurface(&cube, cubeX, cubeY, -cubeWidth, '@')
				CalculateForSurface(&cube, cubeWidth, cubeY, cubeX, '$')
				CalculateForSurface(&cube, -cubeWidth, cubeY, -cubeX, '~')
				CalculateForSurface(&cube, -cubeX, cubeY, cubeWidth, '#')
				CalculateForSurface(&cube, cubeX, -cubeWidth, -cubeY, ';')
				CalculateForSurface(&cube, cubeX, cubeWidth, cubeY, '+')
			}
		}

		fmt.Print("\x1b[H")
		for k := 0; k < area; k += 1 {
			if k%width != 0 {
				fmt.Printf("%c", buffer[k])
			} else {
				fmt.Print("\n")
			}
		}

		IncreaseCubeAngle(&cube)
		time.Sleep(time.Millisecond * time.Duration(sleepTime))
	}
}

func CalculateX(cube *Cube, i float64, j float64, k float64) float64 {
	return j*math.Sin(cube.a)*math.Sin(cube.b)*math.Cos(cube.c) -
		k*math.Cos(cube.a)*math.Sin(cube.b)*math.Cos(cube.c) +
		j*math.Cos(cube.a)*math.Sin(cube.c) +
		k*math.Sin(cube.a)*math.Sin(cube.c) +
		i*math.Cos(cube.b)*math.Cos(cube.c)
}

func CalculateY(cube *Cube, i float64, j float64, k float64) float64 {
	return j*math.Cos(cube.a)*math.Cos(cube.c) +
		k*math.Sin(cube.a)*math.Cos(cube.c) -
		j*math.Sin(cube.a)*math.Sin(cube.b)*math.Sin(cube.c) +
		k*math.Cos(cube.a)*math.Sin(cube.b)*math.Sin(cube.c) -
		i*math.Cos(cube.b)*math.Sin(cube.c)
}

func CalculateZ(cube *Cube, i float64, j float64, k float64) float64 {
	return k*math.Cos(cube.a)*math.Cos(cube.b) -
		j*math.Sin(cube.a)*math.Cos(cube.b) +
		i*math.Sin(cube.b)
}

func CalculateForSurface(cube *Cube, cubeX float64, cubeY float64, cubeZ float64, ch rune) {
	x := CalculateX(cube, cubeX, cubeY, cubeZ)
	y := CalculateY(cube, cubeX, cubeY, cubeZ)
	z := CalculateZ(cube, cubeX, cubeY, cubeZ) + cameraDistance

	ooz := 1.0 / z

	xp := width/2 + int(k1*ooz*x*2)
	yp := height/2 + int(k1*ooz*y)
	bufferIndex := xp + yp*width

	if bufferIndex >= 0 && bufferIndex < area {
		if ooz > zBuffer[bufferIndex] {
			zBuffer[bufferIndex] = ooz
			buffer[bufferIndex] = ch
		}
	}
}

func IncreaseCubeAngle(cube *Cube) {
	cube.a += 0.05
	cube.b += 0.05
	cube.c += 0.01
}
