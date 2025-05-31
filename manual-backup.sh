#!/bin/bash

# Ubuntu On-Demand Backup Script
# CHỈ CHẠY KHI NGƯỜI DÙNG GỌI - KHÔNG TỰ ĐỘNG
# Version: 2.0

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

# Functions
print_status() {
    echo -e "${GREEN}✓ [INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}⚠ [WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}✗ [ERROR]${NC} $1"
}

print_header() {
    echo -e "${CYAN}================================================${NC}"
    echo -e "${CYAN}          UBUNTU ON-DEMAND BACKUP${NC}"
    echo -e "${CYAN}        (Chỉ chạy khi được gọi)${NC}"
    echo -e "${CYAN}================================================${NC}"
}

print_important() {
    echo -e "${BLUE}ℹ [IMPORTANT]${NC} $1"
}

# Configuration
BACKUP_DIR="/backup"
TIMESTAMP=$(date +%Y%m%d-%H%M%S)
BACKUP_FILE="$BACKUP_DIR/manual-backup-$TIMESTAMP.tar.gz"
LOG_FILE="$BACKUP_DIR/backup-log-$TIMESTAMP.txt"
INFO_FILE="$BACKUP_DIR/backup-info-$TIMESTAMP.txt"

# Main script starts here
clear
print_header
echo ""

# Nhấn mạnh đây là backup thủ công
print_important "Script này CHỈ chạy khi bạn gọi thủ công"
print_important "KHÔNG có cron job, KHÔNG có lịch tự động"
print_important "Hoàn toàn kiểm soát bởi người dùng"
echo ""

# Kiểm tra quyền - Cho phép chạy với root
if [[ $EUID -eq 0 ]]; then
   print_status "Đang chạy với quyền root - OK"
   SUDO_PREFIX=""
else
   print_status "Đang chạy với user thường - Sẽ sử dụng sudo khi cần"
   SUDO_PREFIX="sudo"
fi

# Hiển thị thông tin hệ thống
print_status "Thông tin backup session:"
echo "  📅 Thời gian: $(date '+%Y-%m-%d %H:%M:%S')"
echo "  👤 Người thực hiện: $(whoami)"
echo "  🖥️  Hostname: $(hostname)"
echo "  🐧 OS: $(lsb_release -d | cut -f2 2>/dev/null || echo 'Ubuntu')"
echo ""

# Xác nhận QUAN TRỌNG từ người dùng
print_warning "QUAN TRỌNG: Bạn đang chuẩn bị backup toàn bộ hệ thống!"
print_warning "Quá trình này:"
echo "  • Sẽ mất 10-60 phút tùy vào dung lượng dữ liệu"
echo "  • Cần ít nhất 5GB dung lượng trống"
echo "  • Sẽ backup: /home, /etc, /root, /var/www, /usr/local, /opt, /srv"
echo "  • Loại trừ: cache, logs, temp files, system directories"
echo ""


# Kiểm tra dung lượng
print_status "Kiểm tra dung lượng ổ cứng..."
AVAILABLE_SPACE=$(df / | awk 'NR==2{printf "%.1f", $4/1024/1024}')
USED_SPACE=$(df / | awk 'NR==2{printf "%.1f", $3/1024/1024}')

echo "  💾 Dung lượng còn lại: ${AVAILABLE_SPACE}GB"
echo "  📊 Dung lượng đã sử dụng: ${USED_SPACE}GB"

if (( $(echo "$AVAILABLE_SPACE < 5" | bc -l) )); then
    print_error "Không đủ dung lượng! Cần ít nhất 5GB trống."
    print_error "Vui lòng dọn dẹp ổ cứng trước khi backup."
    exit 1
fi

# Tạo thư mục backup
print_status "Chuẩn bị thư mục backup..."
if sudo mkdir -p "$BACKUP_DIR"; then
    sudo chmod 755 "$BACKUP_DIR"
    print_status "Thư mục backup: $BACKUP_DIR"
else
    print_error "Không thể tạo thư mục backup!"
    exit 1
fi

# Tạo backup info file
print_status "Tạo thông tin backup..."
cat > "/tmp/backup-info.txt" << EOF
UBUNTU ON-DEMAND BACKUP INFORMATION
===================================
Backup Type: Manual/On-Demand (Không tự động)
Backup Date: $(date '+%Y-%m-%d %H:%M:%S')
Initiated By: $(whoami)
Hostname: $(hostname)
Ubuntu Version: $(lsb_release -d | cut -f2 2>/dev/null || echo 'Ubuntu')
Kernel: $(uname -r)
IP Address: $(ip route get 1 | awk '{print $7; exit}' 2>/dev/null || echo 'N/A')

BACKUP FILES:
- Main Archive: $BACKUP_FILE
- Log File: $LOG_FILE
- Info File: $INFO_FILE

BACKUP SCOPE:
✓ /home (User data & configurations)
✓ /etc (System configurations)
✓ /root (Root user data)
✓ /var/www (Web server files)
✓ /usr/local (Custom installations)
✓ /opt (Optional software)
✓ /srv (Service data)

EXCLUDED DIRECTORIES:
✗ /proc, /sys, /dev (Virtual filesystems)
✗ /tmp, /var/tmp (Temporary files)
✗ /var/cache, /var/log (Cache & logs)
✗ /snap (Snap packages)
✗ /mnt, /media (Mount points)
✗ /backup (Avoid recursion)

NOTE: Đây là backup THỦ CÔNG, không phải backup tự động.
EOF

sudo mv "/tmp/backup-info.txt" "$INFO_FILE"
sudo chmod 644 "$INFO_FILE"

# Bắt đầu backup
echo ""
print_header
print_status "🚀 BẮT ĐẦU BACKUP THỦ CÔNG..."
echo ""
print_status "📁 File backup sẽ được lưu: $BACKUP_FILE"
print_status "📝 Log file: $LOG_FILE"
print_status "ℹ️ Info file: $INFO_FILE"
echo ""

print_warning "⏳ ĐANG BACKUP - KHÔNG TẮT MÁY HOẶC NGẮT KẾT NỐI!"
print_warning "🔒 Quá trình này chạy với quyền sudo để đọc system files"
echo ""

# Backup timer start
START_TIME=$(date +%s)

# Thực hiện backup
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

# Tính thời gian backup
END_TIME=$(date +%s)
DURATION=$((END_TIME - START_TIME))
DURATION_MIN=$((DURATION / 60))
DURATION_SEC=$((DURATION % 60))

# Kiểm tra kết quả
if [ ${PIPESTATUS[0]} -eq 0 ]; then
    BACKUP_SIZE=$(du -h "$BACKUP_FILE" | cut -f1)
    echo ""
    echo -e "${GREEN}================================================${NC}"
    echo -e "${GREEN}           ✅ BACKUP THÀNH CÔNG!${NC}"
    echo -e "${GREEN}================================================${NC}"
    echo ""
    print_status "📁 File backup: $BACKUP_FILE"
    print_status "📏 Kích thước: $BACKUP_SIZE"
    print_status "⏱️  Thời gian: ${DURATION_MIN}m ${DURATION_SEC}s"
    print_status "📝 Log file: $LOG_FILE"
    print_status "ℹ️ Info file: $INFO_FILE"
    print_status "✅ Backup thủ công hoàn tất lúc: $(date '+%H:%M:%S')"
    
    # Tạo restore script
    RESTORE_SCRIPT="$BACKUP_DIR/restore-$(date +%Y%m%d-%H%M%S).sh"
    cat > "$RESTORE_SCRIPT" << 'EOF'
#!/bin/bash
echo "=========================================="
echo "   Ubuntu System Restore Script"
echo "=========================================="
echo "Sử dụng: sudo ./restore.sh backup-file.tar.gz"
echo ""

if [ $# -eq 0 ]; then
    echo "❌ Vui lòng cung cấp file backup làm tham số"
    echo "Ví dụ: sudo ./restore.sh manual-backup-20250531-123456.tar.gz"
    exit 1
fi

BACKUP_FILE=$1

if [ ! -f "$BACKUP_FILE" ]; then
    echo "❌ Không tìm thấy file backup: $BACKUP_FILE"
    exit 1
fi

echo "📁 Sẽ khôi phục từ: $BACKUP_FILE"
echo "⚠️  CẢNH BÁO: Điều này sẽ GHI ĐÈ lên các file hiện có!"
echo "⚠️  Hãy đảm bảo bạn đã backup hệ thống hiện tại trước khi restore!"
echo ""
echo -n "Nhập 'RESTORE' (viết hoa) để xác nhận: "
read confirmation

if [ "$confirmation" = "RESTORE" ]; then
    echo "🚀 Bắt đầu khôi phục hệ thống..."
    sudo tar -xvpzf "$BACKUP_FILE" -C / --numeric-owner
    echo ""
    echo "✅ Khôi phục hoàn tất!"
    echo "🔄 Vui lòng khởi động lại hệ thống: sudo reboot"
else
    echo "❌ Khôi phục đã bị hủy"
fi
EOF

    sudo chmod +x "$RESTORE_SCRIPT"
    print_status "🔧 Script khôi phục: $RESTORE_SCRIPT"
    
    # Summary
    echo ""
    print_header
    print_important "📋 TÓM TẮT BACKUP SESSION:"
    echo "  • Backup thủ công thực hiện thành công"
    echo "  • Kích thước: $BACKUP_SIZE"  
    echo "  • Thời gian: ${DURATION_MIN}m ${DURATION_SEC}s"
    echo "  • Files được tạo: 4 files (backup + log + info + restore script)"
    echo ""
    print_status "🎉 BACKUP HOÀN TẤT! Script sẽ thoát ngay."
    
else
    echo ""
    echo -e "${RED}================================================${NC}"
    echo -e "${RED}            ❌ BACKUP THẤT BẠI!${NC}"
    echo -e "${RED}================================================${NC}"
    print_error "Có lỗi xảy ra trong quá trình backup."
    print_error "Kiểm tra file log để biết chi tiết: $LOG_FILE"
    exit 1
fi

echo ""
print_status "Script backup on-demand kết thúc. Tạm biệt!"
