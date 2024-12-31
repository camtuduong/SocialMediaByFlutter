import 'package:socialmediaapp/features/post/domain/entities/comment.dart';
import 'package:socialmediaapp/features/post/domain/entities/post.dart';

abstract class PostRepo {
  Future<List<Post>> fetchAllPost();
  Future<void> createPost(Post post);
  Future<void> deletePost(String postId);
  Future<void> updatePost(Post post);
  Future<List<Post>> fetchPostsByUserId(String userId);
  Future<void> toggleLikePost(String postId, String userId);
  Future<void> addComment(String postId, Comment comment);
  Future<void> deleteComment(String postId, String commentId);
}
