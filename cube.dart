import 'dart:math';
import 'dart:io';

const int height = 30;
const int width = 75;
const int area = width * height;
const int sleepTime = 35;
const int distanceFromCamera = 50;
const double cubeWidth = 7.0;
const double incrementSpeed = 0.5;
const double k1 = 40.0;
const String backgroundCharacter = ' ';

var buffer = List<String>.filled(area, ' ', growable: false);
var zBuffer = List<double>.filled(area, 0.0, growable: false);

class Cube {
  double a, b, c;
  Cube(this.a, this.b, this.c);
}

extension CubeModifier on Cube {
  void increaseCubeAngle() {
    a += 0.05;
    b += 0.05;
    c += 0.01;
  }
}

void main() {
  var cube = Cube(0.0, 0.0, 0.0);

  stdout.write("\x1b[2J");
  while (true) {
    buffer.fillRange(0, buffer.length, ' ');
    zBuffer.fillRange(0, zBuffer.length, 0.0);

    for (var cubeX = -cubeWidth; cubeX < cubeWidth; cubeX += incrementSpeed) {
      for (var cubeY = -cubeWidth; cubeY < cubeWidth; cubeY += incrementSpeed) {
        calculateForSurface(cube, cubeX, cubeY, -cubeWidth, '@');
        calculateForSurface(cube, cubeWidth, cubeY, cubeX, '\$');
        calculateForSurface(cube, -cubeWidth, cubeY, -cubeX, '~');
        calculateForSurface(cube, -cubeX, cubeY, cubeWidth, '#');
        calculateForSurface(cube, cubeX, -cubeWidth, -cubeY, ';');
        calculateForSurface(cube, cubeX, cubeWidth, cubeY, '+');
      }
    }

    stdout.write("\x1b[H");
    for (int k = 0; k < area; k += 1) {
      if (k % width != 0) {
        stdout.write(buffer[k]);
      } else {
        stdout.write("\n");
      }
    }

    cube.increaseCubeAngle();
    sleep(const Duration(milliseconds: sleepTime));
  }
}

double calculateX(Cube cube, double i, j, k) {
  return j * sin(cube.a) * sin(cube.b) * cos(cube.c) -
      k * cos(cube.a) * sin(cube.b) * cos(cube.c) +
      j * cos(cube.a) * sin(cube.c) +
      k * sin(cube.a) * sin(cube.c) +
      i * cos(cube.b) * cos(cube.c);
}

double calculateY(Cube cube, double i, j, k) {
  return j * cos(cube.a) * cos(cube.c) +
      k * sin(cube.a) * cos(cube.c) -
      j * sin(cube.a) * sin(cube.b) * sin(cube.c) +
      k * cos(cube.a) * sin(cube.b) * sin(cube.c) -
      i * cos(cube.b) * sin(cube.c);
}

double calculateZ(Cube cube, double i, j, k) {
  return k * cos(cube.a) * cos(cube.b) -
      j * sin(cube.a) * cos(cube.b) +
      i * sin(cube.b);
}

void calculateForSurface(Cube cube, double cubeX, cubeY, cubeZ, String ch) {
  var x = calculateX(cube, cubeX, cubeY, cubeZ);
  var y = calculateY(cube, cubeX, cubeY, cubeZ);
  var z = calculateZ(cube, cubeX, cubeY, cubeZ) + distanceFromCamera;

  var ooz = 1.0 / z;

  int xp = width ~/ 2 + (k1 * ooz * x * 2.0).toInt();
  int yp = height ~/ 2 + (k1 * ooz * y).toInt();

  int idxBuffer = xp + yp * width;

  if (idxBuffer >= 0 && idxBuffer < area) {
    if (ooz > zBuffer[idxBuffer]) {
      zBuffer[idxBuffer] = ooz;
      buffer[idxBuffer] = ch;
    }
  }
}
