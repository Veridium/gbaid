class Credential {
  int _id;
  String _title;
  String _description;
  String _icon;
 
  Credential(this._title, this._description, this._icon);
 
  Credential.map(dynamic obj) {
    this._id = obj['id'];
    this._title = obj['title'];
    this._description = obj['description'];
    this._icon = obj['icon'];
  }
 
  int get id => _id;
  String get title => _title;
  String get description => _description;
  String get icon => _icon;
 
  Map<String, dynamic> toMap() {
    var map = new Map<String, dynamic>();
    if (_id != null) {
      map['id'] = _id;
    }
    map['title'] = _title;
    map['description'] = _description;
    map['icon'] = _icon;
 
    return map;
  }
 
  Credential.fromMap(Map<String, dynamic> map) {
    this._id = map['id'];
    this._title = map['title'];
    this._description = map['description'];
    this._icon = map['icon'];
  }
}