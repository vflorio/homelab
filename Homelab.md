
# HomeLab Infrastructure Documentation

## Network & Devices

### Devices

| Dispositivo | Alias | IP | Descrizione |
|---|---|---|---|
| server | silicon | 192.168.1.1 | Server fisico principale |
| workstation | carbon | 192.168.1.2 | Workstation principale |
| macmini | nitrogen | 192.168.1.3 | Mac Mini |
| tablet-android | boron | 192.168.1.4 | Tablet Android |
| smartphone-ios | phosphorus | 192.168.1.5 | iPhone |
| tv-hisense | sulfur | 192.168.1.6 | Smart TV |
| tv-android | chlorine | 192.168.1.7 | Smart TV |
| laptop-discovery | argon | 192.168.1.8 | Laptop Discovery |
| laptop-kineton | neon | 192.168.1.9 | Laptop Kineton |
| iliadbox | iliadbox | 192.168.1.254 | Gateway principale |

### Network

- **192.168.1.1-32**: Dispositivi fisici primari (range espanso)
- **192.168.1.33-40**: Mini PC ActivaStick
- **192.168.1.150-152**: Servizi di infrastruttura
- **192.168.1.170-173**: Server di produzione
- **192.168.1.180-183**: Server di demo/test
- **192.168.1.254**: Gateway Iliad Box

### DNS Records

| IP | Nome DNS | Alias DNS | Categoria | Descrizione |
|---|---|---|---|---|
| **DISPOSITIVI FISICI** |
| 192.168.1.1 | server | silicon | Hardware | Server fisico principale |
| 192.168.1.2 | workstation | carbon | Hardware | Workstation principale |
| 192.168.1.3 | macmini | nitrogen | Hardware | Mac Mini |
| 192.168.1.4 | tablet-android | boron | Hardware | Tablet Android |
| 192.168.1.5 | smartphone-ios | phosphorus | Hardware | iPhone |
| 192.168.1.6 | tv-hisense | sulfur | Hardware | Smart TV Hisense |
| 192.168.1.7 | tv-android | chlorine | Hardware | Smart TV Android |
| 192.168.1.8 | laptop-discovery | argon | Hardware | Laptop Discovery |
| 192.168.1.9 | laptop-kineton | neon | Hardware | Laptop Kineton |
| 192.168.1.254 | iliadbox | - | Gateway | Gateway principale |
| **SERVIZI INFRASTRUTTURA** |
| 192.168.1.150 | dns | - | Infrastruttura | Server DNS Bind9 |
| 192.168.1.151 | nas | - | Infrastruttura | Network Attached Storage |
| 192.168.1.152 | firewall | - | Infrastruttura | Firewall/Gateway |
| **MINI PC ACTIVASTICK** |
| 192.168.1.33 | activastick-0 | - | ActivaStick | Mini PC #0 *.activastick-0 |
| 192.168.1.34 | activastick-1 | - | ActivaStick | Mini PC #1 *.activastick-1 |
| 192.168.1.35 | activastick-2 | - | ActivaStick | Mini PC #2 *.activastick-2 |
| 192.168.1.36 | activastick-3 | - | ActivaStick | Mini PC #3 *.activastick-3 |
| 192.168.1.37 | activastick-4 | - | ActivaStick | Mini PC #4 *.activastick-4 |
| 192.168.1.38 | activastick-5 | - | ActivaStick | Mini PC #5 *.activastick-5 |
| 192.168.1.39 | activastick-6 | - | ActivaStick | Mini PC #6 *.activastick-6 |
| 192.168.1.40 | activastick-7 | - | ActivaStick | Mini PC #7 *.activastick-7 |
| **SERVER PRODUZIONE** |
| 192.168.1.170 | srv-prod-0 | - | Produzione | Server Prod #0 *.srv-prod-0 |
| 192.168.1.171 | srv-prod-1 | - | Produzione | Server Prod #1 *.srv-prod-1 |
| 192.168.1.172 | srv-prod-2 | - | Produzione | Server Prod #2 *.srv-prod-2 |
| 192.168.1.173 | srv-prod-3 | - | Produzione | Server Prod #3 *.srv-prod-3 |
| **SERVER DEMO/TEST** |
| 192.168.1.180 | srv-demo-0 | - | Demo | Server Demo #0 *.srv-demo-0 |
| 192.168.1.181 | srv-demo-1 | - | Demo | Server Demo #1 *.srv-demo-1 |
| 192.168.1.182 | srv-demo-2 | - | Demo | Server Demo #2 *.srv-demo-2 |
| 192.168.1.183 | srv-demo-3 | - | Demo | Server Demo #3 *.srv-demo-3 |


## Virtual Machines

### VM Infrastructure

| VM ID | Nome | IP | Progetto | Descrizione |
|---|---|---|---|---|
| 1010 | dns | 192.168.1.150 | DNS Resolution | Server DNS Bind9 per risoluzione intranet |
| 1020 | nas | 192.168.1.151 | Storage | HomeLab NAS (OpenMediaVault) |
| 1030 | firewall | 192.168.1.152 | Security | HomeLab Firewall (OpnSense) |
| 2100 | srv-prod-0 | 192.168.1.170 | Produzione | Admin Management Server |
| 2101 | srv-prod-1 | 192.168.1.171 | Produzione | User Applications Server |
| 2200 | srv-demo-0 | 192.168.1.180 | Demo | Admin Management Demo Server |
| 2201 | srv-demo-1 | 192.168.1.181 | Demo | User Applications Demo Server |

## Progetti

### Intranet Custom DNS Resolution
- **Server**: 192.168.1.150 (VM ID: 1010)
- **Servizio**: Bind9 instance
- **Scopo**: Risoluzione DNS personalizzata per la rete intranet

## TODOs

### Base Server Components

- [ ] **Traefik** - Reverse proxy e load balancer
- [ ] **Authentik** - Sistema di autenticazione centralizzato
- [ ] **Prometheus** - Sistema di monitoring

### Prod 0 (Management Server)

- [ ] **Semaphore UI** - Interface di gestione Ansible
- [ ] **Portainer** - Gestione container Docker
- [ ] **Pi Hole** - DNS-level ad blocking
- [ ] **Tailscale** - VPN mesh networking
- [ ] **Grafana** - Dashboard e visualizzazione metriche

### Prod 1 (User Applications)
- [ ] **Gitea** - Git repository server
- [ ] **Container Registry** - TODO: Desc
- [ ] **Verdaccio** - TODO: Desc
- [ ] **Jellyfin** - TODO: Desc
- [ ] **Passbolt** - Password manager
- [ ] **Code Server** - VS Code nel browser
- [ ] **Nextcloud** - Cloud storage e collaboration
- [ ] **Penpot** - Design collaboration tool
- [ ] **Excalidraw** - TODO: Desc
- [ ] **OnlyOffice** - Suite ufficio online
- [ ] **Portainer Agent** - Agent per gestione remota

### Progetti Futuri

- [ ] **Class A Private Network** - Espansione della rete
- [ ] **VPN / Remote Access** - Implementazione con twingate/teleport/tailscale
---
