#!/bin/bash

#################################################################################
# MediaStack Deployment Script
# 
# This script deploys Docker and MediaStack services using Ansible
# It handles the installation of Docker and deployment of gateway, management,
# and media servers with proper configuration management.
#
# Usage: ./deploy-mediastack.sh [options]
# 
# Author: HomeLab Infrastructure Team
# Date: $(date +%Y-%m-%d)
#################################################################################

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m' # No Color

# Configuration
INVENTORY_FILE="inventory/main.ini"
PLAYBOOK="playbooks/deploy-mediastack.yml"
LOG_DIR="logs"
LOG_FILE="$LOG_DIR/deploy-mediastack-$(date +%Y%m%d-%H%M%S).log"

# Default values
TARGET_HOST="servers"
VERBOSE=""
CHECK_MODE=""

# Functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1" | tee -a "$LOG_FILE"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1" | tee -a "$LOG_FILE"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1" | tee -a "$LOG_FILE"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1" | tee -a "$LOG_FILE"
}

log_header() {
    echo -e "${CYAN}${BOLD}================================${NC}" | tee -a "$LOG_FILE"
    echo -e "${CYAN}${BOLD} $1${NC}" | tee -a "$LOG_FILE"
    echo -e "${CYAN}${BOLD}================================${NC}" | tee -a "$LOG_FILE"
}

show_help() {
    cat << EOF
${BOLD}MediaStack Deployment Script${NC}

${BOLD}USAGE:${NC}
    $0 [options]

${BOLD}OPTIONS:${NC}
    -h, --host HOST           Target specific host (gateway, management, media, or servers)
    -v, --verbose             Enable verbose output
    --check                   Run in check mode (dry run)
    --list-hosts              List target hosts and exit
    --help                    Show this help message

${BOLD}EXAMPLES:${NC}
    $0                        Deploy to all MediaStack servers
    $0 -h gateway             Deploy only to gateway server
    $0 -h management          Deploy only to management server
    $0 -h media               Deploy only to media server
    $0 --check -v             Dry run with verbose output

${BOLD}NOTES:${NC}
    - This script deploys to: gateway, management, media servers
    - .env files will be backed up before any changes
    - Manual start.sh execution is required after deployment

EOF
}

# Validate environment
validate_environment() {
    log_info "Validating deployment environment..."
    
    # Check if running from ansible directory
    if [[ ! -f "ansible.cfg" ]]; then
        log_error "This script must be run from the ansible directory"
        exit 1
    fi

    # Check if inventory file exists
    if [[ ! -f "$INVENTORY_FILE" ]]; then
        log_error "Inventory file not found: $INVENTORY_FILE"
        exit 1
    fi

    # Check if playbook exists
    if [[ ! -f "$PLAYBOOK" ]]; then
        log_error "Playbook not found: $PLAYBOOK"
        exit 1
    fi

    # Check if servers directory exists
    if [[ ! -d "../servers" ]]; then
        log_error "Servers directory not found: ../servers"
        exit 1
    fi

    # Create log directory
    mkdir -p "$LOG_DIR"

    # Check ansible installation
    if ! command -v ansible-playbook &> /dev/null; then
        log_error "ansible-playbook command not found. Please install Ansible."
        exit 1
    fi

    log_success "Environment validation completed"
}

# Parse command line arguments
parse_arguments() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            -h|--host)
                TARGET_HOST="$2"
                shift 2
                ;;
            -v|--verbose)
                VERBOSE="-v"
                shift
                ;;
            --check)
                CHECK_MODE="--check"
                shift
                ;;
            --list-hosts)
                ansible-playbook -i "$INVENTORY_FILE" "$PLAYBOOK" --list-hosts --limit "$TARGET_HOST"
                exit 0
                ;;
            --help)
                show_help
                exit 0
                ;;
            *)
                log_error "Unknown option: $1"
                echo "Use --help for usage information"
                exit 1
                ;;
        esac
    done
}

# Pre-deployment checks
pre_deployment_checks() {
    log_info "Running pre-deployment checks..."
    
    # Skip dev server for now
    local target_for_ping="$TARGET_HOST"
    if [[ "$TARGET_HOST" == "servers" ]]; then
        target_for_ping="servers:!dev.intranet.vflorio.com"
    fi
    
    # Test connectivity to target hosts
    log_info "Testing connectivity to target hosts..."
    if ! ansible -i "$INVENTORY_FILE" "$target_for_ping" -m ping &>> "$LOG_FILE"; then
        log_error "Unable to connect to target hosts. Check your inventory and SSH configuration."
        exit 1
    fi
    
    log_success "Pre-deployment checks completed"
}

# Run the deployment
run_deployment() {
    log_header "Starting MediaStack Deployment"
    log_info "Target: $TARGET_HOST"
    log_info "Playbook: $PLAYBOOK"
    log_info "Log file: $LOG_FILE"
    
    # Skip dev server for now
    local target_for_deploy="$TARGET_HOST"
    if [[ "$TARGET_HOST" == "servers" ]]; then
        target_for_deploy="servers:!dev.intranet.vflorio.com"
    fi
    
    # Build ansible-playbook command
    local cmd="ansible-playbook -i $INVENTORY_FILE $PLAYBOOK --limit $target_for_deploy"
    
    if [[ -n "$VERBOSE" ]]; then
        cmd="$cmd $VERBOSE"
    fi
    
    if [[ -n "$CHECK_MODE" ]]; then
        cmd="$cmd $CHECK_MODE"
        log_warning "Running in CHECK MODE (dry run)"
    fi
    
    log_info "Executing: $cmd"
    
    # Execute the deployment
    if eval "$cmd" 2>&1 | tee -a "$LOG_FILE"; then
        log_success "MediaStack deployment completed successfully!"
        return 0
    else
        log_error "Deployment failed! Check the log file for details: $LOG_FILE"
        return 1
    fi
}

# Post-deployment summary
post_deployment_summary() {
    log_header "Deployment Summary"
    
    cat << EOF | tee -a "$LOG_FILE"

${GREEN}✓ Docker installed and configured${NC}
${GREEN}✓ MediaStack services deployed${NC}
${GREEN}✓ Docker networks created${NC}
${GREEN}✓ File permissions set${NC}
${GREEN}✓ Environment files prepared${NC}

${YELLOW}NEXT STEPS:${NC}
${CYAN}1.${NC} SSH to your server(s)
${CYAN}2.${NC} Review and configure .env files in:
   - /opt/mediastack/gateway/.env
   - /opt/mediastack/management/.env
   - /opt/mediastack/media/.env

${CYAN}3.${NC} Start services manually:
   ${BOLD}cd /opt/mediastack/gateway && ./start.sh${NC}
   ${BOLD}cd /opt/mediastack/management && ./start.sh${NC}
   ${BOLD}cd /opt/mediastack/media && ./start.sh${NC}

${CYAN}4.${NC} Monitor logs and verify services are running correctly

${YELLOW}IMPORTANT:${NC} 
- .env files have been backed up before deployment
- Check /opt/mediastack/DEPLOYMENT_SUMMARY.txt on target servers
- All start.sh scripts must be executed manually via SSH

${BLUE}Deployment log saved to: ${BOLD}$LOG_FILE${NC}

EOF
}

# Cleanup function
cleanup() {
    local exit_code=$?
    if [[ $exit_code -ne 0 ]]; then
        log_error "Deployment script exited with error code: $exit_code"
        log_info "Check the log file for details: $LOG_FILE"
    fi
}

# Main execution
main() {
    # Set up error handling
    trap cleanup EXIT
    
    # Initialize log file
    echo "MediaStack Deployment Log - $(date)" > "$LOG_FILE"
    echo "========================================" >> "$LOG_FILE"
    
    # Parse arguments
    parse_arguments "$@"
    
    # Validate environment
    validate_environment
    
    # Run pre-deployment checks
    pre_deployment_checks
    
    # Run deployment
    if run_deployment; then
        post_deployment_summary
        exit 0
    else
        log_error "Deployment failed!"
        exit 1
    fi
}

# Execute main function with all arguments
main "$@"