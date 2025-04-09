#!/bin/bash

# A simple wrapper for ffmpeg that passes all arguments as-is

# Optional: Uncomment to log the command being run
echo "Running ffmpeg with args: $@"

# Forward all arguments to ffmpeg
exec ffmpeg "$@"

