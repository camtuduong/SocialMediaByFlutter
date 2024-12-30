import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:socialmediaapp/features/home/presentation/components/my_drawer.dart';
import 'package:socialmediaapp/features/post/presentation/components/post_tile.dart';
import 'package:socialmediaapp/features/post/presentation/cubits/post_cubit.dart';
import 'package:socialmediaapp/features/post/presentation/cubits/post_states.dart';
import 'package:socialmediaapp/features/post/presentation/pages/upload_post_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  //post cubit
  late final postCubit = context.read<PostCubit>();

  //on startup
  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    //fetch all posts
    context.read<PostCubit>().fetchAllPost();
  }

  void fetchAllPost() {
    postCubit.fetchAllPost();
  }

  void deletePost(String postId) {
    postCubit.deletePost(postId);
    fetchAllPost();
  }

  //Build UI
  @override
  Widget build(BuildContext context) {
    //Scaffold
    return Scaffold(
      //app bar
      appBar: AppBar(
        title: const Text("Home"),
        foregroundColor: Theme.of(context).colorScheme.primary,
        actions: [
          //upload new post button
          IconButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const UploadPostPage(),
              ),
            ),
            icon: const Icon(Icons.add),
          ),
        ],
      ),

      //drawer
      drawer: const MyDrawer(),

      //body
      body: BlocBuilder<PostCubit, PostState>(
        builder: (context, state) {
          //loading..
          if (state is PostLoading && state is PostUploading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          //loaded
          else if (state is PostsLoaded) {
            final allPosts = state.posts;

            if (allPosts.isEmpty) {
              return const Center(
                child: Text("No posts available"),
              );
            }

            return ListView.builder(
              itemCount: allPosts.length,
              itemBuilder: (context, index) {
                //lấy bài viết cá nhân
                final post = allPosts[index];

                //image
                return PostTile(
                  post: post,
                  onDeletePressed: () => deletePost(post.id),
                );
              },
            );
          }

          //error
          else if (state is PostError) {
            return Center(
              child: Text(state.message),
            );
          } else {
            return const SizedBox();
          }
        },
      ),
    );
  }
}
