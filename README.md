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

## Kết quả backup
- File backup: `/backup/ubuntu-backup-TIMESTAMP.tar.gz`
- File log: `/backup/backup-TIMESTAMP.log`
- Script restore: `/backup/restore-TIMESTAMP.sh`

## Khôi phục dữ liệu
sudo ./restore-TIMESTAMP.sh backup-file.tar.gz

## Lưu ý
- Script yêu cầu xác nhận trước khi chạy
- Cần ít nhất 5GB dung lượng trống
- Quá trình backup có thể mất 10-30 phút
- Không tắt máy trong quá trình backup
