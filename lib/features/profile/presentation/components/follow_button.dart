/*
  FOLLOW BTN

  day la follow va unfollow BTN
  --------------------------------------------
  de dung cai widget nay thi can pha :

  - la 1 function (vd : toggleFollow() ),
  - kiem tra xem co isFollowing (vd : sai - > btn follow con khong thi la btn unfollow)


*/

import 'package:flutter/material.dart';

class FollowButton extends StatelessWidget {
  final void Function()? onPressed;
  final bool isFollowing;
  const FollowButton({
    super.key,
    required this.onPressed,
    required this.isFollowing,
  });

//build ui
  @override
  Widget build(BuildContext context) {
    return Padding(
      //padding on outside
      padding: const EdgeInsets.symmetric(horizontal: 25.0),

      //btn
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: MaterialButton(
          onPressed: onPressed,

          //padding inside
          padding: const EdgeInsets.all(25),

          color:
              isFollowing ? Theme.of(context).colorScheme.primary : Colors.blue,
          //text
          child: Text(
            isFollowing ? "Unfollow" : "Follow",
            style: TextStyle(
              color: Theme.of(context).colorScheme.secondary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
