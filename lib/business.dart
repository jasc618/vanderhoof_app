import 'package:flutter/material.dart';
import 'dart:async';
import 'package:vanderhoof_app/main.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'addBusinessPage.dart';
import 'scraper.dart';

// Business object
class BusinessCard {
  final String name;
  final String address;
  final String description;
  BusinessCard(this.name, this.address, this.description);
}

class Business extends StatefulWidget {
  Business({Key key}) : super(key: key);

  final title = "Businesses";

  @override
  _BusinessPageState createState() => new _BusinessPageState();
}

class _BusinessPageState extends State<Business> {
  List<BusinessCard> businesses = [];
  List<BusinessCard> filteredBusinesses = [];
  bool isSearching = false;

  // firebase async get data
  Future _getBusinesses() async {
    CollectionReference fireStore =
        FirebaseFirestore.instance.collection('businesses');

    await fireStore.get().then((QuerySnapshot snap) {
      businesses = filteredBusinesses = [];
      snap.docs.forEach((doc) {
        BusinessCard b =
            BusinessCard(doc['name'], doc['address'], doc["description"]);
        businesses.add(b);
      });
    });
    return businesses;
  }

  @override
  void initState() {
    // reference: https://github.com/bitfumes/flutter-country-house/blob/master/lib/Screens/AllCountries.dart
    // this method gets firebase data and populates into list of businesses
    _getBusinesses().then((data) {
      setState(() {
        businesses = filteredBusinesses = data;
      });
    });
    super.initState();
  }

  // This method does the logic for search and changes filteredBusinesses to search results
  // reference: https://github.com/bitfumes/flutter-country-house/blob/master/lib/Screens/AllCountries.dart
  void _filterSearchItems(value) {
    setState(() {
      filteredBusinesses = businesses
          .where((businessCard) =>
              businessCard.name.toLowerCase().contains(value.toLowerCase()))
          .toList();
    });
  }

  Widget _businessesListBuild() {
    return new Container(
        child: ListView.builder(
      itemCount: filteredBusinesses.length,
      itemBuilder: (BuildContext context, int index) {
        return ExpansionTile(
          // leading: CircleAvatar(
          //   backgroundImage:
          //       NetworkImage(snapshot.data[index].picture),
          // ),
          title: _nullText(filteredBusinesses[index].name),
          subtitle: _nullText(filteredBusinesses[index].address),
          children: <Widget>[_nullText(filteredBusinesses[index].description)],
        );
      },
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Drawer: Hamberguer menu for Admin
      drawer: Drawer(
          child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          Container(
            height: 100,
            margin: EdgeInsets.all(0),
            padding: EdgeInsets.all(0),
            child: DrawerHeader(
              child: Text("Admin Menu"),
              decoration: BoxDecoration(color: colorPrimary),
            ),
          ),
          ListTile(
            leading: Icon(Icons.add_circle_outline),
            title: Text("Add a Business"),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddBusinessPage(),
                  ));
            },
          ),
          ListTile(
            leading: Icon(Icons.ac_unit),
            title: Text("Test Scraper"),
            onTap: () => scrap(true),
          ),
        ],
      )),
      appBar: AppBar(
        title: !isSearching
            ? Text(widget.title)
            : TextField(
                onChanged: (value) {
                  // search logic here
                  _filterSearchItems(value);
                },
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(
                    icon: Icon(
                      Icons.search,
                      color: Colors.white,
                    ),
                    hintText: "Search Businesses",
                    hintStyle: TextStyle(color: Colors.white70)),
              ),
        actions: <Widget>[
          isSearching
              ? IconButton(
                  icon: Icon(Icons.cancel),
                  onPressed: () {
                    setState(() {
                      this.isSearching = false;
                      filteredBusinesses = businesses;
                    });
                  },
                )
              : IconButton(
                  icon: Icon(Icons.search),
                  onPressed: () {
                    setState(() {
                      this.isSearching = true;
                    });
                  },
                )
        ],
      ),
      body: Container(
        padding: EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // insert widgets here wrapped in `Expanded` as a child
            // note: play around with flex int value to adjust vertical spaces between widgets
            Expanded(flex: 1, child: Text("first child - future map widget")),
            Expanded(flex: 11, child: _businessesListBuild()),
          ],
        ),
      ),
    );
  }

  Widget _nullText(String str) {
    if (str != null) {
      return Text(str);
    } else {
      return Text("empty");
    }
  }
}
