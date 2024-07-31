import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase/main.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class EmployeeTracker extends StatefulWidget {
  final User user;
  final Function toggleTheme;

  const EmployeeTracker(
      {super.key, required this.user, required this.toggleTheme});

  @override
  EmployeeTrackerState createState() => EmployeeTrackerState();
}

class EmployeeTrackerState extends State<EmployeeTracker> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ImagePicker _picker = ImagePicker();
  int totalSum = 0;
  Future<void> _pickAndUploadImage(String employeeId) async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      File imageFile = File(pickedFile.path);

      try {
        final ref = FirebaseStorage.instance
            .ref()
            .child('employee_images/$employeeId.jpg');
        await ref.putFile(imageFile);
        final imageUrl = await ref.getDownloadURL();
        await _firestore
            .collection('users')
            .doc(widget.user.uid)
            .collection('employees')
            .doc(employeeId)
            .update({'imageUrl': imageUrl});

        setState(() {}); // Refresh UI
      } catch (e) {
        print('Failed to upload image: $e');
      }
    }
  }

  void _addEmployee(String name, int dailyWage, String yarimKun) {
    _firestore
        .collection('users')
        .doc(widget.user.uid)
        .collection('employees')
        .add({
      'name': name,
      'dailyWage': dailyWage,
      'phoneNumber': yarimKun,
      'workedDays': {},
    });
  }

  void _markTodayAsWorked(String employeeId) async {
    String todayString = DateTime.now().toIso8601String().split('T')[0];
    DocumentSnapshot doc = await _firestore
        .collection('users')
        .doc(widget.user.uid)
        .collection('employees')
        .doc(employeeId)
        .get();
    Map<String, bool> workedDays = Map<String, bool>.from(doc['workedDays']);
    workedDays[todayString] = true;

    await _firestore
        .collection('users')
        .doc(widget.user.uid)
        .collection('employees')
        .doc(employeeId)
        .update({
      'workedDays': workedDays,
    });

    setState(() {}); // Rebuild the UI to reflect changes
  }

  void _subtractWorkedDays(String employeeId, int daysToSubtract) async {
    DocumentSnapshot doc = await _firestore
        .collection('users')
        .doc(widget.user.uid)
        .collection('employees')
        .doc(employeeId)
        .get();
    Map<String, bool> workedDays = Map<String, bool>.from(doc['workedDays']);
    List<String> workedDaysList = workedDays.keys.toList()
      ..sort((a, b) => a.compareTo(b)); // Sort in ascending order

    for (int i = 0; i < daysToSubtract && workedDaysList.isNotEmpty; i++) {
      String earliestDay = workedDaysList.removeAt(0); // Remove from the front
      workedDays.remove(earliestDay);
    }

    await _firestore
        .collection('users')
        .doc(widget.user.uid)
        .collection('employees')
        .doc(employeeId)
        .update({
      'workedDays': workedDays,
    });

    setState(() {}); // Rebuild the UI to reflect changes
  }

  void _subtractAllWorkedDays(String employeeId) async {
    await _firestore
        .collection('users')
        .doc(widget.user.uid)
        .collection('employees')
        .doc(employeeId)
        .update({
      'workedDays': {},
    });

    setState(() {}); // Rebuild the UI to reflect changes
  }

  void _deleteEmployee(String employeeId) async {
    await _firestore
        .collection('users')
        .doc(widget.user.uid)
        .collection('employees')
        .doc(employeeId)
        .delete();

    setState(() {}); // Rebuild the UI to reflect changes
  }

  Future<String?> _getImageUrl(String employeeId) async {
    try {
      final ref = FirebaseStorage.instance
          .ref()
          .child('employee_images/$employeeId.jpg');
      final url = await ref.getDownloadURL();
      return url;
    } catch (e) {
      print('Failed to get image URL: $e');
      return null;
    }
  }

  void _showAddEmployeeDialog() {
    final nameController = TextEditingController();
    final wageController = TextEditingController();
    final phoneController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Employee'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Ism'),
              ),
              TextField(
                controller: wageController,
                decoration: const InputDecoration(labelText: 'Kunlik narhi'),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('chiqish'),
            ),
            TextButton(
              onPressed: () {
                String name = nameController.text;
                int wage = int.parse(wageController.text);
                String phoneNumber = phoneController.text;
                _addEmployee(name, wage, phoneNumber);
                Navigator.of(context).pop();
              },
              child: const Text('qo\'shish'),
            ),
          ],
        );
      },
    );
  }

  void _showEditEmployeeDialog(String employeeId, String currentName,
      int currentWage, String currentPhone) {
    final nameController = TextEditingController(text: currentName);
    final wageController = TextEditingController(text: currentWage.toString());
    final phoneController = TextEditingController(text: currentPhone);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('O\'zgartirish'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Ismi'),
              ),
              TextField(
                controller: wageController,
                decoration: const InputDecoration(labelText: 'Kunlik narhi'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: phoneController,
                decoration: const InputDecoration(labelText: 'Yarim kun'),
                keyboardType: TextInputType.phone,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                String name = nameController.text;
                int wage = int.parse(wageController.text);
                String phoneNumber = phoneController.text;
                _firestore
                    .collection('users')
                    .doc(widget.user.uid)
                    .collection('employees')
                    .doc(employeeId)
                    .update({
                  'name': name,
                  'dailyWage': wage,
                  'phoneNumber': phoneNumber,
                });
                Navigator.of(context).pop();
              },
              child: const Text('Saqlash'),
            ),
          ],
        );
      },
    );
  }

  void _showSubtractDaysDialog(String employeeId) {
    final daysController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('kunlarni ayirish'),
          content: TextField(
            controller: daysController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Necha kunni ayirish kerak',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                int daysToSubtract = int.tryParse(daysController.text) ?? 0;
                if (daysToSubtract > 0) {
                  _subtractWorkedDays(employeeId, daysToSubtract);
                }
                Navigator.of(context).pop();
              },
              child: const Text('Saqlash'),
            ),
          ],
        );
      },
    );
  }

  void _showCalendar(
      String employeeId, Map<String, bool> workedDays, String name) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => CalendarPage(
          userId: widget.user.uid,
          employeeId: employeeId,
          workedDays: workedDays,
          name: name,
        ),
      ),
    );
  }

  void _signOut() async {
    await FirebaseAuth.instance.signOut();
    await GoogleSignIn().signOut();
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
          builder: (context) => SignInPage(toggleTheme: widget.toggleTheme)),
    );
  }

  @override
  Widget build(BuildContext context) {
    String todayString = DateTime.now().toIso8601String().split('T')[0];
    String formattedDate = DateFormat('MMMM d, y').format(DateTime.now());
    return Scaffold(
      appBar: AppBar(
        title: Text(
          formattedDate,
          style: const TextStyle(fontSize: 16),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.brightness_6),
            onPressed: () => widget.toggleTheme(),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _signOut,
          ),
        ],
      ),
      body: StreamBuilder(
        stream: _firestore
            .collection('users')
            .doc(widget.user.uid)
            .collection('employees')
            .snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) return const CircularProgressIndicator();

          totalSum = 0; // Reset totalSum before calculating

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: ListView(
                  children: snapshot.data!.docs.map((doc) {
                    Map<String, bool> workedDays =
                        Map<String, bool>.from(doc['workedDays']);
                    int workedDaysCount = workedDays.length;
                    int dailyWage = doc['dailyWage'];
                    totalSum += dailyWage * workedDaysCount; // Add to totalSum

                    return FutureBuilder<String?>(
                      future: _getImageUrl(doc.id),
                      builder: (context, imageSnapshot) {
                        return Slidable(
                          key: ValueKey(doc.id),
                          startActionPane: ActionPane(
                            extentRatio: 0.6,
                            motion: const ScrollMotion(),
                            children: [
                              SlidableAction(
                                spacing: 5,
                                onPressed: (context) =>
                                    _subtractAllWorkedDays(doc.id),
                                backgroundColor: Colors.orange,
                                foregroundColor: Colors.white,
                                icon: Icons.remove_circle,
                                label: 'boshatish',
                              ),
                              SlidableAction(
                                onPressed: (context) => _deleteEmployee(doc.id),
                                backgroundColor: Colors.red,
                                foregroundColor: Colors.white,
                                icon: Icons.delete,
                                label: 'Haydaldi',
                              ),
                            ],
                          ),
                          endActionPane: ActionPane(
                            extentRatio: 0.35,
                            motion: const ScrollMotion(),
                            children: [
                              SlidableAction(
                                onPressed: (context) => _showEditEmployeeDialog(
                                  doc.id,
                                  doc['name'],
                                  doc['dailyWage'],
                                  doc['phoneNumber'],
                                ),
                                backgroundColor: Colors.green,
                                foregroundColor: Colors.white,
                                icon: Icons.edit,
                                label: 'O\'zgartirish',
                              ),
                            ],
                          ),
                          child: ListTile(
                            leading: GestureDetector(
                              onTap: () => _pickAndUploadImage(doc.id),
                              child: imageSnapshot.connectionState ==
                                      ConnectionState.done
                                  ? CachedNetworkImage(
                                      imageUrl: imageSnapshot.data ?? '',
                                      placeholder: (context, url) =>
                                          const CircularProgressIndicator(),
                                      errorWidget: (context, url, error) =>
                                          const Icon(Icons.person),
                                      width: 50,
                                      height: 50,
                                      fit: BoxFit.cover,
                                    )
                                  : const CircularProgressIndicator(),
                            ),
                            title: Text(doc['name']),
                            subtitle: Text(
                                'O\'bshi:    ${dailyWage * workedDaysCount}\nIshlagan kuni: $workedDaysCount'),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.add),
                                  onPressed: () => _markTodayAsWorked(doc.id),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.remove),
                                  onPressed: () =>
                                      _showSubtractDaysDialog(doc.id),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.calendar_today),
                                  onPressed: () => _showCalendar(
                                      doc.id, workedDays, doc['name']),
                                ),
                              ],
                            ),
                            tileColor: workedDays.containsKey(todayString)
                                ? Colors.green[700]
                                : Colors.red[700],
                          ),
                        );
                      },
                    );
                  }).toList(),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'Umumiy summa: $totalSum',
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(
                height: 15,
              )
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddEmployeeDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}

class CalendarPage extends StatefulWidget {
  final String userId;
  final String employeeId;
  final Map<String, bool> workedDays;
  final String name;
  const CalendarPage({
    super.key,
    required this.userId,
    required this.employeeId,
    required this.workedDays,
    required this.name,
  });

  @override
  CalendarPageState createState() => CalendarPageState();
}

class CalendarPageState extends State<CalendarPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late Map<String, bool> _workedDays;

  @override
  void initState() {
    super.initState();
    _workedDays = widget.workedDays;
  }

  void _updateWorkedDay(DateTime day) async {
    String dayString = day.toIso8601String().split('T')[0];
    bool isWorked = _workedDays[dayString] ?? false;

    if (isWorked) {
      _workedDays.remove(dayString);
    } else {
      _workedDays[dayString] = true;
    }

    await _firestore
        .collection('users')
        .doc(widget.userId)
        .collection('employees')
        .doc(widget.employeeId)
        .update({
      'workedDays': _workedDays,
    });

    setState(() {}); // Rebuild the UI to reflect changes
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Column(
        children: [
          SizedBox(
            width: double.maxFinite,
            //   height: double.maxFinite,
            child: TableCalendar(
              firstDay: DateTime.utc(2024, 1, 1),
              lastDay: DateTime.utc(2028, 12, 31),
              focusedDay: DateTime.now(),
              calendarFormat: CalendarFormat.month,
              selectedDayPredicate: (day) {
                return _workedDays[day.toIso8601String().split('T')[0]] ??
                    false;
              },
              onDaySelected: (selectedDay, focusedDay) {
                _updateWorkedDay(selectedDay);
              },
              calendarBuilders: CalendarBuilders(
                defaultBuilder: (context, day, focusedDay) {
                  bool isWorked =
                      _workedDays[day.toIso8601String().split('T')[0]] ?? false;
                  return Container(
                    margin: const EdgeInsets.all(6.0),
                    decoration: BoxDecoration(
                      color: isWorked ? Colors.green : Colors.red,
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Center(
                      child: Text(
                        day.day.toString(),
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: '${widget.name} ',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.green, // Matn rangini o'zgartiring
                  ),
                ),
                const TextSpan(
                  text: 'ning ishlagan kunlari',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
