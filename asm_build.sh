#!/usr/bin/env bash

set -e

# Paths
SRC_DIR=./asm
BUILD_DIR=./asm_target

SRC_FILE=$SRC_DIR/main.s
OUT_FILE=$BUILD_DIR/main

MCU=attiny2313

# Create output directory
mkdir -p $BUILD_DIR

echo "Assembling and linking..."

avr-gcc \
  -mmcu=$MCU \
  -x assembler-with-cpp \
  -I$SRC_DIR \
  -o $OUT_FILE.elf \
  $SRC_FILE

echo "Generating HEX..."

avr-objcopy -O ihex -R .eeprom $OUT_FILE.elf $OUT_FILE.hex

echo "Done!"
echo "Output: $OUT_FILE.hex"