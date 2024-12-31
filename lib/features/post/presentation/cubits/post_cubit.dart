import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:socialmediaapp/features/post/domain/entities/comment.dart';
import 'package:socialmediaapp/features/post/domain/entities/post.dart';
import 'package:socialmediaapp/features/post/domain/repos/post_repo.dart';
import 'package:socialmediaapp/features/post/presentation/cubits/post_states.dart';

class PostCubit extends Cubit<PostState> {
  final PostRepo postRepo;

  PostCubit({required this.postRepo}) : super(PostInitial());

  Future<void> createPost(Post post) async {
    try {
      emit(PostLoading());
      await postRepo.createPost(post);
      await fetchAllPost(); // Tự động tải lại tất cả bài đăng
    } catch (e) {
      emit(PostError("Failed to create post : $e"));
    }
  }

  //fetch all posts
  Future<void> fetchAllPost() async {
    try {
      emit(PostLoading());
      final posts = await postRepo.fetchAllPost();
      emit(PostsLoaded(posts));
    } catch (e) {
      emit(PostError("Failed to fetch posts : $e"));
    }
  }

  Future<void> updatePost(Post post) async {
    try {
      emit(PostLoading());
      await postRepo.updatePost(post); // Cập nhật bài đăng trong repository
      emit(PostUpdated(
          post)); // Phát trạng thái bài đăng được cập nhật thành công
      await fetchAllPost(); // Tải lại danh sách bài đăng
    } catch (e) {
      emit(PostError("Failed to update post: $e"));
    }
  }

  //delete a post
  Future<void> deletePost(String postId) async {
    try {
      emit(PostLoading());
      await postRepo.deletePost(postId);
      await fetchAllPost(); // Tự động tải lại danh sách
    } catch (e) {
      emit(PostError("Failed to delete post : $e"));
    }
  }

  //chuyen doi thich trong post
  Future<void> toggleLikePost(String postId, String userId) async {
    try {
      await postRepo.toggleLikePost(postId, userId);
    } catch (e) {
      emit(PostError("Failed to toggle like: $e"));
    }
  }

  // them comment vao post
  Future<void> addComment(String postId, Comment comment) async {
    try {
      await postRepo.addComment(postId, comment);

      await fetchAllPost();
    } catch (e) {
      emit(PostError("Failed to add comment : $e"));
    }
  }

  //xoa comment trong post
  Future<void> deleteComment(String postId, String commentId) async {
    try {
      await postRepo.deleteComment(postId, commentId);
      await fetchAllPost();
    } catch (e) {
      emit(PostError("Failed to delete comment : $e"));
    }
  }
}
