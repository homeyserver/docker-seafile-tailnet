# Seafile Server with Traefik

Docker Compose setup for Seafile Server Community Edition with Traefik reverse proxy integration.

## Overview

This setup includes:
- **Seafile Server** - File sync and share server
- **MariaDB** - Database backend
- **Redis** - Cache service (recommended for Seafile 13+)
- **Traefik** - Reverse proxy with automatic HTTPS (external)

## Prerequisites

- Docker and Docker Compose installed
- Traefik reverse proxy running with the `reverse-proxy` network
- Domain name configured (e.g., `seafile.shoji.me`)

## Quick Start

### 1. Clone and Configure

```bash
git clone https://github.com/electblake/homey-seafile-server.git
cd homey-seafile-server

# Copy the example environment file
cp .env.example .env

# Edit .env with your configuration
nano .env
```

### 2. Required Configuration

Edit `.env` and update at minimum:

```bash
# Generate a random JWT key (32+ characters):
# pwgen -s 40 1
JWT_PRIVATE_KEY=your_random_40_character_string_here

# MySQL passwords
INIT_SEAFILE_MYSQL_ROOT_PASSWORD=your_secure_root_password
SEAFILE_MYSQL_DB_PASSWORD=your_secure_seafile_password

# Admin account
INIT_SEAFILE_ADMIN_EMAIL=admin@yourdomain.com
INIT_SEAFILE_ADMIN_PASSWORD=your_secure_admin_password

# Your domain
SEAFILE_SERVER_HOSTNAME=seafile.shojinas.home.shoji.me
```

### 3. Create Volume Directories

```bash
# Create the directories for persistent data
sudo mkdir -p /volume1/docker/seafile/seafile-data
sudo mkdir -p /volume1/docker/seafile/mysql
sudo mkdir -p /volume1/docker/seafile/elasticsearch

# Set permissions (adjust PUID/PGID to match your .env)
sudo chown -R 1027:100 /volume1/docker/seafile/
```

### 4. Start Services

```bash
docker compose up -d
```

### 5. Monitor Startup

Watch the initialization process:

```bash
docker compose logs -f seafile
```

You should see output like:

```
---------------------------------
This is your configuration
---------------------------------
    server name:            seafile
    server ip/domain:       seafile.shojinas.home.shoji.me
    ...
Seafile server started
Seahub is started
Done.
```

### 6. Access Seafile

Once started, access Seafile at:
- https://seafile.shojinas.home.shoji.me (or your configured hostname)

Login with the admin credentials from your `.env` file.

## Directory Structure

```
/volume1/docker/seafile/
├── seafile-data/          # Seafile configuration and data
│   ├── seafile/          # Seafile server files
│   │   ├── conf/         # Configuration files
│   │   └── logs/         # Seafile logs
│   └── logs/             # System logs
│       └── var-log/      # Nginx and other logs
└── mysql/                # MySQL/MariaDB database files
```

## Management

### View Logs

```bash
# All services
docker compose logs -f

# Seafile only
docker compose logs -f seafile

# All Seafile logs on host
sudo tail -f $(find /volume1/docker/seafile/seafile-data/ -type f -name *.log 2>/dev/null)
```

### Add Admin User

```bash
docker exec -it seafile /opt/seafile/seafile-server-latest/reset-admin.sh
```

### Enter Container

```bash
docker exec -it seafile /bin/bash
```

### Restart Services

```bash
docker compose restart
```

### Stop Services

```bash
docker compose down
```

## Configuration

### Traefik Integration

The docker-compose.yml includes Traefik labels configured for:
- HTTP to HTTPS redirect
- Automatic SSL via your existing Traefik setup
- Multiple domain support

Update the Traefik labels in `docker-compose.yml` to match your domains:

```yaml
traefik.http.routers.seafile-insecure.rule: "Host(`seafile.shojinas.home.shoji.me`, `seafile.shoji.me`)"
traefik.http.routers.seafile.rule: "Host(`seafile.shojinas.home.shoji.me`, `seafile.shoji.me`)"
```

### Advanced Configuration

After first startup, you can modify:
- `/volume1/docker/seafile/seafile-data/seafile/conf/seafile.conf` - Seafile server settings
- `/volume1/docker/seafile/seafile-data/seafile/conf/seahub_settings.py` - Web interface settings
- `/volume1/docker/seafile/seafile-data/seafile/conf/ccnet.conf` - Network settings

Restart after changes:
```bash
docker compose restart seafile
```

## Backup

Backup these directories:
- `/volume1/docker/seafile/seafile-data` - All Seafile data
- `/volume1/docker/seafile/mysql` - Database files

```bash
# Example backup script
sudo tar -czf seafile-backup-$(date +%Y%m%d).tar.gz \
  /volume1/docker/seafile/seafile-data \
  /volume1/docker/seafile/mysql
```

## Troubleshooting

### Services won't start

Check logs:
```bash
docker compose logs -f
```

### Reset Everything

**WARNING: This deletes all data!**

```bash
docker compose down -v
sudo rm -rf /volume1/docker/seafile/seafile-data
sudo rm -rf /volume1/docker/seafile/mysql
# Then start over from step 3
```

### Port Conflicts

If port 80 is already in use by Traefik (expected), that's fine - Traefik will proxy to Seafile.

### Permission Issues

Ensure volumes have correct ownership:
```bash
sudo chown -R 1027:100 /volume1/docker/seafile/
```

## Environment Variables

See `.env.example` for all available configuration options.

Key variables:
- `SEAFILE_SERVER_HOSTNAME` - Your domain name
- `JWT_PRIVATE_KEY` - Random 32+ character string
- `INIT_SEAFILE_MYSQL_ROOT_PASSWORD` - MySQL root password
- `SEAFILE_MYSQL_DB_PASSWORD` - MySQL seafile user password
- `INIT_SEAFILE_ADMIN_EMAIL` - Initial admin email
- `INIT_SEAFILE_ADMIN_PASSWORD` - Initial admin password

## References

- [Seafile Manual](https://manual.seafile.com/)
- [Seafile Docker Setup](https://manual.seafile.com/latest/setup/setup_ce_by_docker/)
- [Traefik Documentation](https://doc.traefik.io/traefik/)

## License

See LICENSE file.