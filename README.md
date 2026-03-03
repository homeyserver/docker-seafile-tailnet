# Self-Hosted Seafile Server with Tailscale

This is basically the boierlplate provided by Seafile for generic linux server but replaces caddy reverse proxy with tailscale. 

## 1 Setting up Seafile Server
- See docs for configuration https://manual.seafile.com/latest/setup/setup_ce_by_docker/#download-and-modify-env
- Download from seafile manual the base env file
```sh
wget -O .env https://manual.seafile.com/13.0/repo/docker/ce/env
```

## 2 Tailscale Auth
- Create new machine and get an authkey https://login.tailscale.com/admin/machines/new-linux
- Add is to the bottom of your .env file like

```sh
## Tailscale
TS_AUTHKEY=tskey-auth-XXXXXXXXX-XXXXXXXXXXXXXXXXXXXXX
```

**Tailscale Support**
- Only tailnet connected devices will be able to reach your seafile server.
- supports [tailscale-servee](https://tailscale.com/docs/features/tailscale-serve)
- TODO: Support tailscale-funnel https://tailscale.com/docs/features/tailscale-funnel

## 3 Start Servers

```sh
docker compose up -d
```

## 4 Approve in Tailnet
- Approve New Machine in your Tailnet https://login.tailscale.com/admin/machines
