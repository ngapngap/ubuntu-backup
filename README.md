# Ubuntu Manual Backup Script

Script backup Ubuntu chỉ chạy khi người dùng thực thi thủ công.

## Đặc điểm
- ✅ **Chỉ chạy khi bạn muốn** - Không tự động, không cron job
- ✅ **Xác nhận trước khi chạy** - Hỏi ý kiến người dùng
- ✅ **Kiểm tra dung lượng** - Đảm bảo đủ không gian
- ✅ **Hiển thị tiến trình** - Theo dõi quá trình backup
- ✅ **Tạo script restore** - Tự động tạo script khôi phục
- ✅ **Backup an toàn** - Loại trừ các thư mục không cần thiết

## Cách sử dụng

### Bước 1: Tải về
git clone https://github.com/ngapngap/ubuntu-backup.git
cd ubuntu-backup

### Bước 2: Cấp quyền
chmod +x manual-backup.sh

### Bước 3: Chạy backup (chỉ khi bạn muốn)

./manual-backup.sh

**Lưu ý:** Script sẽ hỏi xác nhận và yêu cầu gõ "YES" trước khi bắt đầu.

## 📁 Backup bao gồm

✅ **User Data:**
- `/home` - Tất cả dữ liệu người dùng
- `/root` - Dữ liệu root user

✅ **System Configuration:**  
- `/etc` - Cấu hình hệ thống
- `/usr/local` - Phần mềm cài thủ công
- `/opt` - Ứng dụng optional

✅ **Web & Services:**
- `/var/www` - Web server files
- `/srv` - Service data

❌ **Loại trừ:**
- Cache files, logs, temp files
- Virtual filesystems (/proc, /sys, /dev)
- Mount points, snap packages

## 🔄 Khôi phục dữ liệu

Script tự động tạo restore script:


## 📊 Kết quả backup

Sau khi chạy, bạn sẽ có 4 files:
/backup/
├── manual-backup-TIMESTAMP.tar.gz # File backup chính
├── backup-log-TIMESTAMP.txt # Log chi tiết
├── backup-info-TIMESTAMP.txt # Thông tin backup
└── restore-TIMESTAMP.sh # Script khôi phục
## Khôi phục dữ liệu
sudo ./restore-TIMESTAMP.sh backup-file.tar.gz

## Lưu ý
- Script yêu cầu xác nhận trước khi chạy
- Cần ít nhất 5GB dung lượng trống
- Quá trình backup có thể mất 10-30 phút
- Không tắt máy trong quá trình backup
