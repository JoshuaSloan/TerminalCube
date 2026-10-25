const width = 75
const height = 30
const area = width * height
const sleep_time = 0.05
const camera_distance = 50
const cube_width = 7.0
const increment_speed = 0.5
const k1 = 40.0
const background_ascii = ' '

buffer = fill(background_ascii, area)
z_buffer = fill(0.0, area)

mutable struct Cube
    a::Float64
    b::Float64
    c::Float64
end

function calculate_x(cube::Cube, i::Float64, j::Float64, k::Float64)
    return j * sin(cube.a) * sin(cube.b) * cos(cube.c) -
           k * cos(cube.a) * sin(cube.b) * cos(cube.c) +
           j * cos(cube.a) * sin(cube.c) +
           k * sin(cube.a) * sin(cube.c) +
           i * cos(cube.b) * cos(cube.c)
end

function calculate_y(cube::Cube, i::Float64, j::Float64, k::Float64)
    return j * cos(cube.a) * cos(cube.c) +
           k * sin(cube.a) * cos(cube.c) -
           j * sin(cube.a) * sin(cube.b) * sin(cube.c) +
           k * cos(cube.a) * sin(cube.b) * sin(cube.c) -
           i * cos(cube.b) * sin(cube.c)
end

function calculate_z(cube::Cube, i::Float64, j::Float64, k::Float64)
    return k * cos(cube.a) * cos(cube.b) -
           j * sin(cube.a) * cos(cube.b) +
           i * sin(cube.b)
end

function calculate_for_surface(cube::Cube, cube_x::Float64, cube_y::Float64, cube_z::Float64, ch::Char)
    x = calculate_x(cube, cube_x, cube_y, cube_z)
    y = calculate_y(cube, cube_x, cube_y, cube_z)
    z = calculate_z(cube, cube_x, cube_y, cube_z) + camera_distance

    ooz = 1.0 / z

    xp::Int = div(width, 2, RoundDown) + trunc(Int, k1 * ooz * x * 2.0)
    yp::Int = div(height, 2, RoundDown) + trunc(Int, k1 * ooz * y)

    buffer_index = xp + yp * width + 1

    if buffer_index >= 1 && buffer_index <= area
        if ooz > z_buffer[buffer_index]
            z_buffer[buffer_index] = ooz
            buffer[buffer_index] = ch
        end
    end
end

function increase_cube_angle(cube::Cube)
    cube.a += 0.05
    cube.b += 0.05
    cube.c += 0.01
end

function (@main)(args)
    cube = Cube(0.0, 0.0, 0.0)
    print("\x1b[2J")

    while true
        fill!(buffer, background_ascii)
        fill!(z_buffer, 0.0)

        for cube_x in -cube_width:increment_speed:cube_width-increment_speed
            for cube_y in -cube_width:increment_speed:cube_width-increment_speed
                calculate_for_surface(cube, cube_x, cube_y, -cube_width, '@')
                calculate_for_surface(cube, cube_width, cube_y, cube_x, '$')
                calculate_for_surface(cube, -cube_width, cube_y, -cube_x, '~')
                calculate_for_surface(cube, -cube_x, cube_y, cube_width, '#')
                calculate_for_surface(cube, cube_x, -cube_width, -cube_y, ';')
                calculate_for_surface(cube, cube_x, cube_width, cube_y, '+')
            end
        end

        print("\x1b[H")
        for k in 0:area-1
            if k % width != 0
                print(buffer[k+1])
            else
                print("\n")
            end
        end

        increase_cube_angle(cube)
        sleep(sleep_time)
    end
end