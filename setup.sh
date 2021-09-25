#!/bin/bash

chmod g+rw /dev/gpiochip0
chown root.gpio /dev/gpiochip0
echo 0 > /sys/class/pwm/pwmchip0/export
echo 2  > /sys/class/pwm/pwmchip0/export

