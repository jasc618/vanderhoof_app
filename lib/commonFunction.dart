import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geocoder/geocoder.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'fireStoreObjects.dart';

// import 'cards.dart';
import 'main.dart';
// import 'map.dart';

/// uses an address String and returns a LatLng geopoint
Future<GeoPoint> toLatLng(String addr) async {
  if (addr == null || addr.startsWith('Vanderhoof')) {
    return null;
  }
  var address;
  try {
    address = await Geocoder.local.findAddressesFromQuery(addr);
  } catch (e) {
    print("could not get geopoint for address: $addr");
    return address;
  }
  var first = address.first;
  var coor = first.coordinates;
  var lat = coor.latitude;
  var lng = coor.longitude;
  return GeoPoint(lat, lng);
}

/// returns true if a string field is empty
bool isFieldEmpty(String toCheck) {
  return (toCheck == null ||
      toCheck.trim() == "" ||
      toCheck == "." ||
      toCheck == "null");
}

/// parses a long string & appends "..."
String parseLongField(String toCheck) {
  String result = toCheck.trim();
  if (toCheck.length > 30) {
    result = toCheck.substring(0, 30) + "...";
  }
  return result;
}

//=========================================
//Method to add business to FireStore
//=========================================
CollectionReference businessFireStore =
    FirebaseFirestore.instance.collection('businesses');

Future<void> addBusiness(Map<String, dynamic> businessInfo, {File imageFile}) {
// Used to add businesses
  return businessFireStore
      .add(businessInfo)
      .then((value) => {
            print("Business Added:  ${value.id}, ${businessInfo['name']}"),
            businessFireStore.doc(value.id).update({"id": value.id}),
            if (imageFile != null)
              {
                uploadFile(imageFile, value.id, "businesses").then((v) =>
                    downloadURL(value.id, "businesses").then((imgURL) =>
                        businessFireStore
                            .doc(value.id)
                            .update({"imgURL": imgURL}))),
              }
          })
      .catchError((error) => print("Failed to add Business: $error"));
}

Future<void> editBusiness(Map<String, dynamic> form, Business business,
    {File imageFile}) {
  if (imageFile != null) {
    uploadFile(imageFile, business.id, "events").then((v) =>
        downloadURL(business.id, "events").then((imgURL) =>
            businessFireStore.doc(business.id).update({"imgURL": imgURL})));
  }
  toLatLng(form['address']).then((geopoint) {
    businessFireStore
        .doc(business.id)
        .update({
          'name': form['name'],
          'address': form['address'],
          'description': form['description'],
          'email': form['email'],
          'website': form['website'],
          'category': form['category'],
          'phone': form['phone'],
          'LatLng': geopoint
        })
        .then((value) => {
              print("Event updated: ${business.id} : ${business.name}"),
              businessFireStore.doc(business.id).update({"id": business.id})
            })
        .catchError((error) => print("Failed to add Event: $error"));
  });
}

Future<void> deleteCard(
    String cardName, String docID, int index, CollectionReference fireStore) {
  // Delete from fireStore
  return fireStore
      .doc(docID)
      .delete()
      .then((value) => print("$docID Deleted"))
      .catchError((error) => print("Failed to delete: $error"));
}

void deleteCardHikeRec(
    int index,
    State thisContext,
    BuildContext context,
    List filteredList,
    CollectionReference fireStore,
    String collectionName,
    String itemName) {
  {
    // Remove the item from the data source.
    thisContext.setState(() {
      filteredList.removeAt(index);
    });
    // Delete from fireStore
    // String docID = businessName.replaceAll('/', '|');
    FirebaseFirestore.instance
        .collection(collectionName)
        .where("name", isEqualTo: itemName)
        .get()
        .then((value) {
      value.docs.forEach((element) {
        FirebaseFirestore.instance
            .collection(collectionName)
            .doc(element.id)
            .delete()
            .then((value) => print("$itemName Deleted"))
            .catchError((error) => print("Failed to delete user: $error"));
      });
    });
    // Then show a snackbar.
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text("$itemName deleted")));
  }
}

DateTime addDateTime({DateTime dateTime, String repeatType}) {
  if (repeatType == 'Daily') {
    return DateTime(dateTime.year, dateTime.month, dateTime.day + 1,
        dateTime.hour, dateTime.minute);
  } else if (repeatType == 'Weekly') {
    return DateTime(dateTime.year, dateTime.month, dateTime.day + 7,
        dateTime.hour, dateTime.minute);
  } else if (repeatType == 'Monthly') {
    return DateTime(dateTime.year, dateTime.month + 1, dateTime.day,
        dateTime.hour, dateTime.minute);
  } else {
    return DateTime(dateTime.year + 1, dateTime.month, dateTime.day,
        dateTime.hour, dateTime.minute);
  }
}

Future<void> addEvent(event, CollectionReference fireStore, {File imageFile}) {
  print("adding to firebase: $event");
  return fireStore
      .add(event)
      .then((value) => {
            print("Event Added: ${value.id} : ${event['title']}"),
            fireStore.doc(value.id).update({"id": value.id}),
            if (imageFile != null)
              {
                uploadFile(imageFile, value.id, "events").then((v) =>
                    downloadURL(value.id, "events").then((imgURL) =>
                        fireStore.doc(value.id).update({"imgURL": imgURL}))),
              }
          })
      .catchError((error) => print("Failed to add Event: $error"));
}

Future<void> uploadFile(File file, String filename, String folderName) async {
  try {
    await firebase_storage.FirebaseStorage.instance
        .ref('$folderName/$filename.png')
        .putFile(file);
  } on FirebaseException catch (e) {
    print("upload fail: $e");
    // e.g, e.code == 'canceled'
  }
}

Future<String> downloadURL(String filename, String folderName) async {
  return await firebase_storage.FirebaseStorage.instance
      .ref('$folderName/$filename.png')
      .getDownloadURL();
}

///filename is the ID of the document
Future<void> deleteFileFromID(String filename, String folderName) async {
  return await firebase_storage.FirebaseStorage.instance
      .ref()
      .child('$folderName/$filename.png')
      .delete()
      .then((_) => print('Successfully deleted $filename storage item'));
}

/// uses a Color with a hex code and returns a MaterialColor object
MaterialColor createMaterialColor(Color color) {
  List strengths = <double>[.05];
  Map swatch = <int, Color>{};
  final int r = color.red, g = color.green, b = color.blue;

  for (int i = 1; i < 10; i++) {
    strengths.add(0.1 * i);
  }
  strengths.forEach((strength) {
    final double ds = 0.5 - strength;
    swatch[(strength * 1000).round()] = Color.fromRGBO(
      r + ((ds < 0 ? r : (255 - r)) * ds).round(),
      g + ((ds < 0 ? g : (255 - g)) * ds).round(),
      b + ((ds < 0 ? b : (255 - b)) * ds).round(),
      1,
    );
  });
  return MaterialColor(color.value, swatch);
}

Widget showLoadingScreen() {
  return SpinKitWave(
    color: colorPrimary,
    size: 50.0,
  );
}

Widget buildScrollToTopButton(isVisible, controller) {
  return isVisible
      ? Container(
          child: FloatingActionButton(
              // scroll to top of the list
              child: FaIcon(FontAwesomeIcons.angleUp),
              shape: RoundedRectangleBorder(),
              foregroundColor: colorPrimary,
              mini: true,
              onPressed: () {
                controller.scrollTo(
                  index: 0,
                  duration: Duration(seconds: 1),
                  curve: Curves.easeInOut,
                );
              }),
        )
      : null;
}

/// async helper method - formats website to remove "http(s)://www."
///
/// "http://" is required to correctly launch website URL
String formatWebsiteURL(String website) {
  if (website != null && website.trim() != "" && website != ".") {
    String formatted = website.trim();
    if (formatted.startsWith('http')) {
      formatted = formatted.substring(4);
    }
    if (formatted.startsWith('s://')) {
      formatted = formatted.substring(4);
    }
    if (formatted.startsWith('://')) {
      formatted = formatted.substring(3);
    }
    if (formatted.startsWith('www.')) {
      formatted = formatted.substring(4);
    }
    return formatted;
  } else {
    // website is empty
    return null;
  }
}

/// async helper method - formats phone number to "(***) ***-****"
String formatPhoneNumber(String phone) {
  if (phone != null && phone.trim() != "" && phone != ".") {
    phone = phone.replaceAll(RegExp("[^0-9]"), '');
    String formatted = phone;
    formatted = "(" +
        phone.substring(0, 3) +
        ") " +
        phone.substring(3, 6) +
        "-" +
        phone.substring(6);
    return formatted;
  } else {
    // phone is empty
    return null;
  }
}

//***************************Same as below************************************
// Widget buildBody(isFirstTime, future, filteredItem, markers, buildList,
//     {buildChips}) {
//   return Container(
//     padding: EdgeInsets.all(0.0),
//     child: isFirstTime
//         ? FutureBuilder(
//             future: future,
//             builder: (context, snapshot) {
//               switch (snapshot.connectionState) {
//                 case ConnectionState.none:
//                   return Text('non');
//                 case ConnectionState.active:
//                 case ConnectionState.waiting:
//                   return showLoadingScreen();
//                 case ConnectionState.done:
//                   {
//                     print(buildChips);
//                     return _buildBody(filteredItem, markers, buildList,
//                         buildChips: buildChips);
//                   }
//                 default:
//                   return Text("Default");
//               }
//             },
//           )
//         : _buildBody(filteredItem, markers, buildList, buildChips: buildChips),
//   );
// }

// ************Saving for later can be deleted if we don't end up doing this.
// Widget _buildBody(filteredItem, markers, buildList, {buildChips}) {
//   return Column(
//     crossAxisAlignment: CrossAxisAlignment.start,
//     children: [
//       // insert widgets here wrapped in `Expanded` as a child
//       // note: play around with flex int value to adjust vertical spaces between widgets
//       Expanded(
//         flex: 9,
//         child: Gmap(filteredItem, markers),
//       ),
//       (buildChips != null && buildChips != "")
//           ? Expanded(flex: 2, child: buildChips())
//           : Container(),
//       Expanded(
//         flex: 14,
//         child: filteredItem.length != 0
//             ? buildList()
//             : Container(
//                 child: Center(
//                   child: Text("No results found", style: titleTextStyle),
//                 ),
//               ),
//       ),
//     ],
//   );
// }
