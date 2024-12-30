import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:socialmediaapp/features/auth/domain/entities/app_user.dart';
import 'package:socialmediaapp/features/auth/presentation/components/my_text_field.dart';
import 'package:socialmediaapp/features/auth/presentation/cubits/auth_cubit.dart';
import 'package:socialmediaapp/features/post/domain/entities/post.dart';
import 'package:socialmediaapp/features/post/presentation/cubits/post_cubit.dart';
import 'package:socialmediaapp/features/post/presentation/cubits/post_states.dart';
import 'package:socialmediaapp/services/cloudinary_service.dart'; // Dùng để upload ảnh lên Cloudinary

class UploadPostPage extends StatefulWidget {
  const UploadPostPage({super.key});

  @override
  State<UploadPostPage> createState() => _UploadPostPageState();
}

class _UploadPostPageState extends State<UploadPostPage> {
  FilePickerResult? _filePickerResult;

  // mobile image pick
  PlatformFile? imagePickedFile;

  // web image pick
  Uint8List? webImage;

  // text controller -> caption
  final textController = TextEditingController();

  // current user
  AppUser? currentUser;

  @override
  void initState() {
    super.initState();
    getCurrentUser();
  }

  // get current user
  void getCurrentUser() {
    final authCubit = context.read<AuthCubit>();
    currentUser = authCubit.currentUser;
  }

  // select image
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

  // create and upload post
  Future<void> uploadPost() async {
    if ((imagePickedFile == null && webImage == null) ||
        textController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Both image and caption are required")),
      );
      return;
    }

    // Hiển thị trạng thái loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return const Center(child: CircularProgressIndicator());
      },
    );

    try {
      // Upload ảnh lên Cloudinary
      String? imageUrl;
      if (_filePickerResult != null) {
        imageUrl = await uploadToCloudinary(_filePickerResult!);
      }

      if (imageUrl == null) {
        throw Exception("Failed to upload image to Cloudinary");
      }

      // Tạo post mới
      final newPost = Post(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: currentUser!.uid,
        userName: currentUser!.name,
        text: textController.text,
        imageUrl: imageUrl,
        timestamp: DateTime.now(),
        likes: [],
      );

      // Lưu post vào Firestore
      final postCubit = context.read<PostCubit>();
      await postCubit.createPost(newPost);

      // Đóng dialog loading
      if (mounted) Navigator.pop(context);

      // Hiển thị thông báo thành công
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Post uploaded successfully")),
      );

      // Giữ người dùng ở màn hình hiện tại
      setState(() {
        _filePickerResult = null;
        imagePickedFile = null;
        webImage = null;
        textController.clear();
      });
    } catch (e) {
      // Đóng dialog loading khi có lỗi
      if (mounted) Navigator.pop(context);

      // Hiển thị thông báo lỗi
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to upload post: $e")),
      );
    }
  }

  @override
  void dispose() {
    textController.dispose();
    super.dispose();
  }

  // Build UI
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PostCubit, PostState>(
      builder: (context, state) {
        if (state is PostLoading) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
        return buildUploadPage();
      },
      listener: (context, state) {
        if (state is PostsLoaded) {
          Navigator.pop(context);
        }
      },
    );
  }

  Widget buildUploadPage() {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Create Post"),
        foregroundColor: Theme.of(context).colorScheme.primary,
        actions: [
          IconButton(
            onPressed: uploadPost,
            icon: const Icon(Icons.upload),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),

            // Display selected image
            Center(
              child: Container(
                height: 200,
                width: 200,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                  image: imagePickedFile != null || webImage != null
                      ? DecorationImage(
                          image: kIsWeb
                              ? MemoryImage(webImage!)
                              : FileImage(File(imagePickedFile!.path!))
                                  as ImageProvider,
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: imagePickedFile == null && webImage == null
                    ? const Center(
                        child: Text(
                          "No Image Selected",
                          style: TextStyle(color: Colors.grey),
                        ),
                      )
                    : null,
              ),
            ),

            const SizedBox(height: 20),

            // Image picker button
            Center(
              child: ElevatedButton.icon(
                onPressed: _openFilePicker,
                icon: const Icon(Icons.image),
                label: const Text("Pick Image"),
              ),
            ),

            const SizedBox(height: 20),

            // Caption text field
            const Text(
              "Caption",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            MyTextField(
              controller: textController,
              hintText: "Enter your caption",
              obscureText: false,
            ),

            const SizedBox(height: 30),

            // Upload button
            Center(
              child: ElevatedButton(
                onPressed: uploadPost,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  backgroundColor: Theme.of(context).colorScheme.primary,
                ),
                child: const Text(
                  "Upload Post",
                  style: TextStyle(fontSize: 18, color: Colors.white70),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
