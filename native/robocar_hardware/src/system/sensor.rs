use super::gpio::{get_output, get_input};
use std::time::{Duration, Instant};
use gpio_cdev::LineHandle;
use std::thread::sleep;

const TRIGGER_PIN: u32 = 216;
const ECHO_PIN: u32 = 50;
const SONIC_SPEED: f64 = 0.034;
const POLL_TIME: u64 = 500;

pub struct Sensor {
  trig_pin: LineHandle,
  echo_pin: LineHandle,
}

impl Sensor {
  pub fn new() -> Result<Self, Box<dyn std::error::Error>> {
    Ok(Self {
      trig_pin: get_output(TRIGGER_PIN)?,
      echo_pin: get_input(ECHO_PIN)?,
    })
  }

  // Polls distance from sensor
  pub fn poll_distance(&mut self) -> Result<f64, Box<dyn std::error::Error>> {
    self.trig_pin.set_value(0)?;
    sleep(Duration::from_millis(POLL_TIME));

    self.trig_pin.set_value(1)?;
    sleep(Duration::from_micros(10));
    self.trig_pin.set_value(0)?;

    loop {
      let val = self.echo_pin.get_value()?;
      if val == 1 {
        break;
      }
    }
    
    let pulse_start = Instant::now();

    loop {
      let val = self.echo_pin.get_value()?;
      if val == 0 {
        break;
      }
    }

    let pulse_duration = pulse_start.elapsed().as_micros();
    let distance = (SONIC_SPEED * pulse_duration as f64) / 2.0;
    return Ok(distance);
  }
}
