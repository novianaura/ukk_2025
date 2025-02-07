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

    //ketika username atau password tidak isi akan muncul validasi ini
    setState(() {
      _usernameError = username.isEmpty ? 'Username kosong' : null;
      _passwordError = password.isEmpty ? 'Password kosong' : null;
    });

    if (username.isEmpty || password.isEmpty) {
      return;
    }
    //mengambil dari supabasenya
    try {
      final response = await Supabase.instance.client
          .from('users')
          .select()
          .eq('username', username)
          .eq('password', password)
          .single();

      //untuk ketika data sudah valid akan mengirim ke halaman selanjutnya
      if (response.isNotEmpty) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => HomePage(title: 'home',
            ),
          ),
        );
      } else { //namun ketika username atau password yang dimasukkan salah akan muncul validasi ini
        setState(() {
          _usernameError = 'Username Salah' ;
          _passwordError = 'Password Salah'; 
        });
      }
    } catch (e) {
      setState(() {
        _usernameError = 'Username Salah';
        _passwordError = 'Password Salah';
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
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  blurRadius: 5,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: 20),
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
                    //ini untuk bagian icon mata di password agar bisa dilihat atau tidak
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
                  onPressed: () => login(context), //untuk proses login agar bisa berfungsi
                      color: Color(0xff3a57e8),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16.0),
                      ),
                      padding: EdgeInsets.all(16),
                      child: Text(
                        "Login",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          fontStyle: FontStyle.normal,
                        ),
                      ),
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

