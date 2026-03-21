#!/usr/bin/env bash

set -e

# Paths
SRC_DIR=./asm
BUILD_DIR=./asm_target

FILE_NAME=main
SRC_FILE=$SRC_DIR/$FILE_NAME.s
OUT_FILE=$BUILD_DIR/$FILE_NAME

MCU=attiny2313

# Create output directory
mkdir -p $BUILD_DIR

echo "Assembling and linking..."

avr-gcc \
  -mmcu=$MCU \
  -x assembler-with-cpp \
  -I$SRC_DIR \
  -o $OUT_FILE.elf \
  -nostartfiles \
  $SRC_FILE

echo "Generating HEX..."
avr-objcopy -O ihex -R .eeprom $OUT_FILE.elf $OUT_FILE.hex

# echo "Generating LST..."
# avr-objdump -d -S $OUT_FILE.elf > $OUT_FILE.lst

echo "Done!"
echo "Output: $OUT_FILE.hex"
# echo "Output: $OUT_FILE.lst"
