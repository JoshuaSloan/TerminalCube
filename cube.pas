{$mode objfpc}
program TerminalCube;
uses Math, SysUtils;

const
  width = 75;
  height = 30;
  area = width * height;
  sleep_time = 50;
  camera_distance = 50;
  cube_width = 7.0;
  increment_speed = 0.5;
  k1 = 40.0;
  background_ascii_code = ' ';

type
  Cube = record
    a: Double;
    b: Double;
    c: Double;
  end;

  PCube = ^Cube;

var
  buffer: Array[0..area-1] of Char;
  z_buffer: Array[0..area-1] of Double;
  my_cube: Cube;
  cube_x, cube_y: Double;
  i: Integer;

function CalculateX(const cube: PCube; const i, j, k: Double): Double;
begin
  result := j * Sin(cube^.a) * Sin(cube^.b) * Cos(cube^.c) -
            k * Cos(cube^.a) * Sin(cube^.b) * Cos(cube^.c) +
            j * Cos(cube^.a) * Sin(cube^.c) +
            k * Sin(cube^.a) * Sin(cube^.c) +
            i * Cos(cube^.b) * Cos(cube^.c);
end;

function CalculateY(const cube: PCube; const i, j, k: Double): Double;
begin
  result := j * Cos(cube^.a) * Cos(cube^.c) +
            k * Sin(cube^.a) * Cos(cube^.c) -
            j * Sin(cube^.a) * Sin(cube^.b) * Sin(cube^.c) +
            k * Cos(cube^.a) * Sin(cube^.b) * Sin(cube^.c) -
            i * Cos(cube^.b) * Sin(cube^.c);
end;

function CalculateZ(const cube: PCube; const i, j, k: Double): Double;
begin
  result := k * Cos(cube^.a) * Cos(cube^.b) -
            j * Sin(cube^.a) * Cos(cube^.b) +
            i * Sin(cube^.b)
end;

procedure CalculateForSurface(const cube: PCube; const cube_x, cube_y, cube_z: Double; const ch: Char);
var
  x, y, z, ooz: Double;
  xp, yp, idx: Integer;
begin
  x := CalculateX(cube, cube_x, cube_y, cube_z);
  y := CalculateY(cube, cube_x, cube_y, cube_z);
  z := CalculateZ(cube, cube_x, cube_y, cube_z) + camera_distance;

  ooz := 1.0 / z;

  xp := width div 2 + Trunc(k1 * ooz * x * 2.0);
  yp := height div 2 + Trunc(k1 * ooz * y);

  idx := xp + yp * width;

  if (idx >= 0) and (idx < area) then
    if ooz > z_buffer[idx] then
      begin
      z_buffer[idx] := ooz;
      buffer[idx] := ch;
      end;
end;

procedure IncreaseCubeAngle(cube: Pcube);
begin
  cube^.a := cube^.a + 0.05;
  cube^.b := cube^.b + 0.05;
  cube^.c := cube^.c + 0.01;
end;

begin
  my_cube.a := 0.0;
  my_cube.b := 0.0;
  my_cube.c := 0.0;
  Write(#27'[2J');

  while True do
  begin
    FillChar(buffer, SizeOf(buffer), background_ascii_code);
    FillChar(z_buffer, SizeOf(z_buffer), 0);

    cube_x := -cube_width;
    while cube_x < cube_width do
      begin
        cube_y := -cube_width;
        while cube_y < cube_width do
          begin
            calculateForSurface(@my_cube, cube_x, cube_y, -cube_width, '@');
            calculateForSurface(@my_cube, cube_width, cube_y, cube_x, '$');
            calculateForSurface(@my_cube, -cube_width, cube_y, -cube_x, '~');
            calculateForSurface(@my_cube, -cube_x, cube_y, cube_width, '#');
            calculateForSurface(@my_cube, cube_x, -cube_width, -cube_y, ';');
            calculateForSurface(@my_cube, cube_x, cube_width, cube_y, '+');

            cube_y := cube_y + increment_speed;
          end;
        cube_x := cube_x + increment_speed;
      end;

    Write(#27'[H');
    for i := 0 to area-1 do
    begin
      if i mod width <> 0 then
        Write(buffer[i])
      else
        WriteLn;
    end;

    IncreaseCubeAngle(@my_cube);
    Sleep(sleep_time);
  end;
end.