import 'package:Turfease/login/Authentication/Services/adminauthenticationservice.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class adminSignin extends StatefulWidget {
  const adminSignin({Key? key}) : super(key: key);

  @override
  State<adminSignin> createState() => _SigninState();
}

class _SigninState extends State<adminSignin> {
  final _formKey = GlobalKey<FormState>();
  bool _isObscured = true;
  bool _loading = false;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final Authenticate _auth = Authenticate();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // White background
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: 50),
              ColorFiltered(
                colorFilter: ColorFilter.mode(
                  Color.fromARGB(255, 0, 102, 102), // Peacock green
                  BlendMode.srcIn,
                ),
                child: Image.asset(
                  'assets/images/logo.png', // Green logo
                  height: 150,
                ),
              ),
              SizedBox(height: 20),
              Text(
                "Sign In",
                style: TextStyle(
                  fontSize: 32,
                  color: Color.fromARGB(255, 0, 102, 102), // Peacock green
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 40),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _emailController,
                      style: TextStyle(color: Colors.black), // Black text color
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        labelStyle: TextStyle(
                            color:
                                Color.fromARGB(255, 0, 0, 0)), // Peacock green
                        focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                                color: Color.fromARGB(
                                    255, 0, 102, 102))), // Peacock green
                      ),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Please enter your email';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 20),
                    TextFormField(
                      controller: _passwordController,
                      style: TextStyle(color: Colors.black), // Black text color
                      obscureText: _isObscured,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        labelStyle: TextStyle(
                            color:
                                Color.fromARGB(255, 0, 0, 0)), // Peacock green
                        focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                                color: Color.fromARGB(
                                    255, 0, 102, 102))), // Peacock green
                        suffixIcon: IconButton(
                          icon: Icon(
                              _isObscured
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                              color: Color.fromARGB(
                                  255, 0, 102, 102)), // Peacock green
                          onPressed: () {
                            setState(() {
                              _isObscured = !_isObscured;
                            });
                          },
                        ),
                      ),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Please enter your password';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
              SizedBox(height: 40),
              ElevatedButton(
                onPressed: _submit,
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                  backgroundColor:
                      Color.fromARGB(255, 0, 102, 102), // Peacock green
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30)),
                ),
                child: _loading
                    ? CircularProgressIndicator(color: Colors.white)
                    : Text("SIGN IN",
                        style: TextStyle(fontSize: 18, color: Colors.white)),
              ),
              
                   
                
                ],
              ),
         
          ),
        ),
     
    );
  }

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _loading = true;
      });
      try {
        await _auth.signinwithEmail(
          context: context,
          email: _emailController.text.toLowerCase(),
          password: _passwordController.text,
        );
        // If authentication succeeds, navigate to HomeScreen

        // Clear text fields after successful sign-in
        _emailController.clear();
        _passwordController.clear();
      } on FirebaseAuthException catch (e) {
        setState(() {
          _loading = false;
        });
        if (e.code == 'user-not-found') {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('User not found!'),
            ),
          );
        } else if (e.code == 'wrong-password') {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Wrong password'),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Something went wrong!'),
            ),
          );
        }
      }
    }
  }
}
