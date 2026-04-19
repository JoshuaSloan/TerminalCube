use std::{thread, time};

const SLEEP_TIME: time::Duration = time::Duration::from_millis(50);
const BACKGROUND_ASCII_CODE: char = ' ';

struct Cube {
    a: f64,
    b: f64,
    c: f64,
    increment_speed: f64,
    camera_distance: f64,
    cube_width: f64,
    width: usize,
    height: usize,
    area: usize,
    k1: f64,
    buffer: Vec<char>,
    z_buffer: Vec<f64>,
}

impl Cube {
    fn new(width: usize, height: usize, cube_width: f64, camera_distance: f64) -> Cube {
        Cube {
            a: 0.0,
            b: 0.0,
            c: 0.0,
            increment_speed: 0.5,
            camera_distance,
            cube_width,
            width,
            height,
            area: width * height,
            k1: 40.0,
            buffer: vec![BACKGROUND_ASCII_CODE; width * height],
            z_buffer: vec![0.0; width * height],
        }
    }

    fn calculate_x(&self, i: f64, j: f64, k: f64) -> f64 {
        let a = self.a;
        let b = self.b;
        let c = self.c;
        j * a.sin() * b.sin() * c.cos() - k * a.cos() * b.sin() * c.cos()
            + j * a.cos() * c.sin()
            + k * a.sin() * c.sin()
            + i * b.cos() * c.cos()
    }

    fn calculate_y(&self, i: f64, j: f64, k: f64) -> f64 {
        let a = self.a;
        let b = self.b;
        let c = self.c;
        j * a.cos() * c.cos() + k * a.sin() * c.cos() - j * a.sin() * b.sin() * c.sin()
            + k * a.cos() * b.sin() * c.sin()
            - i * b.cos() * c.sin()
    }

    fn calculate_z(&self, i: f64, j: f64, k: f64) -> f64 {
        let a = self.a;
        let b = self.b;
        k * a.cos() * b.cos() - j * a.sin() * b.cos() + i * b.sin()
    }

    fn calculate_for_surface(&mut self, cube_x: f64, cube_y: f64, cube_z: f64, ch: char) {
        let x = self.calculate_x(cube_x, cube_y, cube_z);
        let y = self.calculate_y(cube_x, cube_y, cube_z);
        let z = self.calculate_z(cube_x, cube_y, cube_z) + self.camera_distance;

        let ooz = 1.0 / z;

        let xp: i64 = self.width as i64 / 2 + (self.k1 * ooz * x * 2.0) as i64;
        let yp: i64 = self.height as i64 / 2 + (self.k1 * ooz * y) as i64;

        let idx = (xp + yp * self.width as i64) as usize;
        if idx < self.area && ooz > self.z_buffer[idx] {
            self.z_buffer[idx] = ooz;
            self.buffer[idx] = ch;
        }
    }

    fn increase_cube_angle(&mut self) {
        self.a += 0.05;
        self.b += 0.05;
        self.c += 0.01;
    }
}

fn main() {
    let mut my_cube = Cube::new(75, 40, 7.0, 50.0);
    let cube_width = my_cube.cube_width;
    let increment_speed = my_cube.increment_speed;

    print!("\x1b[2J");
    loop {
        my_cube.buffer.fill(BACKGROUND_ASCII_CODE);
        my_cube.z_buffer.fill(0.0);

        let mut cube_x = -cube_width;
        while cube_x < cube_width {
            let mut cube_y = -cube_width;
            while cube_y < cube_width {
                my_cube.calculate_for_surface(cube_x, cube_y, -cube_width, '@');
                my_cube.calculate_for_surface(cube_width, cube_y, cube_x, '$');
                my_cube.calculate_for_surface(-cube_width, cube_y, -cube_x, '~');
                my_cube.calculate_for_surface(-cube_x, cube_y, cube_width, '#');
                my_cube.calculate_for_surface(cube_x, -cube_width, -cube_y, ';');
                my_cube.calculate_for_surface(cube_x, cube_width, cube_y, '+');

                cube_y += increment_speed;
            }
            cube_x += increment_speed;
        }

        print!("\x1b[H");
        for k in 0..my_cube.area {
            print!(
                "{}",
                if k % my_cube.width != 0 {
                    my_cube.buffer[k]
                } else {
                    '\n'
                }
            );
        }

        my_cube.increase_cube_angle();
        thread::sleep(SLEEP_TIME);
    }
}
