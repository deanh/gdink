#!/bin/bash

# Check if inklecate is installed
if ! command -v inklecate &> /dev/null; then
    echo "Error: inklecate not found. Please install it from https://github.com/inkle/ink/releases"
    exit 1
fi

# Get the input file from arguments
if [ $# -lt 1 ]; then
    echo "Usage: $0 <ink_file> [output_file]"
    exit 1
fi

INK_FILE=$1
OUTPUT_FILE="${2:-${INK_FILE%.*}.json}"

echo "Compiling $INK_FILE to $OUTPUT_FILE..."
inklecate -o "$OUTPUT_FILE" "$INK_FILE"

if [ $? -eq 0 ]; then
    echo "Compilation successful!"
else
    echo "Compilation failed."
    exit 1
fi