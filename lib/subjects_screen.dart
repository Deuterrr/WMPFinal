import 'package:flutter/material.dart';
import 'package:wmp_final_app/myenrollment_page.dart';
import 'package:wmp_final_app/widgets/customappbar.dart';
import 'database_helper.dart';

class SubjectsScreen extends StatefulWidget {
  @override
  _SubjectsScreenState createState() => _SubjectsScreenState();
}

class _SubjectsScreenState extends State<SubjectsScreen> {
  List<Map<String, dynamic>> _subjects = [];
  String? _loggedInStudentId;
  static const int maxCredits = 24;

  Future<String?> getEmailfromLoginStatus() async {
    final db = await DatabaseHelper().database;
    final List<Map<String, dynamic>> result = await db.query(
      'loginstatus',
      columns: ['email'],
      limit: 1,
    );

    if (result.isNotEmpty) {
      return result.first['email'] as String?;
    }
    return null;
  }

  Future<void> _fetchSubjects() async {
    final db = await DatabaseHelper().database;
    final result = await db.query('subjects');
    setState(() {
      _subjects = result;
    });
  }

  Future<void> _enrollInSubject(int subjectId, int subjectCredit) async {
    final db = await DatabaseHelper().database;

    final result = await db.query(
      'enrollments',
      where: 'student_id = ? AND subject_id = ?',
      whereArgs: [_loggedInStudentId, subjectId],
    );

    if (result.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Already enrolled in this subject'), duration: Duration(milliseconds: 700)),
      );
      return;
    }

    // check total credits
    final totalCredits = await DatabaseHelper().getTotalCredits(_loggedInStudentId!);

    if (totalCredits + subjectCredit > maxCredits) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Credit limit of $maxCredits exceeded'),
          duration: Duration(milliseconds: 700),
        ),
      );
      return;
    }

    // insert enrollment
    await db.insert('enrollments', {
      'student_id': _loggedInStudentId,
      'subject_id': subjectId,
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Enrolled successfully'),
        duration: Duration(milliseconds: 700),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _loadLoggedInStudentId();
  }

  // load the logged-in student ID asynchronously
  Future<void> _loadLoggedInStudentId() async {
    String? email = await getEmailfromLoginStatus();
    setState(() {
      _loggedInStudentId = email;
    });
    _fetchSubjects();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'Subject Enrollment'),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Text(
                'Menu',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.assignment),
              title: Text('My Enrollment'),
              onTap: () async {
                if (_loggedInStudentId != null) {
                  await _fetchSubjects();
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => MyEnrollmentPage(studentId: _loggedInStudentId!)),
                  );
                } else {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: Text('Login Required'),
                        content: Text('You must log in first to access this feature.'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text('OK'),
                          ),
                        ],
                      );
                    },
                  );
                }
              },
            )
          ],
        ),
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: 
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: _subjects.isEmpty
              ? Center(child: CircularProgressIndicator())
              : DataTable(
                  columns: [
                    DataColumn(label: Text('ID')),
                    DataColumn(label: Text('Name')),
                    DataColumn(label: Text('Description')),
                    DataColumn(label: Text('Credit')),
                    DataColumn(label: Text('Actions')),
                  ],
                  rows: _subjects.map(
                    (subject) => DataRow(cells: [
                      DataCell(Text(subject['id'].toString())),
                      DataCell(Text(subject['name'])),
                      DataCell(Text(subject['description'])),
                      DataCell(Text(subject['credit'].toString())),
                      DataCell(
                        ElevatedButton(
                          onPressed: () {
                            if (_loggedInStudentId != null) {
                              _enrollInSubject(subject['id'], subject['credit']);
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('You need to log in first')),
                              );
                            }
                          },
                          child: Text('Enroll'),
                        ),
                      ),
                    ]),
                  ).toList(),
                ),
        ),
      )
    );
  }
}

