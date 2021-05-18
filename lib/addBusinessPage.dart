import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:getwidget/getwidget.dart';

import 'main.dart';
import 'commonFunction.dart';
import 'data.dart';
import 'package:form_builder_image_picker/form_builder_image_picker.dart';
import 'dart:io';
import 'fireStoreObjects.dart';

class AddBusinessPage extends StatefulWidget {
  final Business business;
  AddBusinessPage({this.business});
  @override
  _AddBusinessPageState createState() =>
      _AddBusinessPageState(business: business);
}

class _AddBusinessPageState extends State<AddBusinessPage> {
  //* Form key
  final _formKey = GlobalKey<FormBuilderState>();
  List<dynamic> category;
  Business business;
  _AddBusinessPageState({this.business});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add a New Business'),
        backgroundColor: colorPrimary,
      ),
      body: Row(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: FormBuilder(
                              key: _formKey,
                              child: Column(
                                children: [
                                  GFTypography(
                                    type: GFTypographyType.typo1,
                                    text: (business != null)
                                        ? 'Edit Business information'
                                        : 'Business Information',
                                  ),
                                  SizedBox(height: 20),
                                  _getTextField(
                                      "name",
                                      "Name",
                                      "Vanderhoof Chamber of Commerce",
                                      Icon(Icons.account_balance),
                                      initialValue: business?.name,
                                      formValidator:
                                          FormBuilderValidators.required(
                                              context)),
                                  _getTextField(
                                      "address",
                                      "Address",
                                      "188 E Stewart Street, Unit 11, PO Box 126, Vanderhoof, BC,",
                                      Icon(Icons.add_location_alt_outlined),
                                      initialValue: business?.address),
                                  _getTextField("phone", "Phone",
                                      "604-123-1234", Icon(Icons.phone),
                                      initialValue: business?.phoneNumber,
                                      phone: true),
                                  _getTextField("website", "Website",
                                      "www.example.com", Icon(Icons.web),
                                      initialValue: business?.website,
                                      url: true),
                                  _getTextField(
                                      "email",
                                      "Email",
                                      "example@gmail.com",
                                      Icon(Icons.email_outlined),
                                      initialValue: business?.email,
                                      email: true),
                                  _getTextField(
                                      "description",
                                      "Description",
                                      "description of business",
                                      Icon(Icons.description_outlined),
                                      initialValue: business?.description),
                                  Container(
                                      margin: EdgeInsets.only(top: 15),
                                      child: Row(
                                        children: [
                                          ElevatedButton(
                                            onPressed: () {
                                              final _key =
                                                  GlobalKey<FormBuilderState>();
                                              showDialog(
                                                  context: context,
                                                  barrierDismissible:
                                                      false, // user must tap button!
                                                  builder:
                                                      (BuildContext context) {
                                                    return AlertDialog(
                                                      insetPadding:
                                                          EdgeInsets.all(10),
                                                      title:
                                                          Text('Add category'),
                                                      content:
                                                          SingleChildScrollView(
                                                        child: ListBody(
                                                          children: <Widget>[
                                                            Text(
                                                                'Choose one more more categories:'),
                                                            // _buildChips(this),
                                                            Center(
                                                              child:
                                                                  FormBuilder(
                                                                      key: _key,
                                                                      child: Column(
                                                                          children: [
                                                                            FormBuilderFilterChip(
                                                                                spacing: 5,
                                                                                name: "category",
                                                                                options: _buildFieldOptions()),
                                                                          ])),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                      actions: <Widget>[
                                                        TextButton(
                                                          child: Text('Yes'),
                                                          onPressed: () {
                                                            setState(() {
                                                              _key.currentState
                                                                  .save();
                                                              category = _key
                                                                      .currentState
                                                                      .value[
                                                                  'category'];
                                                            });

                                                            Navigator.of(
                                                                    context)
                                                                .pop(true);
                                                          },
                                                        ),
                                                        TextButton(
                                                          child: Text('Cancel'),
                                                          onPressed: () {
                                                            Navigator.of(
                                                                    context)
                                                                .pop(false);
                                                          },
                                                        ),
                                                      ],
                                                    );
                                                  });
                                            },
                                            child: Text('Category'),
                                          ),
                                          Expanded(
                                              child: Container(
                                                  margin:
                                                      EdgeInsets.only(left: 15),
                                                  child: Text((category == null)
                                                      ? ""
                                                      : category.join(', ')))),
                                          if (category != null)
                                            IconButton(
                                              icon: Icon(Icons.cancel),
                                              onPressed: () {
                                                setState(() {
                                                  category = null;
                                                });
                                              },
                                            )
                                        ],
                                      )),
                                  FormBuilderImagePicker(
                                    name: 'image',
                                    initialValue: (business != null &&
                                            business.imgURL != null)
                                        ? [business.imgURL]
                                        : null,
                                    decoration: const InputDecoration(
                                      labelText: 'Pick Photo',
                                    ),
                                    maxImages: 1,
                                  ),
                                  SizedBox(height: 10),
                                  Row(
                                    children: [
                                      const Spacer(),
                                      Expanded(
                                          child: Center(
                                              child: ElevatedButton(
                                        onPressed: _onSubmitPressed,
                                        child: Text('Submit'),
                                      ))),
                                      Expanded(
                                          child: Center(
                                              child: ElevatedButton(
                                        onPressed: () {
                                          _formKey.currentState.reset();
                                          // unfocus keyboard
                                          FocusScope.of(context).unfocus();
                                        },
                                        child: Text('Reset'),
                                      ))),
                                      Expanded(
                                          child: Center(
                                              child: ElevatedButton(
                                        onPressed: () => Navigator.pop(context),
                                        child: Text('Cancel'),
                                      )))
                                    ],
                                  ),
                                ],
                              ),
                              autovalidateMode: null,
                              onWillPop: null,
                              initialValue: null,
                              skipDisabled: null,
                              enabled: null,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _getTextField(
      String name, String labelText, String hintText, Icon icon,
      {initialValue,
      email = false,
      url = false,
      phone = false,
      formValidator}) {
    TextInputType inputType = TextInputType.text;
    if (email == true) {
      inputType = TextInputType.emailAddress;
      formValidator =
          FormBuilderValidators.compose([FormBuilderValidators.email(context)]);
    } else if (url == true) {
      inputType = TextInputType.url;
      formValidator =
          FormBuilderValidators.compose([FormBuilderValidators.url(context)]);
    } else if (phone == true) {
      inputType = TextInputType.phone;
      formValidator = FormBuilderValidators.compose([
        (value) {
          if (value == null || value == "") {
            return null;
          }
          value = value.replaceAll(RegExp(r'[-() ]'), '');
          if (!RegExp(r'^[0-9]+$').hasMatch(value) || value.length != 10) {
            return "This field must be a phone number";
          } else {
            return null;
          }
        }
      ]);
    }
    return Container(
      margin: EdgeInsets.only(top: 15),
      child: FormBuilderTextField(
        name: name,
        validator: formValidator,
        keyboardType: inputType,
        initialValue: initialValue,
        // onTap: () => {},
        decoration: InputDecoration(
          labelText: labelText,
          hintText: hintText,
          icon: icon,
          floatingLabelBehavior: FloatingLabelBehavior.always,
          border: OutlineInputBorder(
            borderRadius: const BorderRadius.all(
              const Radius.circular(10.0),
            ),
          ),
        ),
      ),
    );
  }

  void _onSubmitPressed() {
    print("-------------Submit clicked------------");

    //=========================================
    //Validate fields. If successful, then addBusiness()
    //=========================================
    final validationSuccess = _formKey.currentState.validate();
    if (validationSuccess) {
      _formKey.currentState.save();
      print("submitted data:  ${_formKey.currentState.value}");
      File imgFile;
      if (_formKey.currentState.value['image'] != null) if (_formKey
          .currentState.value['image'].isNotEmpty) {
        if (business == null ||
            _formKey.currentState.value['image'][0] != business.imgURL)
          imgFile = _formKey.currentState.value['image'][0];
      } else if (_formKey.currentState.value['image'].isEmpty &&
          business.imgURL != null) {
        businessFireStore.doc(business.id).update({"imgURL": null});
      }
      // if (business != null && category == null) {
      //   category = business.category;
      // }
      toLatLng(_formKey.currentState.value['address']).then((geopoint) {
        Map<String, dynamic> businessInfo = {
          ..._formKey.currentState.value,
          'imgURL': null,
          'LatLng': geopoint,
          'socialMedia': {'facebook': ".", 'instagram': ".", 'twitter': "."},
          'category': category
        };
        businessInfo.remove('image');
        businessInfo['phone'] =
            businessInfo['phone']?.replaceAll(RegExp(r'[-() ]'), '');
        // forEach below is to replace empty String with null
        businessInfo.forEach((key, value) {
          if (value != null && value == '') businessInfo[key] = null;
        });

        // business would be null is it's addBusiness, else it's editBusiness
        if (business == null) {
          print("adding business");
          addBusiness(businessInfo, imageFile: imgFile);
        } else {
          print("editing business");
          editBusiness(businessInfo, business, imageFile: imgFile);
        }

        //=========================================
        //Navigate back to Business Page
        //=========================================
        // Navigator.pop(context);
      });
    }
  }
}

List<FormBuilderFieldOption<dynamic>> _buildFieldOptions() {
  List<FormBuilderFieldOption<dynamic>> options = [];
  for (int i = 0; i < categoryOptions.length; i++) {
    options.add(FormBuilderFieldOption(
        value: categoryOptions[i],
        child: Text(categoryOptions[i], textScaleFactor: 0.9)));
  }
  return options;
}
