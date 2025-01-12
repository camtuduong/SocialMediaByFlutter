import 'package:socialmediaapp/features/post/domain/entities/post.dart';

abstract class PostState {}

//initial
class PostInitial extends PostState {}

//loading..
class PostLoading extends PostState {}

//uploading..
class PostUploading extends PostState {}

//Error
class PostError extends PostState {
  final String message;
  PostError(this.message);
}

//loaded
class PostsLoaded extends PostState {
  final List<Post> posts;
  PostsLoaded(this.posts);
}

//updated
class PostUpdated extends PostState {
  final Post updatedPost;
  PostUpdated(this.updatedPost);
}

class CommentUpdated extends PostState {
  final String commentId;
  final String updatedText;

  CommentUpdated(this.commentId, this.updatedText);
}
