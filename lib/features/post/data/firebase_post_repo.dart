import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:socialmediaapp/features/post/domain/entities/comment.dart';
import 'package:socialmediaapp/features/post/domain/entities/post.dart';
import 'package:socialmediaapp/features/post/domain/repos/post_repo.dart';

class FirebasePostRepo implements PostRepo {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  // store the posts in a collection called "posts"
  final CollectionReference postsCollection =
      FirebaseFirestore.instance.collection("posts");
  @override
  Future<void> createPost(Post post) async {
    try {
      await postsCollection.doc(post.id).set(post.toJson());
    } catch (e) {
      throw Exception("Error creating post : $e");
    }
  }

  @override
  Future<void> deletePost(String postId) async {
    await firestore.collection("posts").doc(postId).delete();
  }

  @override
  Future<List<Post>> fetchAllPost() async {
    try {
      final postsSnapshot =
          await postsCollection.orderBy('timestamp', descending: true).get();

      final List<Post> allPosts = postsSnapshot.docs.map((doc) {
        print("Post data: ${doc.data()}"); // Log dữ liệu bài đăng
        return Post.fromJson(doc.data() as Map<String, dynamic>);
      }).toList();

      return allPosts;
    } catch (e) {
      throw Exception("Error fetching posts: $e");
    }
  }

  @override
  Future<void> updatePost(Post post) async {
    await firestore.collection("posts").doc(post.id).update(post.toJson());
  }

  @override
  Future<List<Post>> fetchPostsByUserId(String userId) async {
    try {
      //fetch posts snapshot with this uid
      final postsSnapshot =
          await postsCollection.where('userId', isEqualTo: userId).get();

      //map firestore document from json -> list of posts
      final userPost = postsSnapshot.docs
          .map((doc) => Post.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
      return userPost;
    } catch (e) {
      throw Exception("Error creating post : $e");
    }
  }

  @override
  Future<void> toggleLikePost(String postId, String userId) async {
    try {
      //get the post document from firestore
      final postDoc = await postsCollection.doc(postId).get();

      if (postDoc.exists) {
        final post = Post.fromJson(postDoc.data() as Map<String, dynamic>);

        //check if user has already like this post
        final hasLiked = post.likes.contains(userId);

        //update the likes list
        if (hasLiked) {
          post.likes.remove(userId); //unlike
        } else {
          post.likes.add(userId);
        }

        //update the post document with the new like list
        await postsCollection.doc(postId).update({
          'likes': post.likes,
        });
      } else {
        throw Exception('Post not found');
      }
    } catch (e) {
      throw Exception('Error toggling like : $e');
    }
  }

  @override
  Future<void> addComment(String postId, Comment comment) async {
    try {
      //get post document
      final postDoc = await postsCollection.doc(postId).get();

      if (postDoc.exists) {
        //chuyển đổi đối tượng json -> post
        final post = Post.fromJson(postDoc.data() as Map<String, dynamic>);

        //them 1 comment moi
        post.comments.add(comment);

        //cap nhat lai post trong firestore
        await postsCollection.doc(postId).update({
          'comments': post.comments.map((comment) => comment.toJson()).toList()
        });
      } else {
        throw Exception("Post no found");
      }
    } catch (e) {
      throw Exception("Error adding comment: $e");
    }
  }

  @override
  Future<void> deleteComment(String postId, String commentId) async {
    try {
      //get post document
      final postDoc = await postsCollection.doc(postId).get();

      if (postDoc.exists) {
        //chuyển đổi đối tượng json -> post
        final post = Post.fromJson(postDoc.data() as Map<String, dynamic>);

        //xoa comment
        post.comments.removeWhere((comment) => comment.id == commentId);

        //cap nhat lai post trong firestore
        await postsCollection.doc(postId).update({
          'comments': post.comments.map((comment) => comment.toJson()).toList()
        });
      } else {
        throw Exception("Post no found");
      }
    } catch (e) {
      throw Exception("Error deleting comment: $e");
    }
  }
}
