import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:socialmediaapp/features/auth/data/firebase_auth_repo.dart';
import 'package:socialmediaapp/features/auth/home/presentation/pages/home_page.dart';
import 'package:socialmediaapp/features/auth/presentation/cubits/auth_cubit.dart';
import 'package:socialmediaapp/features/auth/presentation/cubits/auth_states.dart';
import 'package:socialmediaapp/features/auth/presentation/pages/auth_page.dart';
import 'package:socialmediaapp/features/profile/data/firebase_profile_repo.dart';
import 'package:socialmediaapp/features/profile/presentation/cubits/profile_cubit.dart';
import 'package:socialmediaapp/themes/light_mode.dart';

/*
App - root level

Repositories: for the db
  - firebase

Bloc providers : for the state management
  - auth
  - profile
  - post
  - search 
  - theme

Check Auth State
  - unauthenticated -> auth page (login/register)
  - authenticated -> home page
*/

class MyApp extends StatelessWidget {
  //auth repo
  final authRepo = FirebaseAuthRepo();

  //profile repo
  final profileRepo = FirebaseProfileRepo();

  MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    //profile cubits to app
    return MultiBlocProvider(
      providers: [
        //auth cubits
        BlocProvider<AuthCubit>(
          create: (context) => AuthCubit(authRepo: authRepo)..checkAuth(),
        ),

        //profile cubits
        BlocProvider<ProfileCubit>(
          create: (context) => ProfileCubit(profileRepo: profileRepo),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: lightMode,
        home: BlocConsumer<AuthCubit, AuthState>(builder: (context, authState) {
          print(authState);

          //unauthenticated -> auth page (login/register)
          if (authState is Unauthenticated) {
            return const AuthPage();
          }

          //authenticated -> home page
          if (authState is Authenticated) {
            return const HomePage();
          }

          //loading..
          else {
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }
        },
            //Listen for error...
            listener: (context, state) {
          if (state is AuthError) {
            ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text(state.message)));
          }
        }),
      ),
    );
  }
}
