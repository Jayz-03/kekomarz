import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kekomarz/screens/cart/cart.dart';
import 'package:kekomarz/screens/favorites/favorites.dart';
import 'package:kekomarz/screens/home/home.dart';
import 'package:kekomarz/screens/inbox/inbox.dart';
import 'package:kekomarz/screens/profile/profile.dart';

class ButtomNavTab extends StatefulWidget {
  @override
  _ButtomNavTabState createState() => _ButtomNavTabState();
}

class _ButtomNavTabState extends State<ButtomNavTab> {
  int _selectedIndex = 2;

  static List<Widget> _widgetOptions = <Widget>[
    ProfileScreen(),
    CartScreen(),
    HomeScreen(),
    FavoritesScreen(),
    InboxScreen(),
  ];

  @override
  void initState() {
    super.initState();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 200, 164, 212),
        title: Image.asset(
          'assets/images/kekomarz-logo.png',
          width: 120,
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: InkWell(
                onTap: () {},
                child: Icon(
                  Icons.notifications,
                  color: Color.fromARGB(255, 59, 27, 13),
                  size: 30,
                )),
          ),
        ],
      ),
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: Theme(
        data: Theme.of(context).copyWith(
          canvasColor: Color.fromARGB(255, 100, 59, 159),
          primaryColor: Colors.white,
          textTheme: Theme.of(context).textTheme.copyWith(
                bodySmall: GoogleFonts.robotoCondensed(color: Colors.white70),
              ),
        ),
        child: BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'Profile',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.shopping_cart),
              label: 'Cart',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.favorite),
              label: 'Favorite',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.mail),
              label: 'Inbox',
            ),
          ],
          currentIndex: _selectedIndex,
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.white70,
          selectedLabelStyle: GoogleFonts.robotoCondensed(
              color: Color.fromARGB(255, 55, 28, 28), fontSize: 12.0),
          unselectedLabelStyle: GoogleFonts.robotoCondensed(
              color: Colors.white70, fontSize: 12.0),
          showSelectedLabels: true,
          showUnselectedLabels: true,
          onTap: _onItemTapped,
        ),
      ),
    );
  }
}
