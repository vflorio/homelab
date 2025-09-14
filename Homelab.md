
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

## Storage Architecture

### Physical Storage Configuration

Il server fisico principale (**silicon** - 192.168.1.1) gestisce lo storage attraverso una configurazione multi-tier:

#### Primary Storage - NVMe
- **Dispositivo**: NVMe SSD 1TB
- **Utilizzo**: Hypervisor e Virtual Machines
- **Scopo**: Storage ad alte prestazioni per:
  - Sistema operativo Proxmox VE
  - VM disk images (thin provisioning)
  - VM snapshots e backup locali
  - Swap e cache del sistema

#### OpenMediaVault (OMV) Pool
La gestione dei dati è centralizzata tramite **OpenMediaVault** su VM dedicata (nas - 192.168.1.151):

##### SSD Pool - Application Data
- **Dispositivo**: SSD (capacità variabile)
- **Accesso**: Mount locale OMV + condivisione Samba
- **Utilizzo**: Dati delle applicazioni Docker
- **Contenuto**:
  - Dati applicativi (npm store, container-registry, etc) 
  - Configuration files e segreti
  - Log files applicativi
  - Archivio documenti e foto famiglia
  - Storage per Nextcloud files

##### HDD Pool - Media Storage
- **Dispositivi**: 3x HDD SMR (Shingled Magnetic Recording)
- **Configurazione**: JBOD (Just a Bunch Of Disks) - dischi indipendenti
- **Accesso**: Condivisioni Samba da OMV (\\192.168.1.151\shares)
- **Utilizzo**: Media server e archivio a lungo termine
- **Contenuto**:
  - Libreria multimediale Jellyfin (film, serie TV)


### Storage Integration

#### Samba Mount Configuration
Gli storage OMV vengono montati sui server applicativi tramite Samba/CIFS:

```bash
# Mount automatico tramite /etc/fstab sui server Docker
//192.168.1.151/app-data /mnt/ssd-data cifs credentials=/etc/samba/nas-creds,uid=1000,gid=1000,iocharset=utf8 0 0
//192.168.1.151/media-library /mnt/hdd-media cifs credentials=/etc/samba/nas-creds,uid=1000,gid=1000,iocharset=utf8 0 0
//192.168.1.151/backups /mnt/hdd-backups cifs credentials=/etc/samba/nas-creds,uid=1000,gid=1000,iocharset=utf8 0 0
```

#### Docker Volume Management
```yaml
# Configurazione volumi per applicazioni
volumes:
  # Dati critici su SSD (tramite Samba)
  app_database:
    driver: local
    driver_opts:
      type: cifs
      o: "username=${NAS_USER},password=${NAS_PASS},vers=3.0"
      device: "//192.168.1.151/app-data/databases"
  
  # Media su HDD JBOD (tramite Samba)
  jellyfin_media:
    driver: local
    driver_opts:
      type: cifs
      o: "username=${NAS_USER},password=${NAS_PASS},vers=3.0"
      device: "//192.168.1.151/media-library/jellyfin"
```

#### Backup Strategy per SMR Drives
- **VM Snapshots**: Quotidiani su NVMe (retention: 7 giorni)
- **VM Backup**: Settimanali su HDD JBOD via Samba (retention: 4 settimane)
- **Application Data**: Backup incrementali SSD → HDD tramite rsync over Samba
- **Media Archive**: JBOD con backup esterni mensili (nessuna ridondanza RAID)

#### Performance Considerations per SMR
- **SMR Drives**: Ottimizzati per scritture sequenziali grandi (>1MB)
- **JBOD Benefits**: Nessun overhead RAID, gestione flessibile per drive failure
- **Samba Tuning**: SMB3 con multichannel per throughput ottimale
- **Write Patterns**: Jellyfin streaming (read-heavy) ideale per SMR
- **Backup Windows**: Scritture batch notturne per evitare interferenze SMR

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
- [ ] **VaultWarden** - Password manager
- [ ] **Code Server** - VS Code nel browser
- [ ] **Nextcloud** - Cloud storage e collaboration
- [ ] **Excalidraw** - TODO: Desc
- [ ] **OnlyOffice** - Suite ufficio online
- [ ] **Portainer Agent** - Agent per gestione remota

### Progetti Futuri

- [ ] **Class A Private Network** - Espansione della rete
- [ ] **VPN / Remote Access** - Implementazione con twingate/teleport/tailscale
---