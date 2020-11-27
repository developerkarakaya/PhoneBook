import 'package:flutter/material.dart';
import 'package:phone_book/database/db_helper.dart';
import 'add_contact_page.dart';
import 'models/Contact.dart';

class ContactPage extends StatefulWidget {
  @override
  _ContactPageState createState() => _ContactPageState();
}

class _ContactPageState extends State<ContactPage> {
  List<Contact> contacts;
  DbHelper _dbHelper;
  @override
  void initState() {
    _dbHelper = DbHelper();
    super.initState();
  }

  showAlert(BuildContext context) {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Rehberim"),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => AddContactPage(
                          contact: Contact("", "", ""),
                        )));
          },
          child: Icon(Icons.add),
        ),
        body: FutureBuilder(
          future: _dbHelper.getContacts(),
          builder:
              (BuildContext context, AsyncSnapshot<List<Contact>> snapshot) {
            if (!snapshot.hasData) return CircularProgressIndicator();
            if (snapshot.data.isEmpty)
              return Center(
                child: Text("Rehberde Kişi Bulunamadı"),
              );
            return Container(
                child: ListView.builder(
              itemCount: snapshot.data.length,
              itemBuilder: (BuildContext context, int index) {
                Contact contact = snapshot.data[index];
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => AddContactPage(
                                  contact: contact,
                                )));
                  },
                  child: Dismissible(
                    key: Key(contact.name),
                    onDismissed: (direction) async {
                      _dbHelper.removeContact(contact.id);
                      setState(() {});
                      Scaffold.of(context).showSnackBar(SnackBar(
                        content:
                            Text("${contact.name} Kişisi Başarıyla Silindi"),
                        action: SnackBarAction(
                          label: "Kişiyi Geri Al",
                          onPressed: () async {
                            await _dbHelper.InsertContact(contact);
                            setState(() {});
                          },
                        ),
                      ));
                    },
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundImage: AssetImage(
                          contact.avatar.isEmpty
                              ? "assets/img/person.jpg"
                              : contact.avatar,
                        ),
                        child: Text(
                          contact.name[0],
                          style: TextStyle(
                              fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                      ),
                      title: Text(contact.name),
                      subtitle: Text(contact.phoneNumber),
                    ),
                  ),
                );
              },
            ));
          },
        ));
  }
}
