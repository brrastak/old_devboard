#!/usr/bin/env bash

set -e

# Paths
SRC_DIR=./cpp
BUILD_DIR=./cpp_target

FILE_NAME=main
SRC_FILE=$SRC_DIR/$FILE_NAME.cpp
OUT_FILE=$BUILD_DIR/$FILE_NAME

MCU=attiny2313

# Create output directory
mkdir -p $BUILD_DIR

echo "Compiling and linking C++..."


avr-g++ \
  -mmcu=$MCU \
  -I$SRC_DIR \
  -Os \
  -ffunction-sections -fdata-sections \
  -fno-exceptions -fno-rtti \
  -Wl,--gc-sections \
  -o $OUT_FILE.elf \
  $SRC_FILE

echo "Generating HEX..."
avr-objcopy -O ihex -R .eeprom $OUT_FILE.elf $OUT_FILE.hex

# Optional: disassembly
# echo "Generating LST..."
# avr-objdump -d -S $OUT_FILE.elf > $OUT_FILE.lst

echo "Done!"
echo "Output: $OUT_FILE.hex"
# echo "Output: $OUT_FILE.lst"
