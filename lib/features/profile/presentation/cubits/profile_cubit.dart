import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:socialmediaapp/features/profile/domain/entities/profile_user.dart';
import 'package:socialmediaapp/features/profile/domain/repos/profile_repo.dart';
import 'package:socialmediaapp/features/profile/presentation/cubits/profile_states.dart';

class ProfileCubit extends Cubit<ProfileStates> {
  final ProfileRepo profileRepo;

  ProfileCubit({required this.profileRepo}) : super(ProfileInitial());

  //fetch user profile using repos -> useful for loading profile page
  Future<void> fetchUserProfile(String uid) async {
    try {
      emit(ProfileLoading());
      final user = await profileRepo.fetchUserProfile(uid);

      if (user != null) {
        emit(ProfileLoaded(user));
      } else {
        emit(ProfileError("User not found"));
      }
    } catch (e) {
      emit(ProfileError(e.toString()));
    }
  }

  //return user profile given uid -> useful for loading many profile for posts
  Future<ProfileUser?> getUserProfile(String uid) async {
    final user = await profileRepo.fetchUserProfile(uid);
    return user;
  }

  //update bio and/or profile picture
  Future<void> updateProfile({
    required String uid,
    String? newBio,
    String? newProfileImageUrl,
  }) async {
    emit(ProfileLoading());

    try {
      // Fetch current profile first
      final currentUser = await profileRepo.fetchUserProfile(uid);

      if (currentUser == null) {
        emit(ProfileError("Fail to fetch user for profile update"));
        return;
      }

      // Tạo đối tượng profile mới với thông tin cập nhật
      final updatedProfile = currentUser.copyWith(
        newBio: newBio ?? currentUser.bio,
        newProfileImageUrl:
            newProfileImageUrl ?? currentUser.profileImageUrl, // Cập nhật ảnh
      );

      // Update in repository
      await profileRepo.updateProfile(updatedProfile);

      // Re-fetch the updated profile
      await fetchUserProfile(uid);
    } catch (e) {
      emit(ProfileError("Error updating profile : $e"));
    }
  }
}
