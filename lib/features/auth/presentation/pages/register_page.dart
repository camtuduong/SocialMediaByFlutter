import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:socialmediaapp/features/auth/presentation/components/my_button.dart';
import 'package:socialmediaapp/features/auth/presentation/components/my_text_field.dart';

import '../cubits/auth_cubit.dart';

class RegisterPage extends StatefulWidget {
  final void Function()? togglePages;

  const RegisterPage({super.key, required this.togglePages});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  //text controller
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final pwController = TextEditingController();
  final confirmController = TextEditingController();

  //register btn pressed
  void register() {
    //prepare info

    final String name = nameController.text;
    final String email = emailController.text;
    final String pw = pwController.text;
    final String confirmPw = confirmController.text;

    //auth cubits
    final authCubit = context.read<AuthCubit>();

    //ensure the fields aren't empty
    if (email.isNotEmpty &&
        name.isNotEmpty &&
        pw.isNotEmpty &&
        confirmPw.isNotEmpty) {
      //ensure password math
      if (pw == confirmPw) {
        authCubit.register(name, email, pw);
      }

      // password don't match
      else {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Your password do not match")));
      }
    }
    //fields are empty -> display error
    else {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please complete all fields")));
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    pwController.dispose();
    confirmController.dispose();
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        //Body
        body: SafeArea(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              //logo
              Icon(
                Icons.lock_open_rounded,
                size: 80,
                color: Theme.of(context).colorScheme.primary,
              ),

              const SizedBox(
                height: 50,
              ),

              //create account message
              Text(
                "Let's create an account for you",
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontSize: 16,
                ),
              ),

              const SizedBox(
                height: 25,
              ),

              //name text field
              MyTextField(
                  controller: nameController,
                  hintText: "Name",
                  obscureText: false),

              const SizedBox(
                height: 10,
              ),

              //email text field
              MyTextField(
                  controller: emailController,
                  hintText: "Email",
                  obscureText: false),
              const SizedBox(
                height: 10,
              ),

              //pw text field
              MyTextField(
                  controller: pwController,
                  hintText: "Password",
                  obscureText: true),

              const SizedBox(
                height: 10,
              ),

              // confirm pw text field
              MyTextField(
                  controller: confirmController,
                  hintText: "Confirm password",
                  obscureText: true),

              const SizedBox(
                height: 25,
              ),

              //register btn
              MyButton(onTap: register, text: "Register"),

              const SizedBox(
                height: 50,
              ),
              //already a member? login now
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Already a member?",
                    style:
                        TextStyle(color: Theme.of(context).colorScheme.primary),
                  ),
                  GestureDetector(
                    onTap: widget.togglePages,
                    child: Text(
                      " Login now",
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.inversePrimary,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    ));
  }
}
