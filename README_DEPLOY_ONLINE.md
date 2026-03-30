# Bộ triển khai online cho phần mềm quản lý xây dựng

Bộ này chia 2 giai đoạn:

## Ngày 1 - Chạy online cho cả tổ
- Deploy lên Railway
- Dùng 1 service Node.js + SQLite + uploads trên Volume
- Frontend Flutter Web build sẵn và được Node phục vụ tại cùng domain
- Thành viên dùng bằng điện thoại qua trình duyệt rồi Add to Home Screen

## Ngày 2 - Thêm đăng nhập tài khoản
- Có bảng users và sessions trong SQLite
- Có API đăng nhập/đăng xuất/xác thực phiên
- Tạo tài khoản đầu tiên bằng biến môi trường ADMIN_USERNAME / ADMIN_PASSWORD

---

## Cấu trúc thư mục khuyến nghị trên máy anh

repo-root/
  server/
    server.js
    package.json
    Dockerfile
    railway.json
    .dockerignore
    .gitignore
    public/        <-- copy toàn bộ nội dung từ build/web vào đây
  flutter_app/
    lib/main.dart

---

## Bước A - Build Flutter Web
Tại thư mục app Flutter:

```bat
cd /d D:\projects\ql_xaydung_app
flutter build web
```

Sau đó copy **toàn bộ file trong** `build\web` vào thư mục `server\public`.

---

## Bước B - Deploy Railway

1. Tạo repo GitHub.
2. Đưa thư mục `server` lên repo.
3. Trên Railway tạo service mới từ GitHub repo.
4. Trong service settings, đặt **Root Directory** là `server` nếu repo của anh là monorepo.
5. Attach Volume và mount path là `/data`.
6. Trong Variables thêm:
   - `DATA_DIR=/data`
   - `NODE_ENV=production`
   - `APP_BASE_URL=https://ten-app-cua-anh.up.railway.app`
   - Ngày 2 thêm `ADMIN_USERNAME=admin`
   - Ngày 2 thêm `ADMIN_PASSWORD=doi_mat_khau_ngay`

---

## Bước C - File nào dùng ở giai đoạn nào

### Ngày 1
- Dùng `server.day1.js` và đổi tên thành `server.js`
- Dùng `main.day1.dart` và đổi tên thành `main.dart`

### Ngày 2
- Dùng `server.day2.js` và đổi tên thành `server.js`
- Dùng `main.day2.dart` và đổi tên thành `main.dart`

---

## Ghi chú quan trọng
- Ngày 2 là bản đăng nhập cơ bản, phù hợp nội bộ tổ. Với môi trường lớn hơn nên nâng cấp thêm hash mật khẩu mạnh hơn, rate limit, reset mật khẩu và phân quyền sâu hơn.
- Nếu anh chỉ muốn chạy ngay cho cả tổ, làm Ngày 1 trước. Sau khi online ổn rồi mới thay qua file Ngày 2.
