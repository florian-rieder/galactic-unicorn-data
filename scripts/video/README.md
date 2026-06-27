# Installation

## Setup virtual environment (optional but recommended)

```bash
# Create the environment
python -m venv .venv
# Activate the environment
.venv/bin/activate
```

## Install dependencies

```bash
pip install Pillow opencv-python
```

## Convert a video file

Since OpenCV uses ffmpeg under the hood, it can handle a wide variety of different video file formats.

```
python video2bin.py myvideo.mp4 -o myconvertedvideo.guv
```
