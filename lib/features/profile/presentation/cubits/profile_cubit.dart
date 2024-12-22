import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:socialmediaapp/features/profile/domain/repos/profile_repo.dart';
import 'package:socialmediaapp/features/profile/presentation/cubits/profile_states.dart';

class ProfileCubit extends Cubit<ProfileStates> {
  final ProfileRepo profileRepo;

  ProfileCubit({required this.profileRepo}) : super(ProfileInitial());

  //fetch user profile using repos
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

  //update bio and or profile picture
  Future<void> updateProfile({
    required String uid,
    String? newBio,
  }) async {
    emit(ProfileLoading());

    try {
      //fetch current profile first
      final currentUser = await profileRepo.fetchUserProfile(uid);

      if (currentUser == null) {
        emit(ProfileError("Fail to fetch user for profile update"));
        return;
      }

      //profile picture update

      //update new profile
      final updatedProfile =
          currentUser.copyWith(newBio: newBio ?? currentUser.bio);

      //update in repos
      await profileRepo.updateProfile(updatedProfile);

      //re-fetch the updated profile
      await fetchUserProfile(uid);
    } catch (e) {
      emit(ProfileError("Error updating profile : $e"));
    }
  }
}
