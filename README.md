# Responsive Image Server

This project sets up a responsive image server using NGINX in Docker. The server dynamically resizes images based on URL parameters and caches the resized images to improve performance. 

## Features

- **Dynamic Image Resizing**: Supports on-the-fly resizing of images based on the URL pattern.
- **Caching**: Caches the resized images to reduce processing time for repeated requests.
- **Dockerized Environment**: Runs in a Docker container for easy deployment.

## Prerequisites

- Docker installed on your system.
- Docker Compose installed.

## Project Structure

```
.
├── Dockerfile              # Dockerfile for building the NGINX image with image filter module
├── docker-compose.yml      # Docker Compose file for setting up the service
├── nginx-config/           # Directory containing NGINX configuration files
│   └── image.conf          # NGINX configuration file for the image server
└── README.md               # Project documentation
```

## Getting Started

### 1. Clone the Repository

Clone the repository to your local machine:

```sh
git clone <repository-url>
cd responsive-image-server
```

### 2. Prepare the Directories

Create the directories for the image files and cache:

```sh
mkdir -p /data/files
mkdir -p /data/nginx-images-cache
```

- `/data/files`: Directory where your original images are stored.
- `/data/nginx-images-cache`: Directory for caching the resized images.

### 3. Build and Run the Docker Container

Build and start the Docker container using Docker Compose:

```sh
docker-compose up --build
```

This will:

- Build the custom NGINX image with the `ngx_http_image_filter_module`.
- Start the NGINX server on port `3333` of your host machine.

### 4. Configure NGINX

The `nginx-config/image.conf` file contains the configuration for handling image resizing and caching:

- **Server on port 8888**: Handles image resizing using the `image_filter` module.
- **Server on port 80**: Caches and serves resized images.

### 5. Access the Server

Once the server is running, you can access it on `http://localhost:3333`.

### 6. Using the Image Resizing Feature

To resize an image, use the following URL pattern:

```
http://localhost:3333/{width}/{image_path}
```

- `{width}`: Desired width of the image.
- `{image_path}`: Path to the original image file stored in `/data/files`.

For example, to resize an image named `example.jpg` to a width of `300px`, access:

```
http://localhost:3333/300/example.jpg
```

## Configuration Details

### NGINX Configuration (`nginx-config/image.conf`)

- **Resizing Server (port 8888)**:
    - Resizes images dynamically based on URL patterns.
    - Caches resized images for efficient performance.
    - Uses the `image_filter` module for resizing.

- **Caching Server (port 80)**:
    - Acts as a proxy and caches responses from the resizing server.
    - Sets cache control headers for one year (`expires 1y`).

### Docker Configuration (`Dockerfile`)

- Installs the `ngx_http_image_filter_module` for NGINX to support image resizing.
- Copies the NGINX configuration files from `nginx-config` to `/etc/nginx/conf.d/` in the container.

### Docker Compose (`docker-compose.yml`)

- Maps local directories to the container:
    - `./nginx-config` to `/etc/nginx/conf.d`
    - `/data/files` to `/files`
    - `/data/nginx-images-cache` to `/nginx-images-cache`
- Exposes port `3333` on the host machine to port `80` in the container.

## Stopping the Server

To stop the server, run:

```sh
docker-compose down
```

This will stop and remove the Docker container.
