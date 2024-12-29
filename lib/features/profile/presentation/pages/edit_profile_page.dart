import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:socialmediaapp/features/auth/presentation/components/my_text_field.dart';
import 'package:socialmediaapp/features/profile/domain/entities/profile_user.dart';
import 'package:socialmediaapp/features/profile/presentation/cubits/profile_cubit.dart';
import 'package:socialmediaapp/features/profile/presentation/cubits/profile_states.dart';
import 'package:socialmediaapp/services/cloudinary_service.dart';

class EditProfilePage extends StatefulWidget {
  final ProfileUser user;
  const EditProfilePage({super.key, required this.user});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final bioTextController = TextEditingController();
  FilePickerResult? _filePickerResult; // Lưu file ảnh được chọn
  Uint8List? webImage; // Lưu ảnh cho web
  PlatformFile? imagePickedFile; // Lưu ảnh cho mobile

  @override
  void initState() {
    super.initState();
    bioTextController.text = widget.user.bio; // Hiển thị bio hiện tại
  }

  // Hàm mở file picker
  void _openFilePicker() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowMultiple: false,
      allowedExtensions: ["jpg", "jpeg", "png"],
      type: FileType.custom,
    );

    if (result != null) {
      setState(() {
        _filePickerResult = result;
        if (kIsWeb) {
          webImage = result.files.first.bytes;
        } else {
          imagePickedFile = result.files.first;
        }
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No file selected")),
      );
    }
  }

  // Hàm cập nhật profile
  Future<void> updateProfile() async {
    if (bioTextController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Bio cannot be empty")),
      );
      return;
    }

    // Hiển thị loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return const Center(child: CircularProgressIndicator());
      },
    );

    try {
      // Upload ảnh lên Cloudinary nếu có chọn ảnh mới
      String? imageUrl = widget.user.profileImageUrl;
      if (_filePickerResult != null) {
        imageUrl = await uploadToCloudinary(_filePickerResult!);
        if (imageUrl == null) {
          throw Exception("Failed to upload image");
        }
      }

      // Gửi thông tin mới lên Firestore qua ProfileCubit
      final profileCubit = context.read<ProfileCubit>();
      await profileCubit.updateProfile(
        uid: widget.user.uid,
        newBio: bioTextController.text,
        newProfileImageUrl: imageUrl,
      );

      // Thành công
      Navigator.pop(context); // Tắt loading
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Profile updated successfully")),
      );
      Navigator.pop(context); // Quay lại trang trước đó
    } catch (e) {
      // Tắt loading
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to update profile: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ProfileCubit, ProfileStates>(
      builder: (context, state) {
        return buildEditPage();
      },
      listener: (context, state) {
        if (state is ProfileLoaded) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Profile loaded successfully")),
          );
        }
      },
    );
  }

  Widget buildEditPage() {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Profile"),
        foregroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hiển thị ảnh hiện tại hoặc ảnh đã chọn
            Center(
              child: GestureDetector(
                onTap: _openFilePicker,
                child: Container(
                  height: 120,
                  width: 120,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(12),
                    image: imagePickedFile != null || webImage != null
                        ? DecorationImage(
                            image: kIsWeb
                                ? MemoryImage(webImage!)
                                : FileImage(File(imagePickedFile!.path!))
                                    as ImageProvider,
                            fit: BoxFit.cover,
                          )
                        : widget.user.profileImageUrl.isNotEmpty
                            ? DecorationImage(
                                image:
                                    NetworkImage(widget.user.profileImageUrl),
                                fit: BoxFit.cover,
                              )
                            : null,
                  ),
                  child: widget.user.profileImageUrl.isEmpty &&
                          imagePickedFile == null &&
                          webImage == null
                      ? const Icon(Icons.person, size: 72, color: Colors.grey)
                      : null,
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Ô nhập bio
            const Text(
              "Bio",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            MyTextField(
              controller: bioTextController,
              hintText: "Enter your bio",
              obscureText: false,
            ),

            const SizedBox(height: 30),

            // Nút cập nhật
            Center(
              child: ElevatedButton(
                onPressed: updateProfile,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  backgroundColor: Theme.of(context).colorScheme.primary,
                ),
                child: const Text(
                  "Update Profile",
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
