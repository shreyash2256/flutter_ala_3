import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ALA 3 - SharedPreferences',
      theme: ThemeData(primarySwatch: Colors.teal),
      home: const NotesScreen(),
    );
  }
}

// --- STORAGE HELPER (The "Database") ---
class StorageHelper {
  static const String _key = 'user_notes';

  // Save List of Notes to Local Storage
  static Future<void> saveNotes(List<Map<String, dynamic>> notes) async {
    final prefs = await SharedPreferences.getInstance();
    // Convert the List into a String (JSON) so SharedPreferences can store it
    final String encodedData = json.encode(notes);
    await prefs.setString(_key, encodedData);
  }

  // Load Notes from Local Storage
  static Future<List<Map<String, dynamic>>> loadNotes() async {
    final prefs = await SharedPreferences.getInstance();
    final String? encodedData = prefs.getString(_key);

    if (encodedData == null) return [];

    // Convert the String back into a List
    final List<dynamic> decodedData = json.decode(encodedData);
    return decodedData.cast<Map<String, dynamic>>();
  }
}

// --- MAIN SCREEN UI ---
class NotesScreen extends StatefulWidget {
  const NotesScreen({super.key});

  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  List<Map<String, dynamic>> notes = [];
  final TextEditingController _controller = TextEditingController();
  int _idCounter = 1; // Simple ID generator

  @override
  void initState() {
    super.initState();
    _loadNotes();
  }

  // Load data when app starts
  Future<void> _loadNotes() async {
    final loadedNotes = await StorageHelper.loadNotes();
    setState(() {
      notes = loadedNotes;
      // Ensure new IDs don't clash with old ones
      if (notes.isNotEmpty) {
        _idCounter = notes.last['id'] + 1;
      }
    });
  }

  // Save data whenever we make a change
  Future<void> _saveNotes() async {
    await StorageHelper.saveNotes(notes);
  }

  void _showForm(int? id) {
    if (id != null) {
      final existingNote = notes.firstWhere((element) => element['id'] == id);
      _controller.text = existingNote['content'];
    } else {
      _controller.text = '';
    }

    showModalBottomSheet(
      context: context,
      elevation: 5,
      isScrollControlled: true,
      builder: (_) => Container(
        padding: EdgeInsets.only(
          top: 15,
          left: 15,
          right: 15,
          bottom: MediaQuery.of(context).viewInsets.bottom + 120,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            TextField(
              controller: _controller,
              decoration: const InputDecoration(hintText: 'Enter your note'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                if (id == null) {
                  // CREATE
                  setState(() {
                    notes.add({'id': _idCounter, 'content': _controller.text});
                    _idCounter++;
                  });
                } else {
                  // UPDATE
                  setState(() {
                    final index = notes.indexWhere(
                      (element) => element['id'] == id,
                    );
                    notes[index]['content'] = _controller.text;
                  });
                }

                _saveNotes(); // Save to permanent storage
                _controller.clear();
                Navigator.of(context).pop();
              },
              child: Text(id == null ? 'Create New' : 'Update Note'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Notes (SharedPreferences)'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: notes.isEmpty
          ? const Center(child: Text("No notes saved. Add one!"))
          : ListView.builder(
              itemCount: notes.length,
              itemBuilder: (context, index) => Card(
                color: Colors.teal.shade50,
                margin: const EdgeInsets.all(8),
                child: ListTile(
                  title: Text(
                    notes[index]['content'],
                    style: const TextStyle(fontSize: 18),
                  ),
                  trailing: SizedBox(
                    width: 100,
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () => _showForm(notes[index]['id']),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            setState(() {
                              notes.removeAt(index);
                            });
                            _saveNotes(); // Save deletion
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showForm(null),
        backgroundColor: Colors.teal,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
