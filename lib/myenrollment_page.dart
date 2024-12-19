import 'package:flutter/material.dart';
import 'database_helper.dart';

class MyEnrollmentPage extends StatefulWidget {
  final String studentId; // email or student Id

  MyEnrollmentPage({required this.studentId});

  @override
  _MyEnrollmentPageState createState() => _MyEnrollmentPageState();
}

class _MyEnrollmentPageState extends State<MyEnrollmentPage> {
  List<Map<String, dynamic>> _enrolledSubjects = [];

  Future<void> _fetchEnrolledSubjects() async {
    final db = await DatabaseHelper().database;
    final result = await db.rawQuery('''
      SELECT subjects.id, subjects.name, subjects.description, subjects.credit
      FROM enrollments
      INNER JOIN subjects ON enrollments.subject_id = subjects.id
      WHERE enrollments.student_id = ?
    ''', [widget.studentId]);

    setState(() {
      _enrolledSubjects = result;
    });
  }

  @override
  void initState() {
    super.initState();
    _fetchEnrolledSubjects();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("My Enrollment")),
      body: _enrolledSubjects.isEmpty
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  ListView.builder(
                    physics: NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: _enrolledSubjects.length,
                    itemBuilder: (context, index) {
                      final subject = _enrolledSubjects[index];
                      return Card(
                        margin: EdgeInsets.all(8),
                        child: ListTile(
                          title: Text(subject['name']),
                          subtitle: Text(subject['description']),
                          trailing: Text('${subject['credit']} Credits'),
                          isThreeLine: true,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
    );
  }
}
