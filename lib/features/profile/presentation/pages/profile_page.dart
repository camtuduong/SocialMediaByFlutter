import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:socialmediaapp/features/auth/domain/entities/app_user.dart';
import 'package:socialmediaapp/features/auth/presentation/cubits/auth_cubit.dart';
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
              body: Column(
                children: [
                  //email
                  Text(
                    user.email,
                    style:
                        TextStyle(color: Theme.of(context).colorScheme.primary),
                  ),

                  const SizedBox(
                    height: 15,
                  ),

                  //profile pic
                  Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.secondary,
                      borderRadius: BorderRadius.circular(12),
                      image: user.profileImageUrl.isNotEmpty
                          ? DecorationImage(
                              image: NetworkImage(user
                                  .profileImageUrl), // Sử dụng URL ảnh từ Firestore
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                    height: 120,
                    width: 120,
                    child: user.profileImageUrl.isEmpty
                        ? const Icon(Icons.person, size: 72, color: Colors.grey)
                        : null, // Hiển thị biểu tượng nếu không có ảnh
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
