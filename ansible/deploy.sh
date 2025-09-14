#!/bin/bash

# Script di deploy unificato per homelab
# Autore: Vincenzo Florio
# Data: $(date +%Y-%m-%d)

set -e

# Colori per output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Directory base
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ANSIBLE_CONFIG="$SCRIPT_DIR/ansible.cfg"
INVENTORY="$SCRIPT_DIR/inventory/main.ini"

# Funzione per stampare messaggi colorati
print_msg() {
    local color=$1
    local message=$2
    echo -e "${color}[$(date '+%H:%M:%S')] ${message}${NC}"
}

# Funzione per mostrare l'help
show_help() {
    cat << EOF
Usage: $0 [COMMAND] [OPTIONS]

COMANDI:
    deploy-server <server>              Deploy tutte le app di un server
    deploy-app <server> <app>          Deploy singola app
    deploy-all                         Deploy tutto
    list-servers                       Mostra server disponibili
    list-apps <server>                 Mostra app disponibili per server
    help                              Mostra questo help

OPZIONI:
    -u, --user <username>             Username per connessione SSH (default: vflorio)
    -v, --verbose                     Output verbose
    -n, --dry-run                     Simula senza eseguire

ESEMPI:
    $0 deploy-server srv-prod-0
    $0 deploy-app srv-prod-1 gitea
    $0 deploy-all --user admin
    $0 list-apps srv-prod-1

EOF
}

# Carica configurazioni dei server
load_server_config() {
    local server=$1
    local config_file="$SCRIPT_DIR/configs/${server}.yml"
    
    if [[ ! -f "$config_file" ]]; then
        print_msg $RED "Errore: File di configurazione $config_file non trovato"
        exit 1
    fi
    
    # Legge le app dal file YAML
    apps=$(grep -E "^\s*-\s+" "$config_file" | sed 's/^[[:space:]]*-[[:space:]]*//' | tr '\n' ' ')
    echo "$apps"
}

# Deploy singola app
deploy_app() {
    local server=$1
    local app=$2
    local user=${3:-vflorio}
    local verbose=${4:-false}
    
    print_msg $BLUE "Deploy di $app su $server..."
    
    # Estrae il numero del server (es: srv-prod-0 -> prod-0)
    local server_suffix="${server#srv-}"
    local local_dir="/mnt/c/Data/homelab/next/apps/$app/${app}-${server_suffix}/"
    local remote_dir="~/docker/$app"
    
    # Controlla se la directory locale esiste
    if [[ ! -d "$local_dir" ]]; then
        print_msg $YELLOW "Directory $local_dir non trovata, provo con directory generica..."
        local_dir="/mnt/c/Data/homelab/next/apps/$app/"
        if [[ ! -d "$local_dir" ]]; then
            print_msg $RED "Errore: Directory per $app non trovata"
            return 1
        fi
    fi
    
    local ansible_cmd="ansible-playbook -i $INVENTORY playbooks/update-dockerdeploy.yml"
    ansible_cmd="$ansible_cmd -e \"ansible_user=$user hosts=${server}.intranet.vflorio.com\""
    ansible_cmd="$ansible_cmd -e \"local_project_dir=$local_dir remote_project_dir=$remote_dir\""
    
    if [[ "$verbose" == "true" ]]; then
        ansible_cmd="$ansible_cmd -v"
    fi
    
    print_msg $YELLOW "Eseguendo: $ansible_cmd"
    
    if [[ "$DRY_RUN" != "true" ]]; then
        eval "ANSIBLE_CONFIG=$ANSIBLE_CONFIG $ansible_cmd"
        if [[ $? -eq 0 ]]; then
            print_msg $GREEN "✓ Deploy di $app completato con successo"
        else
            print_msg $RED "✗ Errore nel deploy di $app"
            return 1
        fi
    else
        print_msg $YELLOW "DRY RUN: Comando non eseguito"
    fi
}

# Deploy tutte le app di un server
deploy_server() {
    local server=$1
    local user=${2:-vflorio}
    local verbose=${3:-false}
    
    print_msg $BLUE "Deploy completo del server $server..."
    
    local apps=$(load_server_config "$server")
    
    print_msg $YELLOW "App da deployare: $apps"
    
    for app in $apps; do
        deploy_app "$server" "$app" "$user" "$verbose"
        if [[ $? -ne 0 ]]; then
            print_msg $RED "Errore nel deploy di $app, interrompo il deploy del server"
            return 1
        fi
        sleep 2 # Piccola pausa tra i deploy
    done
    
    print_msg $GREEN "✓ Deploy completo del server $server terminato"
}

# Deploy di tutti i server
deploy_all() {
    local user=${1:-vflorio}
    local verbose=${2:-false}
    
    print_msg $BLUE "Deploy di tutti i server..."
    
    for server in srv-prod-0 srv-prod-1; do
        deploy_server "$server" "$user" "$verbose"
        if [[ $? -ne 0 ]]; then
            print_msg $RED "Errore nel deploy del server $server"
            return 1
        fi
    done
    
    print_msg $GREEN "✓ Deploy completo di tutti i server terminato"
}

# Lista server disponibili
list_servers() {
    print_msg $BLUE "Server disponibili:"
    for config in "$SCRIPT_DIR/configs"/*.yml; do
        if [[ -f "$config" ]]; then
            server=$(basename "$config" .yml)
            echo "  - $server"
        fi
    done
}

# Lista app di un server
list_apps() {
    local server=$1
    local apps=$(load_server_config "$server")
    
    print_msg $BLUE "App disponibili per $server:"
    for app in $apps; do
        echo "  - $app"
    done
}

# Parsing argomenti
USER="vflorio"
VERBOSE=false
DRY_RUN=false

while [[ $# -gt 0 ]]; do
    case $1 in
        -u|--user)
            USER="$2"
            shift 2
            ;;
        -v|--verbose)
            VERBOSE=true
            shift
            ;;
        -n|--dry-run)
            DRY_RUN=true
            shift
            ;;
        deploy-server)
            COMMAND="deploy-server"
            SERVER="$2"
            shift 2
            ;;
        deploy-app)
            COMMAND="deploy-app"
            SERVER="$2"
            APP="$3"
            shift 3
            ;;
        deploy-all)
            COMMAND="deploy-all"
            shift
            ;;
        list-servers)
            COMMAND="list-servers"
            shift
            ;;
        list-apps)
            COMMAND="list-apps"
            SERVER="$2"
            shift 2
            ;;
        help|--help|-h)
            show_help
            exit 0
            ;;
        *)
            print_msg $RED "Opzione sconosciuta: $1"
            show_help
            exit 1
            ;;
    esac
done

# Esecuzione comandi
case $COMMAND in
    deploy-server)
        if [[ -z "$SERVER" ]]; then
            print_msg $RED "Errore: Server non specificato"
            show_help
            exit 1
        fi
        deploy_server "$SERVER" "$USER" "$VERBOSE"
        ;;
    deploy-app)
        if [[ -z "$SERVER" || -z "$APP" ]]; then
            print_msg $RED "Errore: Server e/o app non specificati"
            show_help
            exit 1
        fi
        deploy_app "$SERVER" "$APP" "$USER" "$VERBOSE"
        ;;
    deploy-all)
        deploy_all "$USER" "$VERBOSE"
        ;;
    list-servers)
        list_servers
        ;;
    list-apps)
        if [[ -z "$SERVER" ]]; then
            print_msg $RED "Errore: Server non specificato"
            show_help
            exit 1
        fi
        list_apps "$SERVER"
        ;;
    *)
        print_msg $RED "Comando non specificato"
        show_help
        exit 1
        ;;
esac