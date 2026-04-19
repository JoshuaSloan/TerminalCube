module cube_module
implicit none

integer, parameter :: width = 75, height = 30, area = width * height, sleep_time = 1000, camera_distance = 50
real, parameter :: cube_width = 7.0, increment_speed = 0.5, k1 = 40.0
character, parameter :: background = ' '
character, dimension(area) :: buffer
real, dimension(area) :: z_buffer

type cube
    real :: a
    real :: b
    real :: c
end type cube

contains
    real function calculate_x (c, i, j, k)
        type(cube), intent(inout) :: c
        real, intent(in) :: i, j, k

        calculate_x = j * sin(c%a) * sin(c%b) * cos(c%c) - &
                 k * cos(c%a) * sin(c%b) * cos(c%c) + &
                 j * cos(c%a) * sin(c%c) + k * sin(c%a) * sin(c%c) + &
                 i * cos(c%b) * cos(c%c)
    end function

    real function calculate_y (c, i, j, k)
        type(cube), intent(inout) :: c
        real, intent(in) :: i, j, k

        calculate_y = j * cos(c%a) * cos(c%c) + k * sin(c%a) * cos(c%c) - &
                 j * sin(c%a) * sin(c%b) * sin(c%c) + k * cos(c%a) * sin(c%b) * sin(c%c) - &
                 i * cos(c%b) * sin(c%c)
    end function

    real function calculate_z (c, i, j, k)
        type(cube), intent(inout) :: c
        real, intent(in) :: i, j, k

        calculate_z = k * cos(c%a) * cos(c%b) - j * sin(c%a) * cos(c%b) + i * sin(c%b)
    end function

    subroutine calculate_for_surface (c, c_x, c_y, c_z, ch)
        type(cube), intent(inout) :: c
        real, intent(in) :: c_x, c_y, c_z
        character, intent(in) :: ch
        real :: x, y, z, ooz
        integer :: xp, yp, idx

        x = calculate_x(c, c_x, c_y, c_z)
        y = calculate_y(c, c_x, c_y, c_z)
        z = calculate_z(c, c_x, c_y, c_z) + camera_distance

        ooz = 1.0/z

        xp = width / 2 + int(k1 * ooz * x * 2)
        yp = height / 2 + int(k1 * ooz * y)

        idx = xp + yp * width

        if (idx .ge. 0 .and. idx .lt. area) then
            if (ooz .gt. z_buffer(idx)) then
                z_buffer(idx) = ooz
                buffer(idx) = ch
            endif
        endif
    end subroutine

    subroutine increase_cube_angle(c)
        type(cube), intent(inout) :: c

        c%a = c%a + 0.05
        c%b = c%b + 0.05
        c%c = c%c + 0.01
    end subroutine
end module cube_module

program main
    use cube_module
    implicit none

    integer :: k
    real :: cube_x, cube_y
    type(cube) :: c = cube(a=0.0, b=0.0, c=0.0)

    write(*, '(A)', advance='no') char(27)//'[2J'

    do
        buffer = background
        z_buffer = 0.0

        cube_x = -cube_width
        do while (cube_x .lt. cube_width)
            cube_y = -cube_width
            do while (cube_y .lt. cube_width)
                call calculate_for_surface(c, cube_x, cube_y, -cube_width, '@')
                call calculate_for_surface(c, cube_width, cube_y, cube_x, '$')
                call calculate_for_surface(c, -cube_width, cube_y, -cube_x, '~')
                call calculate_for_surface(c, -cube_x, cube_y, cube_width, '#')
                call calculate_for_surface(c, cube_x, -cube_width, -cube_y, ';')
                call calculate_for_surface(c, cube_x, cube_width, cube_y, '+')
                cube_y = cube_y + increment_speed
            end do
            cube_x = cube_x + increment_speed
        end do

        write(*, '(A)', advance='no') char(27)//'[H'
        do k = 0, area-1
            if (mod(k,width) .ne. 0) then
                write(*, '(A)', advance='no') buffer(k)
            else
                write(*,'(A)')
            end if
        end do

        call increase_cube_angle(c)
        call sleepqq(50)
    end do

end program main
