use Mix.Config

config :robocar, :sysfs_root_path, "/tmp/sys/class/pwm"

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :robocar, RoboCarWeb.Endpoint,
  http: [port: 4002],
  server: false

# Print only warnings and errors during test
config :logger, level: :warn
