# BeMusic Docker Deployment

This setup allows you to deploy BeMusic with a single command using Docker Compose.

## Prerequisites

- [Docker](https://docs.docker.com/get-docker/)
- [Docker Compose](https://docs.docker.com/compose/install/)

## Quick Start

1. Clone the repository (if you haven't already).
2. Run the following command in the root directory:

   ```bash
   docker-compose up -d
   ```

3. Wait for the containers to build and start. The first run will take a few minutes as it installs dependencies and builds frontend assets.
4. Access the application at [http://localhost:8000](http://localhost:8000).

## Initial Setup

By default, the application will redirect you to the installer. You can follow the on-screen instructions to set up your administrator account and site settings.

Alternatively, if you want to skip the installer or reset the admin account, you can run:

```bash
docker-compose exec app php artisan demo:reset
```

This will create an administrator account with:
- **Email:** `admin@admin.com`
- **Password:** `admin`

## Services

- **app**: PHP 8.3-FPM + Nginx + Queue Worker (all in one for simplicity).
- **db**: MySQL 8.0.
- **redis**: Redis for caching and queues.

## Configuration

You can customize the environment variables in `docker-compose.yml`. For more advanced configuration, you can modify the `docker/` directory files.

## Useful Commands

- **View Logs:** `docker-compose logs -f`
- **Stop Services:** `docker-compose down`
- **Run Artisan Commands:** `docker-compose exec app php artisan <command>`
- **Rebuild Containers:** `docker-compose up -d --build`
