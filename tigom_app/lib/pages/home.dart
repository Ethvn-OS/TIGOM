import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFfff9e9),
      appBar: AppBar(
        toolbarHeight: 100,
        title: Text(
          'TIGOM',
          style: TextStyle(
            fontFamily: 'RuslanDisplay',
            color: Color(0xFFE2520B),
            fontSize: 40,
          )
        ),
        backgroundColor: Color(0xFFfff9e9),
        elevation: 0.0,
      ),
      body: Column( // Current Balance Box
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            height: 200,
            margin: EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              color: Color(0XFF1d3867),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  spreadRadius: 5,
                  blurRadius: 7,
                  offset: Offset(0,3)
                )
              ]
            ),
            child: Row(
              children: [
                // Left Side
                Container(
                  width: 120,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    image: DecorationImage(
                      image: AssetImage('assets/flag_pattern.png'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                // Right side
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Current Balance:',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Php 3,000.00',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.bold
                          )
                        )
                      ],
                    )
                  )
                )
              ]
            )
          ),
          Column( // Savings Box (Physical Cash, E - Wallet, Bank)
            children: [
              SizedBox(height: 24),
              Container(
                height: 50,
                margin: EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  color: Color(0xFFe4be74),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16)
                  )
                ),
                child: Row(
                  children: [
                    Container(
                      height: 30,
                      width: 330,
                      margin: EdgeInsets.symmetric(horizontal: 20),
                      decoration: BoxDecoration(
                        color: Color(0xFFfff9e9),
                        borderRadius: BorderRadius.circular(16)
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Center(
                              child: Text(
                                'Physical Cash',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF1D3867)
                                )
                              )
                            )
                          ),
                          Expanded(
                            child: Container(
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: const Color(0xFF1D3867),
                                borderRadius: BorderRadius.circular(20)
                              ),
                              child: const Text(
                                'E-Wallet',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600
                                )
                              )
                            )
                          ),
                          Expanded(
                            child: Center(
                              child: Text(
                                'Bank',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF1D3867)
                                )
                              )
                            )
                          )
                        ],
                      )
                    ),
                  ],
                ),
              ),
              Container(
                height: 100,
                margin: EdgeInsets.symmetric(horizontal: 20),
                padding: EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: Color(0xFFfce7ba),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(16),
                    bottomRight: Radius.circular(16)
                  )
                ),
                child: Row(
                  children: [
                    Align(
                      alignment: Alignment.topLeft,
                      child: Text(
                        'Php',
                        style: TextStyle(
                          fontSize: 18,
                          color: Color(0xFF1D3867)
                        )
                      )
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Center(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            '307.00',
                            style: TextStyle(
                              fontSize: 54,
                              height: 1.0,
                              color: Color(0xFF1D3867),
                              fontWeight: FontWeight.w700
                            )
                          )
                        )
                      )
                    ),
                    Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0xFF1D3867),
                          width: 2,
                        )
                      ),
                      child: const Icon(
                        Icons.add,
                        size: 18,
                        color: Color(0xFF1D3867)
                      )
                    )
                  ],
                )
              )
            ],
          )
        ]
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Color(0XFF1d3867),
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.grey,
        items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.add_road), label: 'Plans'),
        BottomNavigationBarItem(icon: Icon(Icons.access_time), label: 'History'),
        BottomNavigationBarItem(icon: Icon(Icons.face), label: 'Profile'),
        ],
      ),
    );
  }
}

/*

child: Row(
  children: [
    Expanded(
      child: Center(
        child: Text(
          'Physical Cash',
          style: TextStyle(
            fontSize: 12,
            color: Color(0xFF1D3867)
          )
        )
      )
    ),
    Expanded(
      child: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: const Color(0xFF1D3867),
          borderRadius: BorderRadius.circular(20)
        ),
        child: const Text(
          'E-Wallet',
          style: TextStyle(
            fontSize: 12,
            color: Colors.white,
            fontWeight: FontWeight.w600
          )
        )
      )
    ),
    Expanded(
      child: Center(
        child: Text(
          'Bank',
          style: TextStyle(
            fontSize: 12,
            color: Color(0xFF1D3867)
          )
        )
      )
    )
  ]
)

*/