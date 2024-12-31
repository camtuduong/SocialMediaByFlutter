import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:socialmediaapp/features/auth/domain/entities/app_user.dart';
import 'package:socialmediaapp/features/auth/presentation/components/my_text_field.dart';
import 'package:socialmediaapp/features/auth/presentation/cubits/auth_cubit.dart';
import 'package:socialmediaapp/features/post/domain/entities/comment.dart';
import 'package:socialmediaapp/features/post/domain/entities/post.dart';
import 'package:socialmediaapp/features/post/presentation/components/comment_tile.dart';
import 'package:socialmediaapp/features/post/presentation/cubits/post_cubit.dart';
import 'package:socialmediaapp/features/post/presentation/cubits/post_states.dart';
import 'package:socialmediaapp/features/profile/domain/entities/profile_user.dart';
import 'package:socialmediaapp/features/profile/presentation/cubits/profile_cubit.dart';
import 'package:socialmediaapp/features/profile/presentation/pages/profile_page.dart';

class PostTile extends StatefulWidget {
  final Post post;
  final void Function()? onDeletePressed;
  const PostTile(
      {super.key, required this.post, required this.onDeletePressed});

  @override
  State<PostTile> createState() => _PostTileState();
}

class _PostTileState extends State<PostTile> {
  //cubits
  late final postCubit = context.read<PostCubit>();
  late final profileCubit = context.read<ProfileCubit>();

  bool isOwnPost = false;

  //current user
  AppUser? currentUser;

  //post user
  ProfileUser? postUser;

  //on startup
  @override
  void initState() {
    super.initState();
    getCurrentUser();
    fetchPostUser();
  }

  void getCurrentUser() {
    final authCubit = context.read<AuthCubit>();
    currentUser = authCubit.currentUser;
    isOwnPost = (widget.post.userId == currentUser!.uid);
  }

  Future<void> fetchPostUser() async {
    final fetchedUser = await profileCubit.getUserProfile(widget.post.userId);
    if (fetchedUser != null) {
      setState(() {
        postUser = fetchedUser;
      });
    }
  }

  /*

      LIKES

  */

  //user tapped like btn
  void toggleLikePost() {
    //current like status
    final isLiked = widget.post.likes.contains(currentUser!.uid);

    //optimistically like and update UI (đây là phần để cho việc update like trờ nên đẹp mắt hơn mà k cần refresh fetchAllPosts)
    setState(() {
      if (isLiked) {
        widget.post.likes.remove(currentUser!.uid); //unlike
      } else {
        widget.post.likes.add(currentUser!.uid); //like
      }
    });

    //update like
    postCubit
        .toggleLikePost(widget.post.id, currentUser!.uid)
        .catchError((error) {
      //if there's an error, revert back back to original values
      setState(() {
        if (isLiked) {
          widget.post.likes.add(currentUser!.uid); //revert unlike
        } else {
          widget.post.likes.remove(currentUser!.uid); //revert like
        }
      });
    });
  }

  /*

    COMMENTS

  */
  //comment text controller
  final commentTextController = TextEditingController();

  //mo cai comment box -> người dùng muốn gõ một cmt mới
  void openNewCommentBox() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: MyTextField(
          controller: commentTextController,
          hintText: "Type a comment",
          obscureText: false,
        ),
        actions: [
          //cancel btn
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("Cancel"),
          ),

          //save btn
          TextButton(
            onPressed: () {
              addComment();
              Navigator.of(context).pop();
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  //add comment
  void addComment() {
    //tao 1 comment moi
    final newComment = Comment(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      postId: widget.post.id,
      userId: currentUser!.uid,
      userName: currentUser!.name,
      text: commentTextController.text,
      timestamp: DateTime.now(),
    );

    //dung cubit them comment
    if (commentTextController.text.isNotEmpty) {
      postCubit.addComment(widget.post.id, newComment);
    }
  }

  @override
  void dispose() {
    commentTextController.dispose();
    super.dispose();
  }

  //show options for deletion
  void showOptions() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          "Delete Post?",
          textAlign: TextAlign.center,
          style: TextStyle(color: Theme.of(context).colorScheme.primary),
        ),
        actions: [
          //cancel btn
          TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Cancel")),

          //delete btn
          TextButton(
              onPressed: () {
                widget.onDeletePressed!();
                Navigator.of(context).pop();
              },
              child: const Text("Delete")),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.secondary,
      child: Column(
        children: [
          //top section
          GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ProfilePage(
                  uid: widget.post.userId,
                ),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  //profile pic
                  postUser?.profileImageUrl != null
                      ? CachedNetworkImage(
                          imageUrl: postUser!.profileImageUrl,
                          errorWidget: (context, url, error) =>
                              const Icon(Icons.person),
                          imageBuilder: (context, imageProvider) => Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                image: DecorationImage(
                                  image: imageProvider,
                                  fit: BoxFit.cover,
                                )),
                          ),
                        )
                      : const Icon(Icons.person),
                  const SizedBox(
                    width: 10,
                  ),

                  //name
                  Text(
                    widget.post.userName,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.inversePrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const Spacer(),

                  //delete btn
                  if (isOwnPost)
                    GestureDetector(
                      onTap: showOptions,
                      child: Icon(
                        Icons.delete,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                ],
              ),
            ),
          ),

          //image
          CachedNetworkImage(
            imageUrl: widget.post.imageUrl,
            height: 430,
            width: double.infinity,
            fit: BoxFit.cover,
            placeholder: (context, url) => const SizedBox(
              height: 430,
            ),
            errorWidget: (context, url, error) => const Icon(Icons.error),
          ),

          //btn -> like , comment, timestamp
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              children: [
                SizedBox(
                  width: 50,
                  child: Row(
                    children: [
                      //like btn
                      GestureDetector(
                        onTap: toggleLikePost,
                        child: Icon(
                            widget.post.likes.contains(currentUser!.uid)
                                ? Icons.favorite
                                : Icons.favorite_border,
                            color: widget.post.likes.contains(currentUser!.uid)
                                ? Colors.red
                                : Theme.of(context).colorScheme.primary),
                      ),

                      const SizedBox(width: 5),

                      //like count
                      Text(
                        widget.post.likes.length.toString(),
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),

                //cmt btn
                GestureDetector(
                  onTap: openNewCommentBox,
                  child: Icon(
                    Icons.comment,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),

                const SizedBox(width: 5),

                Text(
                  widget.post.comments.length.toString(),
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontSize: 12,
                  ),
                ),

                const Spacer(),
                //timestamp
                Text(
                  widget.post.timestamp.toString(),
                  style:
                      TextStyle(color: Theme.of(context).colorScheme.primary),
                ),
              ],
            ),
          ),

          //CAPTION NEKK
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20),
            child: Row(
              children: [
                //userName
                Text(
                  widget.post.userName,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(width: 10),

                //text
                Text(widget.post.text),
              ],
            ),
          ),

          //COMMENT SECTION
          BlocBuilder<PostCubit, PostState>(
            builder: (context, state) {
              //Loaded
              if (state is PostsLoaded) {
                //final tung cai post rieng
                final post = state.posts
                    .firstWhere((post) => (post.id == widget.post.id));

                if (post.comments.isNotEmpty) {
                  //so luong cmt duoc hien thi
                  int showCommentCount = post.comments.length;

                  //comment section
                  return ListView.builder(
                    itemCount: showCommentCount,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemBuilder: (context, index) {
                      // lay tung cai cmt
                      final comment = post.comments[index];

                      //comment tile UI
                      return CommentTile(comment: comment);
                    },
                  );
                }
              }

              //Loading
              if (state is PostLoading) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              //error
              else if (state is PostError) {
                return Center(
                  child: Text(state.message),
                );
              } else {
                return const Center(
                  child: SizedBox(),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}
