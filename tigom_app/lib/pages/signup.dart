import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});
@override
  State<SignUpPage> createState() => _SignUpPageState();
}


class _SignUpPageState extends State<SignUpPage> {
  bool _obscurePassword = true; 
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF9E9),
      appBar: AppBar(
        toolbarHeight: 100,
        title: Text(
          'TIGOM',
          style: TextStyle(
            color: Color(0xFFE2520B),
            fontSize: 40,
          )
        ),
        backgroundColor: Color(0xFFfff9e9),
        elevation: 0.0,
        iconTheme: IconThemeData(
          color: const Color(0xFF1D3867),
        ),
      ),


      body: SafeArea(
        child: Center(
        child: Padding( 
          padding: const EdgeInsets.symmetric(
            horizontal: 32,
          ),
        child: Column( 
          
          children: [
            Text(
              'Create an Account',
              style: TextStyle(
                color: const Color(0xFF1D3867),
                fontFamily: 'Amarante',
                fontSize:32,
              ),
            ),

            const SizedBox(height: 48),
            TextField(
              controller: usernameController,
              style: TextStyle(
                color: const Color(0xFF1D3867),
                fontFamily: 'Amarante',
              ),
              decoration: InputDecoration(
                labelText: 'Username', 
                labelStyle: TextStyle(
                  color: const Color(0xFF1D3867),
                  fontFamily: 'Amarante',
                ),
                prefixIcon: Icon(
                  Icons.person_outline,
                  color: const Color(0xFF1D3867),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide(color: Color(0xFF1D3867)),
                ),
              ),

            ),



            //email
            const SizedBox(height: 30),
            TextField(
              controller: emailController,
              style: TextStyle(
                color: Color(0xFF1D3867),
                fontFamily: 'Amarante',
              ),
              decoration: InputDecoration(
                labelText: 'Email',
                labelStyle: TextStyle(
                  color: Color(0xFF1D3867),
                  fontFamily: 'Amarante',
                ),
                prefixIcon: Icon(
                  Icons.mail_outline,
                  color: Color(0xFF1D3867),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide(color: Color(0xFF1D3867)),
                ),
              ),
            ),


            const SizedBox(height: 30),
            TextField(
              controller: passwordController,
              obscureText: _obscurePassword,
              style: TextStyle(
                color: Color(0xFF1D3867),
                fontFamily: 'Amarante',
              ),
              decoration: InputDecoration(
                labelText: 'Password',
                labelStyle: TextStyle(
                  color: Color(0xFF1D3867),
                  fontFamily: 'Amarante',
                ),
                prefixIcon: Icon(
                  Icons.lock_outline,
                  color: Color(0xFF1D3867),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide(color: Color(0xFF1D3867)),
                ),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                    color: Color(0xFF1D3867)
                  ),
                  onPressed: (){
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                ),
              ),
            ),



            const SizedBox(height: 30),
            TextField(
              controller: confirmPasswordController,
              obscureText: _obscurePassword,
              style: TextStyle(
                color: Color(0xFF1D3867),
                fontFamily: 'Amarante',
              ),
              decoration: InputDecoration(
                labelText: 'Confirm Password',
                labelStyle: TextStyle(
                  color: Color(0xFF1D3867),
                  fontFamily: 'Amarante',
                ),
                prefixIcon: Icon(
                  Icons.lock_outline,
                  color: Color(0xFF1D3867),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide(color: Color(0xFF1D3867)),
                ),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                    color: Color(0xFF1D3867)
                  ),
                  onPressed: (){
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                ),
              ),
            ),
 

            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: ()async{
                  if(passwordController.text != confirmPasswordController.text){
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Passwords do not match."),
                        ),
                      );
                      return;
                  }

                  try{

                   await Supabase.instance.client.auth.signUp(
                    email: emailController.text.trim(),
                    password: passwordController.text.trim(),

                    data: {
                      'username': usernameController.text.trim(),
                    },
                  );

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Account created successfully"),
                    ),
                  );

                  Navigator.pushNamed(context, '/login');

                } catch (e) {

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(e.toString()),
                    ),
                  );
                }

                },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF1D3867),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: const StadiumBorder(),
              ),
              child: const Text(
                'SIGN UP',
                style: TextStyle(
                  color: Color(0xFFFFF9E9),
                  fontFamily: 'Amarante',
                  fontSize: 16,
                ),
              ),
              ),
            ),



          ],
        ),
        ),
        ),
      ),
    );
  }
}