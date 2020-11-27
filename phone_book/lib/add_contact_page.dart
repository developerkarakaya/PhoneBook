import 'dart:io';
import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:phone_book/database/db_helper.dart';
import 'package:phone_book/models/Contact.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:image_picker/image_picker.dart';

class AddContactPage extends StatelessWidget {
  final Contact contact;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(contact.id == null ? "Yeni Kişi Ekle" : contact.name),
        ),
        body: SingleChildScrollView(
          child: ContactForm(contact: contact, child: AddContactForm()),
        ));
  }

  AddContactPage({@required this.contact});
}

class ContactForm extends InheritedWidget {
  Contact contact;
  ContactForm({@required Widget child, @required this.contact});

  @override
  bool updateShouldNotify(ContactForm oldWidget) {
    return contact.id != oldWidget.contact.id;
  }

  static ContactForm of(BuildContext context) {
    return context.inheritFromWidgetOfExactType(ContactForm);
  }
}

class AddContactForm extends StatefulWidget {
  @override
  _AddContactFormState createState() => _AddContactFormState();
}

class _AddContactFormState extends State<AddContactForm> {
  final _formkey = GlobalKey<FormState>();
  File _file;
  DbHelper _dbHelper;

  @override
  void initState() {
    _dbHelper = DbHelper();
    super.initState();
  }

  var maskFormatter = new MaskTextInputFormatter(
      mask: '# (###) ### ## ##', filter: {"#": RegExp(r'[0-9]')});
  @override
  Widget build(BuildContext context) {
    Contact contact = ContactForm.of(context).contact;

    return Column(
      children: [
        Stack(
          children: [
            Image.asset(
              _file == null ? "assets/img/person.jpg" : _file.path,
              fit: BoxFit.cover,
              height: 350,
              width: double.infinity,
            ),
            Positioned(
              bottom: 8,
              right: 8,
              child: IconButton(
                onPressed: getFile,
                icon: Icon(
                  Icons.camera_alt,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Form(
            key: _formkey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: TextFormField(
                    initialValue: contact.name,
                    decoration: InputDecoration(hintText: "İsim"),
                    validator: (value) {
                      if (value.isEmpty) {
                        return "İsmi Boş Geçemezsiniz !";
                      }
                    },
                    onSaved: (value) {
                      contact.name = value;
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: TextFormField(
                    initialValue: contact.phoneNumber,
                    keyboardType: TextInputType.phone,
                    inputFormatters: [maskFormatter],
                    decoration: InputDecoration(hintText: "Telefon"),
                    validator: (value) {
                      if (value.isEmpty) {
                        return "Telefonu Boş Geçemezsiniz !";
                      }
                    },
                    onSaved: (value) {
                      contact.phoneNumber = value;
                    },
                  ),
                ),
                RaisedButton(
                  color: Colors.blue,
                  textColor: Colors.white,
                  child: Text("Kişi Ekle"),
                  onPressed: () async {
                    if (_formkey.currentState.validate()) {
                      _formkey.currentState.save();

                      await _dbHelper.InsertContact(contact);
                      var snackBar = Scaffold.of(context).showSnackBar(SnackBar(
                          duration: Duration(milliseconds: 500),
                          content: Text(
                              "${contact.name} Kişisi Başarıyla Eklendi")));
                      snackBar.closed.then((onValue) {
                        Navigator.pop(context);
                      });
                    }
                  },
                )
              ],
            ),
          ),
        ),
      ],
    );
  }

  void getFile() async {
    var image = await ImagePicker.pickImage(source: ImageSource.camera);
    setState(() {
      _file = image;
    });
  }
}
