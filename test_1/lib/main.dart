import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: 'https://uvwmnjhzzpbfstzvvavy.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InV2d21uamh6enBiZnN0enZ2YXZ5Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDAwMDMxOTMsImV4cCI6MjA1NTU3OTE5M30.XL1G6Sc3oCnXG2zfpPJvlmWOG09Amvpu-LL9DqAOZHo',
  );

  runApp(const MyApp());
}

final supabase = Supabase.instance.client;

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: const NotesScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class NotesScreen extends StatefulWidget {
  const NotesScreen({super.key});

  @override
  _NotesScreenState createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  List<Map<String, dynamic>> notes = [];

  @override
  void initState() {
    super.initState();
    fetchNotes();
  }

  Future<void> fetchNotes() async {
    final response = await supabase.from('notes').select('*');
    setState(() {
      notes = List<Map<String, dynamic>>.from(response);
    });
  }

  Future<void> addNote(String body) async {
    try {
      await supabase.from('notes').insert({'body': body});
      fetchNotes(); // Refresh the list of notes
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to add note: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Notes"), backgroundColor: Colors.blue),
      body: ListView.builder(
        itemCount: notes.length,
        itemBuilder: (context, index) {
          final note = notes[index];
          return ListTile(title: Text(note['body']));
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) {
              String newNote = '';
              return AlertDialog(
                title: const Text("Add a note"),
                content: TextFormField(
                  onChanged: (value) {
                    newNote = value;
                  },
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text("Cancel"),
                  ),
                  TextButton(
                    onPressed: () async {
                      if (newNote.isNotEmpty) {
                        await addNote(newNote);
                        Navigator.of(context).pop();
                      }
                    },
                    child: const Text("Add"),
                  ),
                ],
              );
            },
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
