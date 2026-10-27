static I64 width = 75;
static I64 height = 30;
static I64 area = width * height;
static U64 sleepTime = 50000;
static F64 cameraDistance = 50.0;
static F64 cubeWidth = 7.0;
static F64 incrementSpeed = 0.5;
static F64 k1 = 40.0;
static U8 backgroundChar = ' ';

extern "c" U32 usleep(U32 usec);
U8 *buffer = MAlloc(sizeof(U8) * area);
F64 *zBuffer = MAlloc(sizeof(F64) * area);

class Cube
{
    F64 a;
    F64 b;
    F64 c;
};

F64 CalculateX(Cube *cube, F64 i, F64 j, F64 k)
{
  return j * sin(cube->a) * sin(cube->b) * cos(cube->c) -
         k * cos(cube->a) * sin(cube->b) * cos(cube->c) +
         j * cos(cube->a) * sin(cube->c) +
         k * sin(cube->a) * sin(cube->c) +
         i * cos(cube->b) * cos(cube->c);
}

F64 CalculateY(Cube *cube, F64 i, F64 j, F64 k)
{
  return j * cos(cube->a) * cos(cube->c) +
         k * sin(cube->a) * cos(cube->c) -
         j * sin(cube->a) * sin(cube->b) * sin(cube->c) +
         k * cos(cube->a) * sin(cube->b) * sin(cube->c) -
         i * cos(cube->b) * sin(cube->c);
}

F64 CalculateZ(Cube *cube, F64 i, F64 j, F64 k)
{
   return k * cos(cube->a) * cos(cube->b) -
          j * sin(cube->a) * cos(cube->b) +
          i * sin(cube->b);
}

U0 CalculateForSurface(Cube *cube, F64 cubeX, F64 cubeY, F64 cubeZ, U8 ch)
{
    F64 x = CalculateX(cube, cubeX, cubeY, cubeZ);
    F64 y = CalculateY(cube, cubeX, cubeY, cubeZ);
    F64 z = CalculateZ(cube, cubeX, cubeY, cubeZ) + cameraDistance;

    F64 ooz = 1.0/z;

    I64 xp = width / 2 + (k1 * ooz * x * 2)(I64);
    I64 yp = height / 2 + (k1 * ooz * y)(I64);

    I64 idx = xp + yp * width;
    if (idx >= 0 && idx < area)
    {
        if(ooz > zBuffer[idx])
        {
            zBuffer[idx] = ooz;
            buffer[idx] = ch;
        }
    }
}

U0 IncreaseCubeAngle(Cube *cube)
{
    cube->a += 0.05;
    cube->b += 0.05;
    cube->c += 0.01;
}

I32 Main()
{
    Cube cube;
    cube.a = 0.0;
    cube.b = 0.0;
    cube.c = 0.0;

    printf("\x1b[2J");

    while (1)
    {
        for (I64 i = 0; i < area; ++i)
        {
            buffer[i] = backgroundChar;
            zBuffer[i] = 0.0;
        }

        for (F64 cubeX = -cubeWidth; cubeX < cubeWidth; cubeX += incrementSpeed)
        {
            for(F64 cubeY = -cubeWidth; cubeY < cubeWidth; cubeY += incrementSpeed)
            {
                CalculateForSurface(&cube, cubeX, cubeY, -cubeWidth, '@');
                CalculateForSurface(&cube, cubeWidth, cubeY, cubeX, '$');
                CalculateForSurface(&cube, -cubeWidth, cubeY, -cubeX, '~');
                CalculateForSurface(&cube, -cubeX, cubeY, cubeWidth, '#');
                CalculateForSurface(&cube, cubeX, -cubeWidth, -cubeY, ';');
                CalculateForSurface(&cube, cubeX, cubeWidth, cubeY, '+');
            }
        }

        printf("\x1b[H");
        for (I64 k = 0; k < area; ++k)
        {
            if(k % width != 0)
            {
                printf("%c", buffer[k]);
            }
            else
            {
                printf("\n");
            }
        }

        IncreaseCubeAngle(&cube);
        usleep(sleepTime);
    }

    Free(buffer);
    Free(zBuffer);
    return 1;
}