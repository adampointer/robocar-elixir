use rustler::{Atom, Env, Term};
use rustler::resource::ResourceArc;
use std::sync::Mutex;
use system::DriveSystem;
use system::Sensor;

mod system;

mod atoms {
  rustler::atoms! {
    ok,
    error,
    gpio_error,
    lock_error,
  }
}

pub struct DriveSystemResource(Mutex<DriveSystem>);

type DriveSystemArc = ResourceArc<DriveSystemResource>;

pub struct SensorSystemResource(Mutex<Sensor>);

type SensorSystemArc = ResourceArc<SensorSystemResource>;

#[rustler::nif]
fn new_sensor_system() -> Result<SensorSystemArc, Atom>{
  let sensor = match Sensor::new() {
    Ok(sensor) => sensor,
    Err(err) => {
      println!("error initialising sensor: {}", err);
      return Err(atoms::gpio_error())
    }
  };
  let resource = ResourceArc::new(SensorSystemResource(Mutex::new(sensor)));

  Ok(resource)
}

#[rustler::nif]
fn poll_distance(resource: ResourceArc<SensorSystemResource>) -> Result<f64, Atom>{
  let mut sensor = match resource.0.try_lock() {
    Ok(guard) => guard,
    Err(_) => return Err(atoms::lock_error()),
  };

  match sensor.poll_distance() {
    Ok(distance) => Ok(distance),
    Err(_) => Err(atoms::gpio_error()),
  }
}

#[rustler::nif]
fn new_drive_system() -> Result<DriveSystemArc, Atom>{
  let drive_system = match DriveSystem::new() {
    Ok(drive_system) => drive_system,
    Err(err) => {
      println!("error initialising drive system: {}", err);
      return Err(atoms::gpio_error())
    }
  };
  let resource = ResourceArc::new(DriveSystemResource(Mutex::new(drive_system)));

  Ok(resource)
}

#[rustler::nif]
fn forwards(resource: ResourceArc<DriveSystemResource>, power_pct: u32) -> Result<(), Atom>{
  let drive = match resource.0.try_lock() {
    Ok(guard) => guard,
    Err(_) => return Err(atoms::lock_error()),
  };

  match drive.forwards(power_pct) {
    Ok(_) => Ok(()),
    Err(err) => {
      println!("error driving forwards: {}", err);
      return Err(atoms::gpio_error())
    }
  }
}

#[rustler::nif]
fn reverse(resource: ResourceArc<DriveSystemResource>, power_pct: u32) -> Result<(), Atom>{
  let drive = match resource.0.try_lock() {
    Ok(guard) => guard,
    Err(_) => return Err(atoms::lock_error()),
  };

  match drive.reverse(power_pct) {
    Ok(_) => Ok(()),
    Err(err) => {
      println!("error reversing: {}", err);
      return Err(atoms::gpio_error())
    }
  }
}

#[rustler::nif]
fn left(resource: ResourceArc<DriveSystemResource>, power_pct: u32) -> Result<(), Atom>{
  let drive = match resource.0.try_lock() {
    Ok(guard) => guard,
    Err(_) => return Err(atoms::lock_error()),
  };

  match drive.left(power_pct) {
    Ok(_) => Ok(()),
    Err(err) => {
      println!("error turning: {}", err);
      return Err(atoms::gpio_error())
    }
  }
}

#[rustler::nif]
fn right(resource: ResourceArc<DriveSystemResource>, power_pct: u32) -> Result<(), Atom>{
  let drive = match resource.0.try_lock() {
    Ok(guard) => guard,
    Err(_) => return Err(atoms::lock_error()),
  };

  match drive.right(power_pct) {
    Ok(_) => Ok(()),
    Err(err) => {
      println!("error turning: {}", err);
      return Err(atoms::gpio_error())
    }
  }
}

#[rustler::nif]
fn stop(resource: ResourceArc<DriveSystemResource>) -> Result<(), Atom>{
  let drive = match resource.0.try_lock() {
    Ok(guard) => guard,
    Err(_) => return Err(atoms::lock_error()),
  };

  match drive.stop() {
    Ok(_) => Ok(()),
    Err(err) => {
      println!("error stopping: {}", err);
      return Err(atoms::gpio_error())
    }
  }
}

rustler::init!(
  "Elixir.RoboCar.Native.NifBridge",
  [
    new_drive_system,
    new_sensor_system,
    poll_distance,
    forwards,
    reverse,
    right,
    stop,
    left,
  ],
  load=load
);

fn load(env: Env, _info: Term) -> bool{
  rustler::resource!(DriveSystemResource, env);
  rustler::resource!(SensorSystemResource, env);
  true
}
