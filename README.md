# Quản lý Tài chính - Finance Manager App

Ứng dụng quản lý tài chính cá nhân được xây dựng bằng Flutter, tập trung vào trải nghiệm mượt mà, bảo mật dữ liệu và đồng bộ hóa đám mây.

## (Preview)

| Dashboard | Quản lý ví | Thêm giao dịch | Cài đặt |
| :---: | :---: | :---: | :---: |
| ![Dashboard](preview/Screenshot%202026-02-08%20160918.png) | ![Ví tiền](preview/Screenshot%202026-02-08%20160930.png) | ![Giao dịch](preview/Screenshot%202026-02-08%20160941.png) | ![Cài đặt](preview/Screenshot%202026-02-08%20160859%20-%20Copy.png) |

## Tính năng chính

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

---
*Phát triển bởi Phuc0908*
