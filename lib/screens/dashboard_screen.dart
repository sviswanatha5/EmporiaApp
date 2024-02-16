import "package:firebase_auth/firebase_auth.dart";
import "package:flutter/material.dart";
import "package:practice_project/screens/product_page.dart";
/*
class FirstScreen extends StatelessWidget {
  const FirstScreen({super.key});

  void signUserOut() {
    FirebaseAuth.instance.signOut();
  }

 
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: Text("LOGGED IN")),
      appBar: AppBar(actions: [
        IconButton(onPressed: signUserOut, icon: Icon(Icons.logout))
      ]),
    );
  }
  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dashboard'),
      ),
      body: Center(
        child: widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.deepPurple,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
    );
  }
}
*/

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;
  TextEditingController _searchController = TextEditingController();

  void signUserOut() {
    FirebaseAuth.instance.signOut();
  }

  // Dummy data for demonstration purposes

  final String _email = FirebaseAuth.instance.currentUser!.email.toString();
  final List<String> _allItems = [
    'computer',
    'pencil',
    'shirt',
    'desk',
    'headphone',
    'backpack',
    'book'
        'bag'
  ];
  List<String> _searchResults = [];

  // Search functionality
  void _runFilter(String enteredKeyword) {
    List<String> results = [];
    if (enteredKeyword.isEmpty) {
      results = _allItems;
    } else {
      results = _allItems
          .where((item) =>
              item.toLowerCase().contains(enteredKeyword.toLowerCase()))
          .toList();
    }
    setState(() {
      _searchResults = results;
    });
  }

  @override
  void initState() {
    super.initState();
    _searchResults = _allItems;
    _searchController.addListener(() {
      _runFilter(_searchController.text);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Widget homeWidget() {
    return ProductPage();
  }

  Widget searchWidget() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: TextField(
            controller: _searchController,
            decoration: const InputDecoration(
              labelText: 'Search',
              suffixIcon: Icon(Icons.search),
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: _searchResults.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(_searchResults[index]),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget profileWidget() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding:  EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            'Profile',
            style: TextStyle(fontSize: 35, fontWeight: FontWeight.bold),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Text('Email: $_email'),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: OutlinedButton(
            onPressed: () {
              // TODO
            },
            child: const Text('Edit Profile'),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: OutlinedButton(
            onPressed: () {
              signUserOut();
            },
            child: const Text('Logout'),
          ),
        ),
      ],
    );
  }

  List<Widget> get widgetOptions =>
      [homeWidget(), searchWidget(), profileWidget()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dashboard'),
      ),
      body: Center(
        child: widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.deepPurple,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
    );
  }
}
