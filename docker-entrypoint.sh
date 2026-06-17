#!/bin/sh
set -e

# Wait for MySQL to be ready
echo "Waiting for MySQL..."
while ! nc -z db 3306; do
  sleep 1
done
echo "MySQL is up!"

# Setup .env
if [ ! -f .env ]; then
    echo "Creating .env file..."
    cp env.example .env
fi

# Update .env with Docker service names and configuration
echo "Configuring .env..."
sed -i "s/DB_HOST=127.0.0.1/DB_HOST=db/g" .env
sed -i "s/DB_DATABASE=bemusic/DB_DATABASE=${DB_DATABASE:-bemusic}/g" .env
sed -i "s/DB_USERNAME=root/DB_USERNAME=${DB_USERNAME:-bemusic}/g" .env
sed -i "s/DB_PASSWORD=/DB_PASSWORD=${DB_PASSWORD:-secret}/g" .env
sed -i "s/REDIS_HOST=127.0.0.1/REDIS_HOST=redis/g" .env
sed -i "s/INSTALLED=false/INSTALLED=true/g" .env
sed -i "s|APP_URL=http://localhost$|APP_URL=${APP_URL:-http://localhost:8000}|g" .env

# Ensure demo credentials are set in .env
if ! grep -q "DEMO_ADMIN_EMAIL=" .env; then
    echo "DEMO_ADMIN_EMAIL=${DEMO_ADMIN_EMAIL:-admin@admin.com}" >> .env
fi
if ! grep -q "DEMO_ADMIN_PASSWORD=" .env; then
    echo "DEMO_ADMIN_PASSWORD=${DEMO_ADMIN_PASSWORD:-admin}" >> .env
fi

# Always generate key if default or missing
if ! grep -q "APP_KEY=base64" .env || grep -q "NE5wdzVEQm9CeUVMTGRtczNEZXTuVjFre1Q0QmJTQUc=" .env; then
    php artisan key:generate --force
fi

# Run migrations
echo "Running migrations..."
php artisan migrate --force

# Seed database in correct order
echo "Seeding common permissions..."
php artisan db:seed --class="Common\Database\Seeders\PermissionTableSeeder" --force || true
echo "Seeding common roles..."
php artisan db:seed --class="Common\Database\Seeders\RolesTableSeeder" --force || true
echo "Seeding common themes..."
php artisan db:seed --class="Common\Database\Seeders\CssThemesTableSeeder" --force || true
echo "Seeding application data..."
php artisan db:seed --force || true

# Initialize Admin Account
echo "Initializing Admin Account..."
php artisan demo:reset || echo "Admin reset failed, but continuing..."

# Create storage link
echo "Creating storage link..."
if [ -d "public/storage" ] && [ ! -L "public/storage" ]; then
    rm -rf public/storage
fi
php artisan storage:link --force || true

# Clear and Cache settings
echo "Managing cache..."
php artisan config:clear
php artisan cache:clear
php artisan config:cache
php artisan route:cache
php artisan view:cache

# Fix permissions
echo "Setting permissions..."
chown -R www-data:www-data storage bootstrap/cache public/storage public
chmod -R 775 storage bootstrap/cache public/storage public

echo "BeMusic is ready!"
exec "$@"
