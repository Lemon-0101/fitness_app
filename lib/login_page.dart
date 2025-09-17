import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitness_app/model/user.dart' as UserModel;
import 'package:fitness_app/register_page.dart';
import 'package:fitness_app/textbox_list_item_card.dart';
import 'package:flutter/material.dart';
import 'package:fitness_app/getting_started_page.dart';


class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  String _emailAddress = "";
  String _password = "";

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
                      child: Builder( // <-- Add Builder here
                        builder: (context) => ElevatedButton.icon(
                          onPressed: () async {
                            if (_formKey.currentState!.validate()) {
                              String message = "";
                              try {
                                await UserModel.User().signInWithEmail(_emailAddress, _password);
                              } on FirebaseAuthException catch (e) {
                                if (e.code == 'user-not-found') {
                                  message = "No user found for that email.";
                                } else if (e.code == 'wrong-password') {
                                  message = "Wrong password provided for that user.";
                                }
                              }
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(message)),
                              );
                            }
                          },
                          label: const Text("Sign in"),
                          icon: Icon(Icons.login),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => RegisterPage()),
                        );
                      },
                      child: const Text('Register Here'),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: 300, // Adjust this width as needed
                      child: Row(
                        children: const <Widget>[
                          Expanded(
                            child: Divider(
                              thickness: 1, // Optional: Adjust line thickness
                              color: Colors.grey, // Optional: Change line color
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 10),
                            child: Text(
                              'OR',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ),
                          Expanded(
                            child: Divider(
                              thickness: 1,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 60, // Adjust width as needed
                          height: 60, // Adjust height as needed
                          child: ElevatedButton(
                            onPressed: () async {
                              try {
                                await UserModel.User().signInWithGoogle();
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(builder: (context) => GettingStartedPage()),
                                );
                              } on FirebaseAuthException catch (e) {
                                debugPrint('Sign-in failed: ${e.code}');
                              } catch (e) {
                                debugPrint('An unexpected error occurred: $e');
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.zero, // Remove default padding
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: Image.asset('assets/images/google_logo.png', height: 24.0),
                          ),
                        ),
                        const SizedBox(width: 10), // Add spacing between buttons
                        SizedBox(
                          width: 60,
                          height: 60,
                          child: ElevatedButton(
                            onPressed: () async {
                              try {
                                await UserModel.User().signInWithGoogle();
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(builder: (context) => GettingStartedPage()),
                                );
                              } on FirebaseAuthException catch (e) {
                                debugPrint('Sign-in failed: ${e.code}');
                              } catch (e) {
                                debugPrint('An unexpected error occurred: $e');
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF1877F2),
                              padding: EdgeInsets.zero,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: Image.asset('assets/images/facebook_logo.png', height: 24.0),
                          ),
                        ),
                        const SizedBox(width: 10),
                        SizedBox(
                          width: 60,
                          height: 60,
                          child: ElevatedButton(
                            onPressed: () async {
                              try {
                                await UserModel.User().signInWithGoogle();
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(builder: (context) => GettingStartedPage()),
                                );
                              } on FirebaseAuthException catch (e) {
                                debugPrint('Sign-in failed: ${e.code}');
                              } catch (e) {
                                debugPrint('An unexpected error occurred: $e');
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF000000),
                              padding: EdgeInsets.zero,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: Image.asset('assets/images/apple_logo.png', height: 24.0),
                          ),
                        ),
                      ],
                    )
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