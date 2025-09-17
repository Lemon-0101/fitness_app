import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitness_app/model/user.dart' as UserModel;
import 'package:fitness_app/textbox_list_item_card.dart';
import 'package:flutter/material.dart';
import 'package:fitness_app/getting_started_page.dart';


class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  String _emailAddress = "";
  String _password = "";
  String _cpassword = "";

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                LogoWidget(),
                SizedBox(height: 10),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 300, // Adjust this width as needed
                      child: TextFormField(
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          labelText: 'Email',
                          hintText: 'e.g., email@email.com',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your email address.';
                          }
                          final bool emailValid = RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+").hasMatch(value);
                          if (!emailValid) {
                            return 'Please enter a valid email address.';
                          }
                          return null; // Return null if the input is valid
                        },
                        onChanged: (value) {
                          _emailAddress = value;
                        },
                      )
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: 300, // Adjust this width as needed
                      child: TextFormField(
                        obscureText: true,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your password.';
                          }
                          if (value.length < 8) {
                            return 'Your password is too short.';
                          }
                          if (_password != _cpassword) {
                            return 'Password doesn\'t match.';
                          }
                          return null; // Return null if the input is valid
                        },
                        onChanged: (value) {
                          _password = value;
                        },
                      )
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: 300, // Adjust this width as needed
                      child: TextFormField(
                        obscureText: true,
                        decoration: InputDecoration(
                          labelText: 'Confirm Password',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your password.';
                          }
                          if (value.length < 8) {
                            return 'Your password is too short.';
                          }
                          if (_password != _cpassword) {
                            return 'Password doesn\'t match.';
                          }
                          return null; // Return null if the input is valid
                        },
                        onChanged: (value) {
                          _cpassword = value;
                        },
                      )
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: 300, // Adjust this width as needed
                      child: Builder( // <-- Add Builder here
                        builder: (context) => ElevatedButton.icon(
                          onPressed: () async {
                            if (_formKey.currentState!.validate()) {
                              String message = "";
                              try {
                                await UserModel.User().signUpWithEmail(_emailAddress, _password);
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(builder: (context) => GettingStartedPage()),
                                );
                              } on FirebaseAuthException catch (e) {
                                if (e.code == 'weak-password') {
                                  message = "The password provided is too weak.";
                                } else if (e.code == 'email-already-in-use') {
                                  message = "The account already exists for that email.";
                                }
                              } catch (e) {
                                print(e);
                              }
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(message)),
                              );
                            }
                          },
                          label: const Text("Sign Up"),
                          icon: Icon(Icons.login),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text('Back to Login Page'),
                    ),
                  ],
                )
              ],
            )
          ),
        ),
      ),
    );
  }
}

class LogoWidget extends StatelessWidget {
  const LogoWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30.0),
      child: Stack(
        children: [
          Image.asset('assets/images/logo.png'),
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Center(
              child: RichText(
                text: TextSpan(
                  style: theme.textTheme.displayMedium!.copyWith(
                    color: Color(0xFF08095c),
                    fontWeight: FontWeight.bold
                  ),
                  children: <TextSpan>[
                    TextSpan(
                      text: 'Fitness',
                    ),
                    TextSpan(
                      text: 'App',
                      style: TextStyle(
                        color: Color(0xFF73cc43)
                      )
                    )
                  ]
                )
              )
            )
          )
        ]
      )
    );
  }
}