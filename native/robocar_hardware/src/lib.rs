use rustler::{Atom, Env, Term};
use rustler::resource::ResourceArc;
use std::sync::Mutex;
use crate::drive_system::DriveSystem;

mod drive_system;

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

#[rustler::nif]
fn new() -> Result<DriveSystemArc, Atom>{
  let drive_system = match DriveSystem::new() {
    Ok(drive_system) => drive_system,
    Err(err) => {
      println!("error initialising hardware: {}", err);
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
    new,
    forwards,
    reverse,
    stop,
  ],
  load=load
);

fn load(env: Env, _info: Term) -> bool{
  rustler::resource!(DriveSystemResource, env);
  true
}
