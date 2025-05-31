#!/bin/bash

# Ubuntu Manual Backup Script - Chỉ chạy khi người dùng thực thi
# Version: 1.0

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Functions
print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_header() {
    echo -e "${BLUE}===========================================${NC}"
    echo -e "${BLUE}          Ubuntu Manual Backup${NC}"
    echo -e "${BLUE}===========================================${NC}"
}

# Configuration
BACKUP_DIR="/backup"
TIMESTAMP=$(date +%Y%m%d-%H%M%S)
BACKUP_FILE="$BACKUP_DIR/ubuntu-backup-$TIMESTAMP.tar.gz"
LOG_FILE="$BACKUP_DIR/backup-$TIMESTAMP.log"

# Main script starts here
clear
print_header

# Kiểm tra quyền
if [[ $EUID -eq 0 ]]; then
   print_error "Không chạy script này với quyền root. Sử dụng sudo khi cần."
   exit 1
fi

# Hiển thị thông tin
print_status "Backup sẽ được thực hiện thủ công"
print_status "Thời gian: $(date)"
print_status "Người thực hiện: $(whoami)"
print_status "Hostname: $(hostname)"

# Xác nhận từ người dùng
echo ""
print_warning "Bạn có chắc chắn muốn thực hiện backup không?"
print_warning "Quá trình này có thể mất 10-30 phút tùy vào dung lượng dữ liệu."
echo ""
read -p "Nhấn 'y' để tiếp tục hoặc bất kỳ phím nào để hủy: " -n 1 -r
echo ""

if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    print_status "Backup đã được hủy bởi người dùng."
    exit 0
fi

# Kiểm tra dung lượng
print_status "Kiểm tra dung lượng ổ cứng..."
AVAILABLE_SPACE=$(df / | awk 'NR==2{printf "%.0f", $4/1024/1024}')
print_status "Dung lượng còn lại: ${AVAILABLE_SPACE}GB"

if [ $AVAILABLE_SPACE -lt 5 ]; then
    print_error "Không đủ dung lượng! Cần ít nhất 5GB trống."
    exit 1
fi

# Tạo thư mục backup
print_status "Tạo thư mục backup..."
sudo mkdir -p "$BACKUP_DIR"

if [ $? -ne 0 ]; then
    print_error "Không thể tạo thư mục backup!"
    exit 1
fi

# Hiển thị tiến trình
print_status "Bắt đầu backup hệ thống..."
print_status "File backup: $BACKUP_FILE"
print_status "File log: $LOG_FILE"

echo ""
print_warning "=== BACKUP ĐANG THỰC HIỆN ==="
print_warning "Không tắt máy hoặc ngắt kết nối trong quá trình backup!"
echo ""

# Thực hiện backup với progress
sudo tar -cvpzf "$BACKUP_FILE" \
    --exclude=/proc \
    --exclude=/sys \
    --exclude=/dev \
    --exclude=/run \
    --exclude=/tmp \
    --exclude=/mnt \
    --exclude=/media \
    --exclude=/lost+found \
    --exclude=/var/cache \
    --exclude=/var/tmp \
    --exclude=/var/run \
    --exclude=/var/log \
    --exclude=/snap \
    --exclude=/swapfile \
    --exclude=/backup \
    --one-file-system \
    /home \
    /etc \
    /root \
    /var/www \
    /usr/local \
    /opt \
    /srv \
    2>&1 | tee "$LOG_FILE"

# Kiểm tra kết quả
if [ ${PIPESTATUS[0]} -eq 0 ]; then
    BACKUP_SIZE=$(du -h "$BACKUP_FILE" | cut -f1)
    echo ""
    echo -e "${GREEN}===========================================${NC}"
    echo -e "${GREEN}           BACKUP THÀNH CÔNG!${NC}"
    echo -e "${GREEN}===========================================${NC}"
    print_status "File backup: $BACKUP_FILE"
    print_status "Kích thước: $BACKUP_SIZE"
    print_status "Log file: $LOG_FILE"
    print_status "Thời gian hoàn thành: $(date)"
    echo ""
    
    # Tạo script restore
    RESTORE_SCRIPT="$BACKUP_DIR/restore-$(date +%Y%m%d-%H%M%S).sh"
    cat > "$RESTORE_SCRIPT" << 'EOF'
#!/bin/bash
echo "Ubuntu System Restore Script"
echo "Sử dụng: sudo ./restore.sh backup-file.tar.gz"

if [ $# -eq 0 ]; then
    echo "Vui lòng cung cấp file backup làm tham số"
    exit 1
fi

BACKUP_FILE=$1

if [ ! -f "$BACKUP_FILE" ]; then
    echo "Không tìm thấy file backup: $BACKUP_FILE"
    exit 1
fi

echo "Khôi phục từ: $BACKUP_FILE"
echo "CẢNH BÁO: Điều này sẽ ghi đè lên các file hiện có!"
read -p "Tiếp tục? (y/N): " -n 1 -r
echo

if [[ $REPLY =~ ^[Yy]$ ]]; then
    sudo tar -xvpzf "$BACKUP_FILE" -C / --numeric-owner
    echo "Khôi phục hoàn tất!"
    echo "Vui lòng khởi động lại hệ thống: sudo reboot"
else
    echo "Khôi phục đã bị hủy"
fi
EOF

    sudo chmod +x "$RESTORE_SCRIPT"
    print_status "Script khôi phục: $RESTORE_SCRIPT"
    
else
    echo ""
    echo -e "${RED}===========================================${NC}"
    echo -e "${RED}            BACKUP THẤT BẠI!${NC}"
    echo -e "${RED}===========================================${NC}"
    print_error "Kiểm tra file log để biết chi tiết: $LOG_FILE"
    exit 1
fi

echo ""
print_status "Backup hoàn tất! Bạn có thể thoát script bây giờ."
