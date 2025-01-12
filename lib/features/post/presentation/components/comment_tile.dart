import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:socialmediaapp/features/auth/domain/entities/app_user.dart';
import 'package:socialmediaapp/features/auth/presentation/cubits/auth_cubit.dart';
import 'package:socialmediaapp/features/post/domain/entities/comment.dart';
import 'package:socialmediaapp/features/post/presentation/cubits/post_cubit.dart';

class CommentTile extends StatefulWidget {
  final Comment comment;
  const CommentTile({super.key, required this.comment});

  @override
  State<CommentTile> createState() => _CommentTileState();
}

class _CommentTileState extends State<CommentTile> {
  //current user
  AppUser? currentUser;
  bool isOwnPost = false;

  @override
  void initState() {
    super.initState();
    getCurrentUser();
  }

  void getCurrentUser() {
    final authCubit = context.read<AuthCubit>();
    currentUser = authCubit.currentUser;
    isOwnPost = (widget.comment.userId == currentUser!.uid);
  }

  //show options for deletion or editing
  void showOptions() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          "Comment Options",
          textAlign: TextAlign.center,
          style: TextStyle(color: Theme.of(context).colorScheme.primary),
        ),
        actions: [
          //edit btn
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              showEditDialog();
            },
            child: const Text("Edit"),
          ),

          //delete btn
          TextButton(
              onPressed: () {
                context
                    .read<PostCubit>()
                    .deleteComment(widget.comment.postId, widget.comment.id);
                Navigator.of(context).pop();
              },
              child: const Text("Delete")),
        ],
      ),
    );
  }

  // show dialog to edit the comment
  void showEditDialog() {
    TextEditingController textController =
        TextEditingController(text: widget.comment.text);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          "Edit Comment",
          textAlign: TextAlign.center,
          style: TextStyle(color: Theme.of(context).colorScheme.primary),
        ),
        content: TextField(
          controller: textController,
          maxLines: null,
          decoration: InputDecoration(
            hintText: "Edit your comment",
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          //cancel btn
          TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Cancel")),

          //save btn
          TextButton(
            onPressed: () {
              String updatedText = textController.text.trim();
              if (updatedText.isNotEmpty) {
                context.read<PostCubit>().updateComment(
                      widget.comment.postId,
                      widget.comment.id,
                      updatedText,
                    );
                Navigator.of(context).pop();
              }
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Row(
        children: [
          //name
          Text(
            widget.comment.userName,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.inversePrimary,
            ),
          ),

          const SizedBox(width: 10),

          //comment text
          Text(
            widget.comment.text,
            style:
                TextStyle(color: Theme.of(context).colorScheme.inversePrimary),
          ),

          const Spacer(),

          //more options button
          if (isOwnPost)
            GestureDetector(
              onTap: showOptions,
              child: Icon(
                Icons.more_horiz,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
        ],
      ),
    );
  }
}
