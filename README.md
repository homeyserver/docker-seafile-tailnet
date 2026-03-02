# Seafile Server with Traefik and Tailscale

Docker Compose setup for Seafile Server Community Edition with Traefik reverse proxy and optional Tailscale integration.

## Overview

This setup includes:
- **Seafile Server** - File sync and share server
- **MariaDB** - Database backend
- **Redis** - Cache service (recommended for Seafile 13+)
- **Traefik** - Reverse proxy with automatic HTTPS (external)
- **Tailscale** - Optional VPN integration to expose Seafile on your tailnet

## Prerequisites

- Docker and Docker Compose installed
- Traefik reverse proxy running with the `reverse-proxy` network
- Domain name configured (e.g., `seafile.shoji.me`)
- (Optional) Tailscale account and auth key for tailnet integration

## Quick Start

### Option 1: Using Portainer (Recommended for GUI users)

1. **In Portainer, create a new Stack:**
   - Go to Stacks → Add Stack
   - Name it `seafile`
   - Copy the contents of `docker-compose.yml` into the Web editor

2. **Configure environment variables in Portainer:**
   - Scroll down to "Environment variables"
   - Click "Add an environment variable" for each required variable:
     - `INIT_SEAFILE_MYSQL_ROOT_PASSWORD` - Strong MySQL root password
     - `SEAFILE_MYSQL_DB_PASSWORD` - Strong MySQL seafile password
     - `JWT_PRIVATE_KEY` - Generate with: `openssl rand -base64 32`
     - `SEAFILE_SERVER_HOSTNAME` - Your domain (e.g., `seafile.shoji.me`)
     - `INIT_SEAFILE_ADMIN_EMAIL` - Admin email
     - `INIT_SEAFILE_ADMIN_PASSWORD` - Strong admin password
     - (Optional) `TAILSCALE_AUTHKEY` - From https://login.tailscale.com/admin/settings/keys
     - (Optional) `TAILSCALE_HOSTNAME` - Hostname on tailnet (e.g., `seafile`)

3. **Create volume directories on your host:**
   ```bash
   sudo mkdir -p /volume1/docker/seafile/{seafile-data,mysql,tailscale}
   sudo chown -R 1027:100 /volume1/docker/seafile/
   ```

4. **Deploy the stack** in Portainer

5. **Monitor logs** in Portainer to watch initialization

**To disable Tailscale in Portainer:**
- Simply stop the `seafile-tailscale` container or leave `TAILSCALE_AUTHKEY` empty

### Option 2: Using Docker Compose CLI

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
# Generate a random JWT key (32+ characters)
# Option 1: Using pwgen (install with: apt-get install pwgen or brew install pwgen)
pwgen -s 40 1
# Option 2: Using openssl (available on most systems)
openssl rand -base64 32

# Then set it in .env:
JWT_PRIVATE_KEY=your_random_40_character_string_here

# MySQL passwords - use strong, unique passwords
INIT_SEAFILE_MYSQL_ROOT_PASSWORD=your_secure_root_password
SEAFILE_MYSQL_DB_PASSWORD=your_secure_seafile_password

# Admin account
INIT_SEAFILE_ADMIN_EMAIL=admin@yourdomain.com
INIT_SEAFILE_ADMIN_PASSWORD=your_secure_admin_password

# Your domain
SEAFILE_SERVER_HOSTNAME=seafile.shojinas.home.shoji.me

# Tailscale configuration (optional - see Tailscale Integration section)
# To disable Tailscale: Set TAILSCALE_AUTHKEY to empty or stop container in Portainer
TAILSCALE_AUTHKEY=tskey-auth-your-key-here
TAILSCALE_HOSTNAME=seafile
```

### 3. (Optional) Tailscale Integration

If you want to expose Seafile on your Tailscale network (tailnet):

1. **Get a Tailscale auth key:**
   - Go to https://login.tailscale.com/admin/settings/keys
   - Generate a new auth key
   - Recommended settings: Enable "Reusable" and "Ephemeral"
   
2. **Update .env file:**
   ```bash
   TAILSCALE_AUTHKEY=tskey-auth-xxxxxxxxxxxxx
   TAILSCALE_HOSTNAME=seafile
   ```

3. **Create Tailscale state directory:**
   ```bash
   sudo mkdir -p /volume1/docker/seafile/tailscale
   sudo chown -R 1027:100 /volume1/docker/seafile/tailscale
   ```

The Seafile container will now be accessible on your tailnet at the hostname you specified (e.g., `http://seafile`).

### 4. Create Volume Directories

```bash
# Create the directories for persistent data
sudo mkdir -p /volume1/docker/seafile/seafile-data
sudo mkdir -p /volume1/docker/seafile/mysql
sudo mkdir -p /volume1/docker/seafile/elasticsearch

# Set permissions (adjust PUID/PGID to match your .env)
sudo chown -R 1027:100 /volume1/docker/seafile/
```

### 5. Start Services

```bash
docker compose up -d
```

**For Portainer users:** Simply create a new stack from this repository and configure the environment variables in the Portainer UI.

### 6. Monitor Startup

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

### 7. Access Seafile

Once started, access Seafile at:
- **Via Traefik (HTTPS):** https://seafile.shojinas.home.shoji.me (or your configured hostname)
- **Via Tailscale (if enabled):** http://seafile (or your configured Tailscale hostname)

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
sudo tail -f $(find /volume1/docker/seafile/seafile-data/ -type f -name '*.log' 2>/dev/null)
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

## Tailscale Management

### Check Tailscale Status

```bash
# View Tailscale status
docker exec seafile-tailscale tailscale status

# View Tailscale IP address
docker exec seafile-tailscale tailscale ip
```

### Disable/Enable Tailscale

**Via Portainer:**
- Navigate to Containers
- Find `seafile-tailscale`
- Click Stop/Start to disable/enable

**Via Docker Compose:**
```bash
# Stop Tailscale
docker compose stop tailscale

# Start Tailscale
docker compose start tailscale

# Or remove the auth key from .env and restart
```

**To permanently disable:** Remove or comment out the `tailscale` service from `docker-compose.yml`.

### Tailscale Logs

```bash
docker compose logs -f tailscale
```

## Configuration

### How Tailscale Integration Works

This setup uses the official Tailscale container (`ghcr.io/tailscale/tailscale`) as a sidecar that shares the network namespace with the Seafile container. This means:

1. **The Tailscale container runs alongside Seafile** and handles all VPN connectivity
2. **Seafile is accessible on your tailnet** at the hostname you specify (e.g., `http://seafile`)
3. **No custom Dockerfile needed** - uses official images for both Seafile and Tailscale
4. **Network namespace sharing** - Tailscale and Seafile share the same network stack
5. **Works alongside Traefik** - You can access Seafile both via Traefik (public/HTTPS) and Tailscale (private/tailnet)

The Tailscale container requires:
- `CAP_ADD: NET_ADMIN, SYS_MODULE` - for VPN networking
- `/dev/net/tun` device access - for tunnel interface
- Persistent state directory - to maintain connection across restarts

### Traefik Integration

The docker-compose.yml includes Traefik labels configured for:
- HTTP to HTTPS redirect
- Automatic SSL via your existing Traefik setup
- Domain routing via environment variable

The domain is set via the `SEAFILE_SERVER_HOSTNAME` variable in `.env`. To support multiple domains, you can edit the Traefik labels in `docker-compose.yml`:

```yaml
# Example for multiple domains:
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

### Key Seafile Variables:
- `SEAFILE_SERVER_HOSTNAME` - Your domain name
- `JWT_PRIVATE_KEY` - Random 32+ character string
- `INIT_SEAFILE_MYSQL_ROOT_PASSWORD` - MySQL root password
- `SEAFILE_MYSQL_DB_PASSWORD` - MySQL seafile user password
- `INIT_SEAFILE_ADMIN_EMAIL` - Initial admin email
- `INIT_SEAFILE_ADMIN_PASSWORD` - Initial admin password

### Tailscale Variables:
- `TAILSCALE_AUTHKEY` - Auth key from https://login.tailscale.com/admin/settings/keys
- `TAILSCALE_HOSTNAME` - Hostname for your Seafile container on the tailnet
- `TAILSCALE_EXTRA_ARGS` - Additional Tailscale arguments (e.g., `--accept-routes`)
- `TAILSCALE_STATE_DIR` - Directory to persist Tailscale state

**Note:** To disable Tailscale, simply stop the container in Portainer or via `docker compose stop tailscale`

## References

- [Seafile Manual](https://manual.seafile.com/)
- [Seafile Docker Setup](https://manual.seafile.com/latest/setup/setup_ce_by_docker/)
- [Traefik Documentation](https://doc.traefik.io/traefik/)

## License

See LICENSE file.