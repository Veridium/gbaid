import 'package:flutter/material.dart';
import '../data/model/credential.dart';
import '../data/database_helper.dart';
 
class CredentialScreen extends StatefulWidget {
  final Credential cred;
  CredentialScreen(this.cred);
 
  @override
  State<StatefulWidget> createState() => new _CredentialScreenState();
}
 
class _CredentialScreenState extends State<CredentialScreen> {
  DatabaseHelper db = new DatabaseHelper();
 
  TextEditingController _titleController;
  TextEditingController _descriptionController;
  TextEditingController _iconController;
 
  @override
  void initState() {
    super.initState();
 
    _titleController = new TextEditingController(text: widget.cred.title);
    _descriptionController = new TextEditingController(text: widget.cred.description);
    _iconController = new TextEditingController(text: widget.cred.icon);
  }
 
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Credential')),
      body: Container(
        margin: EdgeInsets.all(15.0),
        alignment: Alignment.center,
        child: Column(
          children: <Widget>[
            TextField(
              controller: _titleController,
              decoration: InputDecoration(labelText: 'Title'),
            ),
            Padding(padding: new EdgeInsets.all(5.0)),
            TextField(
              controller: _descriptionController,
              decoration: InputDecoration(labelText: 'Description'),
            ),
            Padding(padding: new EdgeInsets.all(5.0)),
            TextField(
              controller: _iconController,
              decoration: InputDecoration(labelText: 'Icon'),
            ),
            Padding(padding: new EdgeInsets.all(5.0)),
            RaisedButton(
              child: (widget.cred.id != null) ? Text('Update') : Text('Add'),
              onPressed: () {
                if (widget.cred.id != null) {
                  db.updateCred(Credential.fromMap({
                    'id': widget.cred.id,
                    'title': _titleController.text,
                    'description': _descriptionController.text,
                    'icon': _iconController.text
                  })).then((_) {
                    Navigator.pop(context, 'update');
                  });
                }else {
                  db.saveCred(Credential(_titleController.text, _descriptionController.text, _iconController.text)).then((_) {
                    Navigator.pop(context, 'save');
                  });
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}