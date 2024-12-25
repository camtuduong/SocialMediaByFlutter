import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:socialmediaapp/features/auth/presentation/components/my_text_field.dart';
import 'package:socialmediaapp/features/profile/domain/entities/profile_user.dart';
import 'package:socialmediaapp/features/profile/presentation/cubits/profile_cubit.dart';
import 'package:socialmediaapp/features/profile/presentation/cubits/profile_states.dart';
import 'package:socialmediaapp/features/profile/presentation/pages/upload_area.dart';

class EditProfilePage extends StatefulWidget {
  final ProfileUser user;
  const EditProfilePage({super.key, required this.user});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final bioTextController = TextEditingController();
  FilePickerResult? _filePickerResult;

  // Hàm mở file picker
  void _openFilePicker() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowMultiple: false,
      allowedExtensions: ["jpg", "jpeg", "png", "mp4"],
      type: FileType.custom,
    );

    if (result != null) {
      setState(() {
        _filePickerResult = result;
      });

      // Đẩy dữ liệu đến UploadArea
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => UploadArea(filePickerResult: _filePickerResult),
        ),
      );
    } else {
      // Xử lý khi không chọn file
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No file selected")),
      );
    }
  }

  // Hàm cập nhật hồ sơ
  void updateProfile() {
    final profileCubit = context.read<ProfileCubit>();

    if (bioTextController.text.isNotEmpty) {
      profileCubit.updateProfile(
        uid: widget.user.uid,
        newBio: bioTextController.text,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ProfileCubit, ProfileStates>(
      builder: (context, state) {
        if (state is ProfileLoading) {
          return const Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  Text("Uploading..."),
                ],
              ),
            ),
          );
        } else {
          return buildEditPage();
        }
      },
      listener: (context, state) {
        if (state is ProfileLoaded) {
          Navigator.pop(context);
        }
      },
    );
  }

  Widget buildEditPage() {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Profile"),
        foregroundColor: Theme.of(context).colorScheme.primary,
        actions: [
          IconButton(
            onPressed: updateProfile,
            icon: const Icon(Icons.upload),
          ),
        ],
      ),
      body: Column(
        children: [
          // Ảnh đại diện
          GestureDetector(
            onTap: () {
              _openFilePicker();
            },
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.secondary,
                borderRadius: BorderRadius.circular(12),
                image: widget.user.profileImageUrl.isNotEmpty
                    ? DecorationImage(
                        image: NetworkImage(widget.user.profileImageUrl),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              height: 120,
              width: 120,
              child: widget.user.profileImageUrl.isEmpty
                  ? const Icon(Icons.person, size: 72, color: Colors.grey)
                  : null,
            ),
          ),
          const SizedBox(height: 10),
          const Text("Bio"),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25.0),
            child: MyTextField(
              controller: bioTextController,
              hintText: widget.user.bio,
              obscureText: false,
            ),
          ),
        ],
      ),
    );
  }
}
