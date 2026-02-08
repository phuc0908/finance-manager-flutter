# Quản lý Tài chính - Finance Manager App

Ứng dụng quản lý tài chính cá nhân được xây dựng bằng Flutter, tập trung vào trải nghiệm mượt mà, bảo mật dữ liệu và đồng bộ hóa đám mây.

## 📸 Hình ảnh minh họa (Preview)

| Dashboard | Quản lý ví | Thêm giao dịch | Cài đặt |
| :---: | :---: | :---: | :---: |
| ![Dashboard](C:\Users\phuc0\.gemini\antigravity\brain\6513b30f-1a1e-4d0c-b0d1-8e924aaefed4\media__1770541761017.png) | ![Ví tiền](C:\Users\phuc0\.gemini\antigravity\brain\6513b30f-1a1e-4d0c-b0d1-8e924aaefed4\media__1770541772365.png) | ![Giao dịch](C:\Users\phuc0\.gemini\antigravity\brain\6513b30f-1a1e-4d0c-b0d1-8e924aaefed4\media__1770541783357.png) | ![Cài đặt](C:\Users\phuc0\.gemini\antigravity\brain\6513b30f-1a1e-4d0c-b0d1-8e924aaefed4\media__1770541750290.png) |

## ✨ Tính năng chính

- **Tổng quan tài chính (Dashboard)**: Theo dõi số dư, thu nhập và chi tiêu trong tháng với giao diện hiện đại.
- **Quản lý ví**: Hỗ trợ nhiều loại ví khác nhau (Tiền mặt, Ngân hàng, Thẻ tín dụng...).
- **Ghi chép giao dịch**: Thêm mới thu chi nhanh chóng với phân loại danh mục (Ăn uống, Mua sắm, v.v.).
- **Đồng bộ hóa đám mây (Cloud Sync)**:
  - Tự động sao lưu dữ liệu lên Firebase.
  - Tính năng **Đồng bộ thủ công (Force Sync)**: Xóa bộ nhớ đệm cục bộ và tải lại dữ liệu mới nhất từ Cloud nếu có sai lệch.
- **Cá nhân hóa**:
  - Chỉnh sửa Nickname và Avatar URL.
  - Hỗ trợ đổi giao diện và đa ngôn ngữ (đang phát triển).

## 🛠 Công nghệ sử dụng

- **Framework**: `Flutter` (Dart)
- **Quản lý trạng thái**: `Flutter Riverpod`
- **Cơ sở dữ liệu cục bộ**: `Isar` (NoSQL cực nhanh cho Flutter)
- **Backend**: `Firebase` (Auth & Firestore)
- **Kiến trúc**: Clean Architecture (Data, Domain, Presentation)

## 🚀 Hướng dẫn cài đặt

1. **Clone project**:
   ```bash
   git clone <url_du_an>
   ```
2. **Cài đặt dependencies**:
   ```bash
   flutter pub get
   ```
3. **Cài đặt Developer Mode**:
   - Nếu bạn dùng Windows, hãy bật **Developer Mode** trong cài đặt hệ thống để hỗ trợ Symlinks.
4. **Chạy ứng dụng**:
   ```bash
   flutter run
   ```

---
*Phát triển bởi Hy Phương*
