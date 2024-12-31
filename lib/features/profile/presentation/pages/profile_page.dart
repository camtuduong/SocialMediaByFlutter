import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:socialmediaapp/features/auth/domain/entities/app_user.dart';
import 'package:socialmediaapp/features/auth/presentation/cubits/auth_cubit.dart';
import 'package:socialmediaapp/features/post/presentation/components/post_tile.dart';
import 'package:socialmediaapp/features/post/presentation/cubits/post_cubit.dart';
import 'package:socialmediaapp/features/post/presentation/cubits/post_states.dart';
import 'package:socialmediaapp/features/profile/presentation/components/bio.box.dart';
import 'package:socialmediaapp/features/profile/presentation/cubits/profile_cubit.dart';
import 'package:socialmediaapp/features/profile/presentation/cubits/profile_states.dart';
import 'package:socialmediaapp/features/profile/presentation/pages/edit_profile_page.dart';

class ProfilePage extends StatefulWidget {
  final String uid;
  const ProfilePage({super.key, required this.uid});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  //cubits
  late final authCubit = context.read<AuthCubit>();

  //current user
  late AppUser? currentUser = authCubit.currentUser;

  //posts
  int postCount = 0;

  @override
  void initState() {
    super.initState();
    // Gọi fetchUserProfile khi màn hình được khởi tạo
    context.read<ProfileCubit>().fetchUserProfile(widget.uid);
  }

//Build ui
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileCubit, ProfileStates>(
      builder: (context, state) {
        //loaded
        if (state is ProfileLoaded) {
          //get loaded users
          final user = state.profileUser;

          return Scaffold(
              appBar: AppBar(
                title: Text(user.name),
                foregroundColor: Theme.of(context).colorScheme.primary,
                actions: [
                  //edit profile button
                  IconButton(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EditProfilePage(
                          user: user,
                        ),
                      ),
                    ),
                    icon: const Icon(Icons.settings),
                  )
                ],
              ),

              //body
              body: ListView(
                children: [
                  //email
                  Center(
                    child: Text(
                      user.email,
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.primary),
                    ),
                  ),

                  const SizedBox(
                    height: 15,
                  ),

                  // Profile pic
                  Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.secondary,
                      shape: BoxShape
                          .circle, // Đổi từ BoxShape.rectangle sang BoxShape.circle
                      image: user.profileImageUrl.isNotEmpty
                          ? DecorationImage(
                              image: NetworkImage(
                                  user.profileImageUrl), // URL ảnh từ Firestore
                              fit: BoxFit.cover,
                            )
                          : null,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1), // Hiệu ứng bóng
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    height: 120, // Đường kính hình tròn
                    width: 120, // Đường kính hình tròn
                    child: user.profileImageUrl.isEmpty
                        ? const Icon(
                            Icons.person,
                            size:
                                60, // Biểu tượng trong trường hợp không có ảnh
                            color: Colors.grey,
                          )
                        : null,
                  ),

                  const SizedBox(
                    height: 25,
                  ),

                  //bio box
                  Padding(
                    padding: const EdgeInsets.only(left: 25.0),
                    child: Row(
                      children: [
                        Text(
                          "Bio",
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(
                    height: 10,
                  ),

                  BioBox(text: user.bio),

                  //posts
                  Padding(
                    padding: const EdgeInsets.only(left: 25.0, top: 25),
                    child: Row(
                      children: [
                        Text(
                          "Posts",
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(
                    height: 10,
                  ),

                  //list of posts from this user
                  BlocBuilder<PostCubit, PostState>(
                    builder: (context, state) {
                      //posts loaded
                      if (state is PostsLoaded) {
                        //loc nhung bai post dua tren user id
                        final userPosts = state.posts
                            .where((post) => post.userId == widget.uid)
                            .toList();

                        postCount = userPosts.length;
                        return ListView.builder(
                          itemCount: postCount,
                          physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemBuilder: (context, index) {
                            //lay tung bai post
                            final post = userPosts[index];

                            //return as post tile UI
                            return PostTile(
                              post: post,
                              onDeletePressed: () =>
                                  context.read<PostCubit>().deletePost(post.id),
                            );
                          },
                        );
                      }

                      //post loading..
                      else if (state is PostLoading) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      } else {
                        return const Center(
                          child: Text("No post..."),
                        );
                      }
                      //
                    },
                  ),
                ],
              ));
        }

        //loading..
        else if (state is ProfileLoading) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        } else {
          return const Center(
            child: Text("No profile found.."),
          );
        }
      },
    );
  }
}
