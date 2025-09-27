#!/bin/bash

set -e  # Exit on any error

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
NAS_SERVER="nas.intranet.vflorio.com"
SMB_USER="vflorio"
SMB_PASS="7W8jfoCb#"
CREDENTIALS_FILE="/etc/samba/credentials"
MOUNT_BASE="/mnt/nas"

# Share names (adjust these to match your OMV shares)
declare -a SHARES=("media-0" "media-1" "media-2")

# Logging function
log() {
    echo -e "${BLUE}[$(date '+%Y-%m-%d %H:%M:%S')] $1${NC}"
}

error() {
    echo -e "${RED}[ERROR] $1${NC}" >&2
}

success() {
    echo -e "${GREEN}[SUCCESS] $1${NC}"
}

warning() {
    echo -e "${YELLOW}[WARNING] $1${NC}"
}

# Check if running as root
check_root() {
    if [[ $EUID -ne 0 ]]; then
        error "This script must be run as root (use sudo)"
        exit 1
    fi
}

# Install required packages
install_packages() {
    log "Installing required packages..."
    
    # Update package list
    apt-get update -qq
    
    # Install CIFS utilities and Samba common
    apt-get install -y cifs-utils samba-common-bin smbclient
    
    success "Packages installed successfully"
}

# Create credentials file
create_credentials() {
    log "Creating SMB credentials file..."
    
    # Create samba directory if it doesn't exist
    mkdir -p /etc/samba
    
    # Create credentials file
    cat > "$CREDENTIALS_FILE" <<EOF
username=$SMB_USER
password=$SMB_PASS
EOF
    
    # Set secure permissions
    chmod 600 "$CREDENTIALS_FILE"
    chown root:root "$CREDENTIALS_FILE"
    
    success "Credentials file created at $CREDENTIALS_FILE"
}

# Test SMB connection
test_smb_connection() {
    log "Testing SMB connection to $NAS_SERVER..."
    
    if smbclient -L "//$NAS_SERVER" -U "$SMB_USER%$SMB_PASS" >/dev/null 2>&1; then
        success "SMB connection test successful"
        return 0
    else
        error "SMB connection test failed"
        return 1
    fi
}

# Create mount points
create_mount_points() {
    log "Creating mount points..."
    
    mkdir -p "$MOUNT_BASE"
    
    for share in "${SHARES[@]}"; do
        local mount_point="$MOUNT_BASE/$share"
        mkdir -p "$mount_point"
        log "Created mount point: $mount_point"
    done
    
    success "Mount points created"
}

# Mount shares with retry logic
mount_share() {
    local share="$1"
    local mount_point="$MOUNT_BASE/$share"
    local max_attempts=3
    local attempt=1
    
    while [ $attempt -le $max_attempts ]; do
        log "Mounting $share (attempt $attempt/$max_attempts)..."
        
        if mount -t cifs "//$NAS_SERVER/$share" "$mount_point" \
            -o credentials="$CREDENTIALS_FILE",uid=1000,gid=1000,iocharset=utf8,file_mode=0664,dir_mode=0775,vers=3.0; then
            success "Successfully mounted $share to $mount_point"
            return 0
        else
            warning "Failed to mount $share (attempt $attempt/$max_attempts)"
            sleep 2
            ((attempt++))
        fi
    done
    
    error "Failed to mount $share after $max_attempts attempts"
    return 1
}

# Mount all shares
mount_all_shares() {
    log "Mounting SMB shares..."
    
    local failed_mounts=0
    
    for share in "${SHARES[@]}"; do
        if ! mount_share "$share"; then
            ((failed_mounts++))
        fi
    done
    
    if [ $failed_mounts -eq 0 ]; then
        success "All shares mounted successfully"
        return 0
    else
        error "$failed_mounts shares failed to mount"
        return 1
    fi
}

# Add entries to fstab for persistence
add_to_fstab() {
    log "Adding entries to /etc/fstab for persistence..."
    
    # Backup fstab
    cp /etc/fstab /etc/fstab.backup.$(date +%Y%m%d_%H%M%S)
    
    # Remove any existing entries for our NAS
    sed -i "/$NAS_SERVER/d" /etc/fstab
    
    # Add comment
    echo "" >> /etc/fstab
    echo "# SMB shares from OMV NAS - Added by setup-smb-mounts.sh" >> /etc/fstab
    
    # Add entries for each share
    for share in "${SHARES[@]}"; do
        local mount_point="$MOUNT_BASE/$share"
        echo "//$NAS_SERVER/$share $mount_point cifs credentials=$CREDENTIALS_FILE,uid=1000,gid=1000,iocharset=utf8,file_mode=0664,dir_mode=0775,vers=3.0,_netdev 0 0" >> /etc/fstab
        log "Added fstab entry for $share"
    done
    
    success "fstab entries added successfully"
}

# Verify mounts
verify_mounts() {
    log "Verifying mounted shares..."
    
    local all_mounted=true
    
    for share in "${SHARES[@]}"; do
        local mount_point="$MOUNT_BASE/$share"
        if mountpoint -q "$mount_point"; then
            success "$share is properly mounted at $mount_point"
            
            # Test write access
            if touch "$mount_point/.test_write" 2>/dev/null && rm "$mount_point/.test_write" 2>/dev/null; then
                log "Write access confirmed for $share"
            else
                warning "Write access test failed for $share"
            fi
        else
            error "$share is NOT mounted at $mount_point"
            all_mounted=false
        fi
    done
    
    return $all_mounted
}

# Show mount information
show_mount_info() {
    log "Current SMB mount information:"
    echo ""
    df -h | grep "$NAS_SERVER" || echo "No SMB mounts found in df output"
    echo ""
    mount | grep cifs || echo "No CIFS mounts found in mount output"
    echo ""
}

# Create systemd service for auto-mounting
create_systemd_service() {
    log "Creating systemd service for auto-mounting..."
    
    cat > /etc/systemd/system/smb-automount.service <<EOF
[Unit]
Description=Auto-mount SMB shares from NAS
After=network-online.target
Wants=network-online.target
RequiresMountsFor=$MOUNT_BASE

[Service]
Type=oneshot
RemainAfterExit=yes
ExecStart=/bin/bash -c 'sleep 10 && mount -a -t cifs'
ExecStop=/bin/bash -c 'umount $MOUNT_BASE/* 2>/dev/null || true'
TimeoutStartSec=30

[Install]
WantedBy=multi-user.target
EOF
    
    # Enable the service
    systemctl daemon-reload
    systemctl enable smb-automount.service
    
    success "Systemd service created and enabled"
}

# Main execution
main() {
    echo ""
    log "Starting SMB Mount Setup for HomeLab Media Server"
    echo ""
    
    # Check if running as root
    check_root
    
    # Install packages
    install_packages
    
    # Create credentials
    create_credentials
    
    # Test connection
    if ! test_smb_connection; then
        error "Cannot connect to SMB server. Please check:"
        echo "  - Server is reachable: $NAS_SERVER"
        echo "  - Credentials are correct: $SMB_USER"
        echo "  - SMB service is running on the server"
        exit 1
    fi
    
    # Create mount points
    create_mount_points
    
    # Mount shares
    if mount_all_shares; then
        # Add to fstab for persistence
        add_to_fstab
        
        # Create systemd service
        create_systemd_service
        
        # Verify everything is working
        verify_mounts
        
        # Show final information
        show_mount_info
        
        echo ""
        success "SMB mount setup completed successfully!"
        echo ""
        log "Mounted shares:"
        for share in "${SHARES[@]}"; do
            echo "  - //$NAS_SERVER/$share -> $MOUNT_BASE/$share"
        done
        echo ""
        log "To manually remount all shares: sudo mount -a -t cifs"
        log "To check service status: sudo systemctl status smb-automount.service"
        echo ""
    else
        error "Some shares failed to mount. Please check the logs above."
        exit 1
    fi
}

# Run main function
main "$@"