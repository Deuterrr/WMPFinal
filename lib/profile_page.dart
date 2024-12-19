import 'package:flutter/material.dart';
import 'package:wmp_final_app/login_screen.dart';
import 'database_helper.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String? _email;
  String? _name;
  final _nameController = TextEditingController();

  // get, or fetch, user details (email and name)
  Future<void> _fetchUserDetails() async {
    final db = await DatabaseHelper().database;

    // email from the loginstatus table
    final loginResult = await db.query(
      'loginstatus',
      columns: ['email'],
      limit: 1,
    );

    if (loginResult.isNotEmpty) {
      final email = loginResult.first['email'] as String?;

      // if email exists, fetch user details from students table
      if (email != null) {
        final studentResult = await db.query(
          'students',
          columns: ['email', 'name'],
          where: 'email = ?',
          whereArgs: [email],
          limit: 1,
        );

        if (studentResult.isNotEmpty) {
          setState(() {
            _email = studentResult.first['email'] as String?;
            _name = studentResult.first['name'] as String?;
            _nameController.text = _name ?? ''; // set name in the TextFormField, but feels odd
          });
        }
      }
    }
  }

  // update the name in the database
  Future<void> _updateName() async {
    final db = await DatabaseHelper().database;
    
    await db.update(
      'students',
      {'name': _nameController.text},
      where: 'email = ?',
      whereArgs: [_email],
    );

    setState(() {
      _name = _nameController.text;
    });

    // show confirmation message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Name updated successfully!')),
    );
  }

  // logout and clear the loginstatus table
  Future<void> _logout() async {
    final db = await DatabaseHelper().database;

    await db.delete('loginstatus');
    
    Navigator.pushReplacement(
      context, MaterialPageRoute(builder: (context) => LoginScreen())
    );
  }

  @override
  void initState() {
    super.initState();
    _fetchUserDetails();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Profile')),
      body: _email == null || _name == null
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Email: $_email',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Name:',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      hintText: 'Enter your name',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _updateName,
                    child: Text('Update Name'),
                    style: ElevatedButton.styleFrom(
                      iconColor: Colors.green,
                    ),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _logout,
                    child: Text('Logout'),
                    style: ElevatedButton.styleFrom(
                      iconColor: Colors.red,
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
