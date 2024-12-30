import 'package:cloud_firestore/cloud_firestore.dart';
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
}