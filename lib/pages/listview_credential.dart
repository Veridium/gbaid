import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:http/http.dart' as http;

import '../bloc/bloc.dart';
import '../data/model/credential.dart';
import '../data/database_helper.dart';
import 'credential_screen.dart';

class ListViewCred extends StatefulWidget {
  @override
  _ListViewCredState createState() => new _ListViewCredState();
}

class _ListViewCredState extends State<ListViewCred> {
  List<Credential> items = new List();
  DatabaseHelper db = new DatabaseHelper();

  @override
  void initState() {
    super.initState();

    db.getAllCreds().then((credentials) {
      setState(() {
        credentials.forEach((cred) {
          items.add(Credential.fromMap(cred));
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
                      Image.network(items[position].icon, height: 30),
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

  void _deleteCred(BuildContext context, Credential cred, int position) async {
    db.deleteCred(cred.id).then((creds) {
      setState(() {
        items.removeAt(position);
      });
    });
  }

  void _navigateToCredential(BuildContext context, Credential cred) async {
    String barcodeScanRes = await FlutterBarcodeScanner.scanBarcode("#ff6666", "Cancel", false, ScanMode.DEFAULT);
    http.Response pingResponse;
    RegExp re = new RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+");
    Match firstMatch = re.firstMatch(cred.description);
    String email = cred.description.substring(firstMatch.start, firstMatch.end);
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

  void _createNewCred(BuildContext context) async {
    String result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => CredentialScreen(Credential('', '', ''))),
    );

    if (result == 'save') {
      db.getAllCreds().then((creds) {
        setState(() {
          items.clear();
          creds.forEach((cred) {
            items.add(Credential.fromMap(cred));
          });
        });
      });
    }
  }
}
