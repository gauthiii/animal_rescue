import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
// import 'dashboard.dart';
import 'nav.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _isLoading = false;
  bool _isRegistering = false;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkIfUserIsLoggedIn();
    });
  }

  void _checkIfUserIsLoggedIn() {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => NavbarScreen(user: user)),
      );
    }
  }

  Future<User?> _signInWithGoogle() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final GoogleSignIn googleSignIn = GoogleSignIn();
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      if (googleUser != null) {
        final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
        final AuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );
        UserCredential userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
        return userCredential.user;
      }
    } catch (e) {
      print('Error signing in with Google: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }

    return null;
  }

  Future<void> _signInWithEmailPassword() async {
    setState(() {
      _isLoading = true;
    });

    try {
      UserCredential userCredential;
      if (_isRegistering) {
        userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _emailController.text,
          password: _passwordController.text,
        );
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Registration successful! Please log in.')),
        );
      } else {
        userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: _emailController.text,
          password: _passwordController.text,
        );
      }
      if (userCredential.user != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => NavbarScreen(user: userCredential.user!)),
        );
      }
    } catch (e) {
      print('Error with email/password authentication: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('images/wall2.png'),
            opacity: 0.6,
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(height: 80),
              Stack(
  children: [
    // Outer text for stroke effect
    Text(
      'Animal Rescue',
      style: TextStyle(
        fontSize: 50,
        fontWeight: FontWeight.bold,
        fontFamily: "Bangers",
        foreground: Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3 // Adjust stroke width as needed
          ..color = Color.fromARGB(255, 219, 153, 106), // Stroke color
      ),
    ),
    // Inner text for fill
    Text(
      'Animal Rescue',
      style: TextStyle(
        fontSize: 50,
        fontWeight: FontWeight.bold,
        fontFamily: "Bangers",
        color: Color.fromARGB(255, 7, 7, 7), // Fill color
      ),
    ),
  ],
),

              const SizedBox(height: 40),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32.0),
                child: Column(
                  children: [
                    TextField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        hintText: 'Email',
                        filled: true,
                        fillColor: Colors.grey[200],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15.0),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _passwordController,
                      decoration: InputDecoration(
                        hintText: 'Password',
                        filled: true,
                        fillColor: Colors.grey[200],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15.0),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      obscureText: true,
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _signInWithEmailPassword,
                      child: Text(_isRegistering ? 'Register' : 'Log In'),
                    ),
                   
                  ],
                ),
              ),
              const SizedBox(height: 10),
              _isLoading
                  ? const CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                    )
                  : ElevatedButton(
                      onPressed: () async {
                        User? user = await _signInWithGoogle();
                        if (user != null) {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => NavbarScreen(user: user)),
                          );
                        }
                      },
                      child: const Text('Sign in with Google'),
                    ),
                    Container(height: 50,),
                     TextButton(
                      onPressed: () {
                        setState(() {
                          _isRegistering = !_isRegistering;
                        });
                      },
                      child: Text(
                        _isRegistering ? 'Already have an account? Log in' : 'Don\'t have an account? Register',
                        style: const TextStyle(color: Color.fromARGB(255, 255, 255, 255)),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
