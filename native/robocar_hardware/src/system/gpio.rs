use gpio_cdev::{Chip, LineRequestFlags, LineHandle, Error, Line};

pub fn get_output(gpio_number: u32) -> Result<LineHandle, Error>{
    let line = get_line(gpio_number)?;
    line.request(LineRequestFlags::OUTPUT, 0, "robocar")
}

pub fn get_input(gpio_number: u32) -> Result<LineHandle, Error>{
    let line = get_line(gpio_number)?;
    line.request(LineRequestFlags::INPUT, 0, "robocar")
}

pub fn get_line(gpio_number: u32) -> Result<Line, Error>{
    let mut chip = Chip::new("/dev/gpiochip0")?;
    chip.get_line(gpio_number)
}