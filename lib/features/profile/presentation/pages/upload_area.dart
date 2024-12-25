import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:socialmediaapp/features/profile/data/firebase_profile_repo.dart';
import 'package:socialmediaapp/services/cloudinary_service.dart';

class UploadArea extends StatefulWidget {
  final FilePickerResult?
      filePickerResult; // Nhận FilePickerResult từ constructor

  const UploadArea({super.key, required this.filePickerResult});

  @override
  State<UploadArea> createState() => _UploadAreaState();
}

class _UploadAreaState extends State<UploadArea> {
  @override
  Widget build(BuildContext context) {
    final selectedFile = widget.filePickerResult; // Truy cập filePickerResult

    if (selectedFile == null || selectedFile.files.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text("Upload Area"),
        ),
        body: const Center(
          child: Text("No file selected"),
        ),
      );
    }

    // Lấy thông tin file được chọn
    final file = selectedFile.files.first;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Upload Area"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Selected File: ${file.name}",
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 20),
              TextFormField(
                readOnly: true,
                initialValue: selectedFile.files.first.name,
                decoration: const InputDecoration(labelText: "Name"),
              ),
              const SizedBox(height: 20),
              TextFormField(
                readOnly: true,
                initialValue: selectedFile.files.first.extension,
                decoration: const InputDecoration(labelText: "Extention"),
              ),
              const SizedBox(height: 20),
              TextFormField(
                readOnly: true,
                initialValue: "${selectedFile.files.first.size} bytes.",
                decoration: const InputDecoration(labelText: "Size"),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Text("canel")),
                  ),
                  const SizedBox(
                    width: 25,
                  ),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        // Gọi hàm uploadToCloudinary
                        final result = await uploadToCloudinary(selectedFile);

                        if (result != null) {
                          // Hiển thị thông báo upload thành công
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text("File uploaded successfully")),
                          );

                          // Tạo đối tượng FirebaseProfileRepo
                          final profileRepo = FirebaseProfileRepo();

                          // Lấy UID của user hiện tại
                          String uid = FirebaseAuth.instance.currentUser!.uid;

                          // Tải hồ sơ hiện tại
                          final currentUser =
                              await profileRepo.fetchUserProfile(uid);

                          if (currentUser != null) {
                            // Tạo đối tượng ProfileUser đã cập nhật
                            final updatedUser = currentUser.copyWith(
                                newProfileImageUrl: result);

                            // Lưu vào Firebase
                            await profileRepo.updateProfile(updatedUser);

                            // Hiển thị thông báo cập nhật thành công
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text(
                                      "Profile image URL updated successfully")),
                            );

                            // Quay lại màn hình trước
                            Navigator.pop(context);
                          } else {
                            // Thông báo lỗi nếu không tìm thấy user
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content:
                                      Text("Failed to fetch user profile")),
                            );
                          }
                        } else {
                          // Hiển thị thông báo lỗi nếu upload thất bại
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text("Cannot upload your file")),
                          );
                        }
                      },
                      child: const Text("Upload"),
                    ),
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
