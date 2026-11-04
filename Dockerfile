# CT Reconstruction - Student Package Dockerfile
# Simple image for students to test their implementations

FROM gnuoctave/octave:11.1.0

# Avoid interactive prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive

# Install Python and zip for submission packing
RUN apt-get update && apt-get install -y --no-install-recommends \
    python3 \
    python3-pip \
    zip \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /workspace

# Copy all project files from the current directory to the image
COPY . .

# Default command: run student's reconstruction
CMD ["octave", "--no-gui", "--no-window-system", "--eval", "run_tier"]
