# SPDX-FileCopyrightText: 2021 ladyada for Adafruit Industries
# SPDX-License-Identifier: MIT

# -*- coding: utf-8 -*-

import time
import subprocess
import digitalio
import board
import os
from PIL import Image, ImageDraw, ImageFont
from adafruit_rgb_display import st7789
from digitalio import DigitalInOut, Direction


# Configuration for CS and DC pins (these are FeatherWing defaults on M0/M4):
cs_pin = digitalio.DigitalInOut(board.CE0)
dc_pin = digitalio.DigitalInOut(board.D25)
backlight = digitalio.DigitalInOut(board.D26)
reset_pin = None

# Config for display baudrate (default max is 24mhz):
BAUDRATE = 64000000
SPEED_FILE = "/tmp/speed.txt"

# Setup SPI bus using hardware SPI:
spi = board.SPI()

# Create the ST7789 display:
disp = st7789.ST7789(
    spi,
    cs=cs_pin,
    dc=dc_pin,
    rst=reset_pin,
    baudrate=BAUDRATE,
    width=240,
    height=240,
    x_offset=0,
    y_offset=80,
)

# Input pins:
button_A = DigitalInOut(board.D5)
button_A.direction = Direction.INPUT

button_B = DigitalInOut(board.D6)
button_B.direction = Direction.INPUT

# Turn on the Backlight
backlight.switch_to_output()
backlight.value = True

# Create blank image for drawing.
# Make sure to create image with mode 'RGB' for full color.
height = disp.width  # we swap height/width to rotate it to landscape!
width = disp.height
image = Image.new("RGB", (width, height))
rotation = 0
LineSpacing = 5

# Get drawing object to draw on image.
draw = ImageDraw.Draw(image)

# Draw a black filled box to clear the image.
draw.rectangle((0, 0, width, height), outline=0, fill=(0, 0, 0))
disp.image(image, rotation)
# Draw some shapes.
# First define some constants to allow easy resizing of shapes.
padding = -2
top = padding
bottom = height - padding
# Move left to right keeping track of the current x position for drawing shapes.
x = 0


# Alternatively load a TTF font.  Make sure the .ttf font file is in the
# same directory as the python script!
# Some other nice fonts to try: http://www.dafont.com/bitmap.php
font = ImageFont.truetype("/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf", 24)

# Turn on the backlight
backlight = digitalio.DigitalInOut(board.D22)
backlight.switch_to_output()
backlight.value = True

# Create the temp. file if it doesn't exist
file = open(SPEED_FILE, 'a')
file.close()

# Flag to indicate this is the first time we have started
First = True

while True:
    # Draw a black filled box to clear the image.
    draw.rectangle((0, 0, width, height), outline=0, fill=0)

    # Shell scripts for system monitoring from here:
    # https://unix.stackexchange.com/questions/119126/command-to-display-memory-usage-disk-usage-and-cpu-load
    cmd = "hostname -I | cut -d' ' -f1"
    IP = "IP: " + subprocess.check_output(cmd, shell=True).decode("utf-8")

    cmd = "top -bn1 | grep load | awk '{printf \"CPU Load: %.2f\", $(NF-2)}'"
    CPU = subprocess.check_output(cmd, shell=True).decode("utf-8")

    cmd = "free -m | awk 'NR==2{printf \"Mem: %s/%s MB\", $3,$2 }'"
    MemUsage = subprocess.check_output(cmd, shell=True).decode("utf-8")

    cmd = 'df -h | awk \'$NF=="/"{printf "Disk: %d/%d GB  %s", $3,$2,$5}\''
    Disk = subprocess.check_output(cmd, shell=True).decode("utf-8")

    cmd = "cat /sys/class/thermal/thermal_zone0/temp |  awk '{printf \"CPU Temp: %.1f C\", $(NF-0) / 1000}'"  # pylint: disable=line-too-long
    Temp = subprocess.check_output(cmd, shell=True).decode("utf-8")

    cmd="date '+%Y%m%d:%H%M%S'"
    Time = subprocess.check_output(cmd, shell=True).decode("utf-8")

    if not button_B.value:  # B button pressed
       cmd="sudo shutdown -h now"

       y = top
       draw.text((x, y), "Shutting Down ...", font=font, fill="#FFFF00")

       disp.image(image, rotation)
       time.sleep(5)

       subprocess.check_output(cmd, shell=True).decode("utf-8")


    # Write five lines of text.
    y = top
    draw.text((x, y), Time, font=font, fill="#FFFF00")

    y += (LineSpacing + font.getsize(Time)[1])
    draw.text((x, y), IP, font=font, fill="#FFFFFF")

    y += (LineSpacing + font.getsize(IP)[1])
    draw.text((x, y), CPU, font=font, fill="#FFFF00")

    y += (LineSpacing + font.getsize(CPU)[1])
    draw.text((x, y), MemUsage, font=font, fill="#00FF00")

    y += (LineSpacing + font.getsize(MemUsage)[1])
    draw.text((x, y), Disk, font=font, fill="#0000FF")

    y += (LineSpacing + font.getsize(Disk)[1])
    draw.text((x, y), Temp, font=font, fill="#FF00FF")

    y += (LineSpacing + font.getsize(Temp)[1])

    if First or not button_A.value:  # A button pressed
       cmd="/home/pi/bin/perform-speed-test.sh " + SPEED_FILE

       draw.text((x, y), "Mb/s: Checking ...", font=font, fill="#FFFFFF")

       disp.image(image, rotation)
       subprocess.check_output(cmd, shell=True).decode("utf-8")

    else:
       cmd="echo $((($(date +%s) - $(date +%s -r " + SPEED_FILE + ")) / 60))"
       Age = subprocess.check_output(cmd, shell=True).decode("utf-8")

       cmd="cat " + SPEED_FILE + " | awk '{ print $2,\" \"}' | tr -d '\n' | sed 's/Mb\/s//g'"
       Speed = "Mb/s: " + subprocess.check_output(cmd, shell=True).decode("utf-8") + "m" + Age

       draw.text((x, y), Speed, font=font, fill="#FFFFFF")

       # Display image.
       disp.image(image, rotation)

    time.sleep(10)

    First = False
