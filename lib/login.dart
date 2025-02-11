import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'home_page.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  bool _obscureText = true;
  String? _usernameError;
  String? _passwordError;

  Future<void> login(BuildContext context) async {
    final username = usernameController.text.trim();
    final password = passwordController.text.trim();

    setState(() {
      _usernameError = username.isEmpty ? 'Username kosong' : null;
      _passwordError = password.isEmpty ? 'Password kosong' : null;
    });

    if (username.isEmpty || password.isEmpty) {
      return;
    }

    try {
      final response = await Supabase.instance.client
          .from('users')
          .select()
          .eq('username', username)
          .single();

      if (response.isNotEmpty) {
        final dbPassword = response['password'];
        final role = response['role'];  // Assuming 'role' is a field in your 'users' table

        if (dbPassword == password) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => HomePage(
                title: 'home',
                username: username,
                role: role,
              ),
            ),
          );
        } else {
          setState(() {
            _passwordError = 'Password Salah';
            _usernameError = null;
          });
        }
      }
    } catch (e) {
      setState(() {
        _usernameError = 'Username Salah';
        _passwordError = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            width: MediaQuery.of(context).size.width * 0.9,
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                Text("Welcome", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 26)),
                SizedBox(height: 10),
                Text("Please login to continue", style: TextStyle(color: Colors.black54, fontSize: 16)),
                SizedBox(height: 30),
                TextField(
                  controller: usernameController,
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.person, color: Colors.black),
                    hintText: "Username",
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(15.0)),
                    errorText: _usernameError,
                    filled: true,
                    fillColor: Colors.grey[200],
                  ),
                ),
                SizedBox(height: 16),
                TextField(
                  controller: passwordController,
                  obscureText: _obscureText,
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.lock, color: Colors.black),
                    suffixIcon: IconButton(
                      icon: Icon(_obscureText ? Icons.visibility : Icons.visibility_off, color: Colors.black),
                      onPressed: () {
                        setState(() {
                          _obscureText = !_obscureText;
                        });
                      },
                    ),
                    hintText: "Password",
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(15.0)),
                    errorText: _passwordError,
                    filled: true,
                    fillColor: Colors.grey[200],
                  ),
                ),
                SizedBox(height: 20),
                MaterialButton(
                  onPressed: () => login(context),
                  color: Color(0xff3a57e8),
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
                  padding: EdgeInsets.all(16),
                  child: Text("Login", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                  textColor: Color(0xffffffff),
                  height: 50,
                  minWidth: MediaQuery.of(context).size.width,
                ),
                SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
