import 'package:flutter/material.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF9E9),

      body: Stack(
        children: [
          
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 260,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/pattern.png'),
                  fit: BoxFit.cover,
                ),
              ),
              child: const Center(
                child: Text(
                  'TIGOM',
                  style: TextStyle(
                    fontSize: 70,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: 6,
                    shadows: [
                      Shadow(
                        blurRadius: 2,
                        color: Colors.black45,
                        offset: Offset(-2, 2),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          
          Positioned(
            top: 220,
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              decoration: const BoxDecoration(
                color: Color(0xFFFFF9E9),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 10,
                    offset: Offset(0, -4),
                  ),
                ],
              ),

              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 40,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                    
                      Text(
                        'LOG IN',
                        style: TextStyle(
                          fontFamily: 'Amarante',
                          color: const Color(0xFF1D3867),
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 4,
                        ),
                      ),

                      const SizedBox(height: 30),

                     
                      TextField(
                        decoration: InputDecoration(
                          labelText: 'Username',
                          labelStyle: TextStyle( 
                            color: const Color(0xFF1D3867),
                            fontFamily: 'Amarante',
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: BorderSide(color: Color(0xFF1D3867)),
                          ),
                        ),

                      ),

                      const SizedBox(height: 20),

                      
                      TextField(
                        obscureText: true,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          labelStyle: TextStyle(
                            color: const Color(0xFF1D3867),
                            fontFamily: 'Amarante',
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: BorderSide(color: Color(0xFF1D3867)),
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1D3867),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: const StadiumBorder(),
                          ),
                          child: const Text(
                            'LOG IN',
                            style: TextStyle(
                              letterSpacing: 3,
                              color: Color(0xFFFFF9E9),
                              fontFamily: 'Amarante',
                            ),
                          ),
                        ),
                      ),


                      const SizedBox(height: 16),

                      Center(
                        child: RichText(
                          text: TextSpan(
                            text: "Don’t have an account? ",
                            style: TextStyle(
                              color: const Color(0xFF1D3867),
                              fontSize: 13,
                              fontFamily: 'Amarante',
                            ),
                            children: [
                              TextSpan(
                                text: "Sign Up",
                                style: TextStyle(
                                  color: Colors.red,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Amarante',
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}