/*

  Trang này sẽ được hiển thị một thanh tab để hiển thị
      - danh sach followers
      - danh sach following

*/
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:socialmediaapp/features/profile/presentation/components/user_tile.dart';
import 'package:socialmediaapp/features/profile/presentation/cubits/profile_cubit.dart';

class FollowerPage extends StatelessWidget {
  final List<String> followers;
  final List<String> following;

  const FollowerPage({
    super.key,
    required this.followers,
    required this.following,
  });

  @override
  Widget build(BuildContext context) {
    //Tab controller
    return DefaultTabController(
      length: 2,

      //scaffold
      child: Scaffold(
        appBar: AppBar(
          //Tab bar
          bottom: TabBar(
            dividerColor: Colors.transparent,
            labelColor: Theme.of(context).colorScheme.inversePrimary,
            unselectedLabelColor: Theme.of(context).colorScheme.primary,
            tabs: const [
              Tab(text: "Followers"),
              Tab(text: "Following"),
            ],
          ),
        ),

        //Tab bar view
        body: TabBarView(
          children: [
            _buildUserList(followers, "No followers", context),
            _buildUserList(following, "No following", context),
          ],
        ),
      ),
    );
  }

  //xây dựng danh sách người dùng, cung cấp danh sách uid hồ sơ
  Widget _buildUserList(
      List<String> uids, String emptyMessage, BuildContext context) {
    return uids.isEmpty
        ? Center(child: Text(emptyMessage))
        : ListView.builder(
            itemCount: uids.length,
            itemBuilder: (context, index) {
              // lay tung uid
              final uid = uids[index];

              return FutureBuilder(
                future: context.read<ProfileCubit>().getUserProfile(uid),
                builder: (context, snapshot) {
                  //user loaded
                  if (snapshot.hasData) {
                    final user = snapshot.data!;
                    return UserTile(user: user);
                  }

                  //loading...
                  else if (snapshot.connectionState ==
                      ConnectionState.waiting) {
                    return ListTile(title: Text("Loading..."));
                  }

                  //not found..
                  else {
                    return ListTile(title: Text("User not found"));
                  }
                },
              );
            },
          );
  }
}
