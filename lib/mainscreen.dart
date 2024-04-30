import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_database/firebase_database.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final _formKey = GlobalKey<FormState>();
  final _databaseRef = FirebaseDatabase.instance.ref().child('students');
  final _storageRef = FirebaseStorage.instance.ref().child('profile_photos');

  File? _image;
  String _firstName = '';
  String _lastName = '';
  int _age = 0;
  bool _isMale = false;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(source: ImageSource.gallery);
    setState(() {
      _image = File(pickedImage!.path);
    });
  }

  Future<void> _saveData() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      if (_image != null) {
        final imageRef = _storageRef.child('${DateTime.now()}.jpg');
        await imageRef.putFile(_image!);
        final imageUrl = await imageRef.getDownloadURL();
        _databaseRef.push().set({
          'firstName': _firstName,
          'lastName': _lastName,
          'age': _age,
          'gender': _isMale ? 'Male' : 'Female',
          'profilePhotoUrl': imageUrl,
        });
      }
      setState(() {
        _image = null;
        _firstName = '';
        _lastName = '';
        _age = 0;
        _isMale = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Student information saved successfully!'),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Student Information'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              GestureDetector(
                onTap: _pickImage,
                child: _image == null
                    ? const Icon(Icons.add_a_photo, size: 100)
                    : Image.file(_image!, width: 100, height: 100),
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'First Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter first name';
                  }
                  return null;
                },
                onSaved: (value) => _firstName = value!,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Last Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter last name';
                  }
                  return null;
                },
                onSaved: (value) => _lastName = value!,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Age'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter age';
                  }
                  return null;
                },
                onSaved: (value) => _age = int.parse(value!),
              ),
              Row(
                children: [
                  const Text('Gender:'),
                  Checkbox(
                    value: _isMale,
                    onChanged: (value) {
                      setState(() {
                        _isMale = value!;
                      });
                    },
                  ),
                  const Text('Male'),
                ],
              ),
              ElevatedButton(
                onPressed: _saveData,
                child: const Text('Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

