use std::error::Error;
use gpio_cdev::LineHandle;
use sysfs_pwm::{Pwm, Error as PwmError};
use super::gpio::get_output;

const LEFT_FORWARD: u32 = 51;
const LEFT_REVERSE: u32 = 77;
const RIGHT_FORWARD: u32 = 76;
const RIGHT_REVERSE: u32 = 12;
const PWM_CHIP: u32 = 0;
const PWM_CHANNEL_1: u32 = 0;
const PWM_CHANNEL_2: u32 = 2;
const PWM_FREQ_HZ: u32 = 100;

pub struct DriveSystem {
  pin_left_forward: LineHandle,
  pin_left_reverse: LineHandle,
  pin_right_forward: LineHandle,
  pin_right_reverse: LineHandle,
  pwm_left: Pwm,
  pwm_right: Pwm,
}

impl DriveSystem {
  pub fn new() -> Result<Self, Box<dyn Error>> {
    Ok(Self{
      pin_left_forward: get_output(LEFT_FORWARD)?,
      pin_left_reverse: get_output(LEFT_REVERSE)?,
      pin_right_forward: get_output(RIGHT_FORWARD)?,
      pin_right_reverse: get_output(RIGHT_REVERSE)?,
      pwm_left: Pwm::new(PWM_CHIP, PWM_CHANNEL_1)?,
      pwm_right: Pwm::new(PWM_CHIP, PWM_CHANNEL_2)?,
    })
  }

  pub fn forwards(&self, power_pct: u32) -> Result<(), Box<dyn Error>> {
    self.start_pwm(power_pct)?;
    self.pin_left_forward.set_value(1)?;
    self.pin_right_forward.set_value(1)?;
    self.pin_left_reverse.set_value(0)?;
    self.pin_right_reverse.set_value(0)?;

    Ok(())
  }

  pub fn reverse(&self, power_pct: u32) -> Result<(), Box<dyn Error>> {
    self.start_pwm(power_pct)?;
    self.pin_left_reverse.set_value(1)?;
    self.pin_right_reverse.set_value(1)?;
    self.pin_left_forward.set_value(0)?;
    self.pin_right_forward.set_value(0)?;

    Ok(())
  }

  pub fn stop(&self) -> Result<(), Box<dyn Error>> {
    self.stop_pwm()?;
    self.pin_left_reverse.set_value(0)?;
    self.pin_right_reverse.set_value(0)?;
    self.pin_left_forward.set_value(0)?;
    self.pin_right_forward.set_value(0)?;

    Ok(())
  }

  pub fn left(&self, power_pct: u32) -> Result<(), Box<dyn Error>> {
    self.start_pwm(power_pct)?;
    self.pin_left_reverse.set_value(1)?;
    self.pin_right_reverse.set_value(0)?;
    self.pin_left_forward.set_value(0)?;
    self.pin_right_forward.set_value(1)?;

    Ok(())
  }

  pub fn right(&self, power_pct: u32) -> Result<(), Box<dyn Error>> {
    self.start_pwm(power_pct)?;
    self.pin_left_reverse.set_value(0)?;
    self.pin_right_reverse.set_value(1)?;
    self.pin_left_forward.set_value(1)?;
    self.pin_right_forward.set_value(0)?;

    Ok(())
  }

  fn start_pwm(&self, power_pct: u32) -> Result<(), PwmError> {
    let (period, duty_cycle) = DriveSystem::calculate_period_duty_cycle(power_pct);
    self.pwm_left.set_period_ns(period)?;
    self.pwm_left.set_duty_cycle_ns(duty_cycle)?;
    self.pwm_left.enable(true)?;
    self.pwm_right.set_period_ns(period)?;
    self.pwm_right.set_duty_cycle_ns(duty_cycle)?;
    self.pwm_right.enable(true)?;

    Ok(())
  }

  fn stop_pwm(&self) -> Result<(), PwmError> {
    self.pwm_left.enable(false)?;
    self.pwm_right.enable(false)?;

    Ok(())
  }

  fn calculate_period_duty_cycle(power_pct: u32) -> (u32, u32) {
    let period = 1000000000 / PWM_FREQ_HZ;
    let duty_cycle = period * (power_pct / 100);

    (period, duty_cycle)
  }
}
