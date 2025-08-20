import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:fitness_app/getting_started_page.dart';


class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  Future<UserCredential?> signInWithGoogle() async {
    UserCredential? userCredential;

    try {
      await GoogleSignIn.instance.initialize();
      final GoogleSignInAccount googleUser = await GoogleSignIn.instance.authenticate();
      final GoogleSignInAuthentication googleAuth = googleUser.authentication;
      final credential = GoogleAuthProvider.credential(idToken: googleAuth.idToken);
      userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
    } on FirebaseAuthException catch (e) {
      print('Sign-in failed: ${e.code}');
    } catch (e) {
      print('An unexpected error occurred: $e');
    }

    return userCredential;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
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
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        var userCredential = await signInWithGoogle();
                        if (userCredential != null) {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => GettingStartedPage(user: userCredential.user)),
                          );
                        }
                      },
                      label: const Text("Sign in with Google"),
                      icon: Image.asset('assets/images/google_logo.png', height: 24.0),
                    ),
                  ),
                  const SizedBox(height: 10), // Add spacing between buttons
                  SizedBox(
                    width: 300, // Adjust this width as needed
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        var userCredential = await signInWithGoogle();
                        if (userCredential != null) {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => GettingStartedPage(user: userCredential.user)),
                          );
                        }
                      },
                      label: const Text(
                        "Sign in with Facebook",
                        style: TextStyle(color: Colors.white),
                      ),
                      icon: Image.asset('assets/images/facebook_logo.png', height: 24.0),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1877F2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10), // Add spacing between buttons
                  SizedBox(
                    width: 300, // Adjust this width as needed
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        var userCredential = await signInWithGoogle();
                        if (userCredential != null) {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => GettingStartedPage(user: userCredential.user)),
                          );
                        }
                      },
                      label: const Text(
                        "Sign in with Apple",
                        style: TextStyle(color: Colors.white),
                      ),
                      icon: Image.asset('assets/images/apple_logo.png', height: 24.0),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF000000),
                      ),
                    ),
                  ),
                ],
              )
            ],
          )
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
      padding: const EdgeInsets.all(30.0),
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