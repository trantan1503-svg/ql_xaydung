// NGÀY 2: file Flutter cần thêm màn hình đăng nhập và gắn token vào request.
// Vì file main.dart hiện tại của anh khá dài, bản nâng cấp đăng nhập nên làm trên chính code đang chạy.
// Quy trình tối thiểu:
// 1) Thêm biến serverBaseUrl là domain Railway.
// 2) Tạo LoginPage gọi POST /api/auth/login.
// 3) Lưu token vào localStorage hoặc SharedPreferences.
// 4) Gắn header Authorization: Bearer <token> cho toàn bộ request.
// 5) Thêm nút đăng xuất gọi POST /api/auth/logout.
// Nếu anh muốn, em sẽ viết riêng tiếp một file main.dart đầy đủ có login dựa trên bản giao diện cuối anh đang dùng.
