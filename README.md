# Quản lý Tài chính - Finance Manager App

Ứng dụng quản lý tài chính cá nhân được xây dựng bằng Flutter, tập trung vào trải nghiệm mượt mà, bảo mật dữ liệu và đồng bộ hóa đám mây.

## (Preview)

| Dashboard | Quản lý ví | Thêm giao dịch | Cài đặt |
| :---: | :---: | :---: | :---: |
| ![Dashboard](https://drive.google.com/file/d/1GDMDfYPSO9OFw_1F7f_Ng9CAKeSTUaih/view?usp=drive_link) | ![Ví tiền](https://drive.google.com/file/d/1jgVFYkvqAvdQVCA52pSHWHyQBl48zAx4/view?usp=drive_link) | ![Giao dịch](https://drive.google.com/file/d/1EsDr4BcNK29Rb2vWSUvrvpt7Oin3nnn_/view?usp=drive_link) | ![Cài đặt](https://drive.google.com/file/d/13p-ecqJ394P4ZGe7MYg5X_TzW4Cw_3FI/view?usp=sharing) |

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
