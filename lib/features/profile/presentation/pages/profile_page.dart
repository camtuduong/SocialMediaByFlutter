import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:socialmediaapp/features/auth/domain/entities/app_user.dart';
import 'package:socialmediaapp/features/auth/presentation/cubits/auth_cubit.dart';
import 'package:socialmediaapp/features/post/presentation/components/post_tile.dart';
import 'package:socialmediaapp/features/post/presentation/cubits/post_cubit.dart';
import 'package:socialmediaapp/features/post/presentation/cubits/post_states.dart';
import 'package:socialmediaapp/features/profile/presentation/components/bio.box.dart';
import 'package:socialmediaapp/features/profile/presentation/components/follow_button.dart';
import 'package:socialmediaapp/features/profile/presentation/components/profile_stats.dart';
import 'package:socialmediaapp/features/profile/presentation/cubits/profile_cubit.dart';
import 'package:socialmediaapp/features/profile/presentation/cubits/profile_states.dart';
import 'package:socialmediaapp/features/profile/presentation/pages/edit_profile_page.dart';
import 'package:socialmediaapp/features/profile/presentation/pages/follower_page.dart';

class ProfilePage extends StatefulWidget {
  final String uid;
  const ProfilePage({super.key, required this.uid});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  //cubits
  late final authCubit = context.read<AuthCubit>();
  late final profileCubit = context.read<ProfileCubit>();

  //current user
  late AppUser? currentUser = authCubit.currentUser;

  //posts
  int postCount = 0;

  @override
  void initState() {
    super.initState();

    //load user profile data
    profileCubit.fetchUserProfile(widget.uid);
  }

  /*

    FOLLOW / UNFOLLOW

  */
  void followButtonPressed() {
    final profileState = profileCubit.state;
    if (profileState is! ProfileLoaded) {
      return; //return is profile is not loaded
    }

    final profileUser = profileState.profileUser;
    final isFollowing = profileUser.followers.contains(currentUser!.uid);

    //optimistically update UI
    setState(() {
      //unfollow
      if (isFollowing) {
        profileUser.followers.remove(currentUser!.uid);
      }

      //follow
      else {
        profileUser.followers.add(currentUser!.uid);
      }
    });

    //thực hiện chuyển đổi thực tế theo cubit
    profileCubit.toggleFollow(currentUser!.uid, widget.uid).catchError((error) {
      //revert update if there is an error
      setState(() {
        //unfollow
        if (isFollowing) {
          profileUser.followers.add(currentUser!.uid);
        }

        //follow
        else {
          profileUser.followers.remove(currentUser!.uid);
        }
      });
    });
  }

//Build ui
  @override
  Widget build(BuildContext context) {
    //is own post
    bool isOwnPost = (widget.uid == currentUser!.uid);

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
                  if (isOwnPost)
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
                  Center(
                    child: Container(
                      height: 120, // Đường kính hình tròn
                      width: 120, // Đường kính hình tròn
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.secondary,
                        shape: BoxShape.circle, // Hình dạng hình tròn
                        boxShadow: [
                          BoxShadow(
                            color:
                                Colors.black.withOpacity(0.1), // Hiệu ứng bóng
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ClipOval(
                        // Đảm bảo ảnh nằm trong hình tròn
                        child: user.profileImageUrl.isNotEmpty
                            ? CachedNetworkImage(
                                imageUrl: user.profileImageUrl,
                                fit: BoxFit.cover, // Đảm bảo ảnh không bị méo
                                placeholder: (context, url) =>
                                    const CircularProgressIndicator(), // Hiển thị khi đang tải
                                errorWidget: (context, url, error) =>
                                    const Icon(
                                  Icons.error, // Hiển thị khi lỗi
                                  color: Colors.red,
                                ),
                              )
                            : const Icon(
                                Icons
                                    .person, // Biểu tượng mặc định nếu không có ảnh
                                size: 60,
                                color: Colors.grey,
                              ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 25),

                  //profile stats
                  ProfileStats(
                    postCount: postCount,
                    followersCount: user.followers.length,
                    followingCount: user.following.length,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => FollowerPage(
                          followers: user.followers,
                          following: user.following,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 25),

                  //follow btn
                  if (!isOwnPost)
                    FollowButton(
                      onPressed: followButtonPressed,
                      isFollowing: user.followers.contains(currentUser!.uid),
                    ),

                  const SizedBox(height: 25),

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
                        //lọc bài post dựa trên user id
                        final userPosts = state.posts
                            .where((post) => post.userId == widget.uid)
                            .toList();

                        // cập nhật postCount và trigger rebuild
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          setState(() {
                            postCount = userPosts.length;
                          });
                        });

                        return ListView.builder(
                          itemCount: postCount,
                          physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemBuilder: (context, index) {
                            // lấy từng bài post
                            final post = userPosts[index];

                            // return PostTile
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
