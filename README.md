## Tailscale Setup
- Create new machine and get an authkey https://login.tailscale.com/admin/machines/new-linux


## Setup Seafile
- See docs for configuration https://manual.seafile.com/latest/setup/setup_ce_by_docker/#download-and-modify-env
- 
```sh
wget -O .env https://manual.seafile.com/13.0/repo/docker/ce/env
```

## Start Servers

```sh
docker compose up -d
```

## Approve in Tailnet
- Approve New Machine in your Tailnet https://login.tailscale.com/admin/machines
