import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:http/http.dart' as http;

import '../bloc/bloc.dart';
import '../data/model/credential.dart';
import '../data/database_helper.dart';
import 'credential_screen.dart';

class ListViewNote extends StatefulWidget {
  @override
  _ListViewNoteState createState() => new _ListViewNoteState();
}

class _ListViewNoteState extends State<ListViewNote> {
  List<Note> items = new List();
  DatabaseHelper db = new DatabaseHelper();

  @override
  void initState() {
    super.initState();

    db.getAllNotes().then((notes) {
      setState(() {
        notes.forEach((note) {
          items.add(Note.fromMap(note));
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        floatingActionButton: FloatingActionButton(
          child: Icon(Icons.add),
          onPressed: () => _showPlans(context),
        ),
        body: Center(
          child: ListView.builder(
          itemCount: items.length,
          padding: const EdgeInsets.all(0.0),
          itemBuilder: (context, position) {
            return Column(
              children: <Widget>[
                Divider(height: 5.0),
                ListTile(
                  title: Text(
                    '${items[position].title}',
                    style: TextStyle(
                      fontSize: 18.0,
                      color: Colors.deepOrangeAccent,
                    ),
                  ),
                  subtitle: Text(
                    '${items[position].description}',
                    style: new TextStyle(
                      fontSize: 14.0,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  leading: Column(
                    children: <Widget>[
                      Padding(padding: EdgeInsets.all(10.0)),
                      Image.asset("images/sovrin-ico.png", height: 30),
                    ],
                  ),
                  onTap: () => _navigateToCredential(context, items[position]),
                ),
              ],
            );
          },
        )
      )
    );
  }

  void _showPlans(BuildContext context) {
    final registrationBloc = BlocProvider.of<RegistrationBloc>(context);
    registrationBloc.add(ShowPlans());
  }

  void _deleteNote(BuildContext context, Note note, int position) async {
    db.deleteNote(note.id).then((notes) {
      setState(() {
        items.removeAt(position);
      });
    });
  }

  void _navigateToCredential(BuildContext context, Note note) async {
    String barcodeScanRes = await FlutterBarcodeScanner.scanBarcode("#ff6666", "Cancel", false, ScanMode.DEFAULT);
    http.Response pingResponse;
    RegExp re = new RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+");
    Match firstMatch = re.firstMatch(note.description);
    String email = note.description.substring(firstMatch.start, firstMatch.end);
    try {
      pingResponse = await http.post(Uri.encodeFull(barcodeScanRes),
          body: json.encode({
            'email': email
          }),
          headers: {
            "Content-Type": "application/json"
          }).timeout(Duration(seconds: 30));
    } catch (e) {
    }
  }

  void _createNewNote(BuildContext context) async {
    String result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => NoteScreen(Note('', ''))),
    );

    if (result == 'save') {
      db.getAllNotes().then((notes) {
        setState(() {
          items.clear();
          notes.forEach((note) {
            items.add(Note.fromMap(note));
          });
        });
      });
    }
  }
}
