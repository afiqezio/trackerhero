import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';

class FormPage extends StatefulWidget {
  @override
  _FormPageState createState() => _FormPageState();
}

class _FormPageState extends State<FormPage> {
  final _formKey = GlobalKey<FormState>();
  final List<Map<String, String>> _dropdownItems = [
    {'title': 'Scheduled', 'details': 'Details for Scheduled'},
    {'title': 'Remote', 'details': 'Details for Remote'},
    {'title': 'Safety', 'details': 'Details for Safety'},
  ];
  final ImagePicker _picker = ImagePicker();
  final List<File> _attachments = [];
  final MapController _mapController = MapController();

  double? _latitude;
  double? _longitude;
  File? _image;
  LatLng? _userLocation;

  String? _selectedItem;
  final TextEditingController _textField1Controller = TextEditingController();
  final TextEditingController _textField2Controller = TextEditingController();
  final TextEditingController _textField3Controller = TextEditingController();
  final TextEditingController _textField4Controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _getUserLocation();
  }

  Future<void> _getUserLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Check if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled, show an error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Location services are disabled.")),
      );
      return;
    }

    // Check location permissions
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, show an error
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Location permissions are denied")),
        );
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are permanently denied
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Location permissions are permanently denied")),
      );
      return;
    }

    if (permission == LocationPermission.whileInUse || permission == LocationPermission.always) {
      Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      setState(() {
        _latitude = position.latitude;
        _longitude = position.longitude;
        _userLocation = LatLng(_latitude!, _longitude!);
      });

      // Move the map to the new location
      _mapController.move(_userLocation!, 13.0);
    }

  }

  Future<void> _pickAttachment() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Choose Attachment Source"),
          content: Text("Would you like to take a new photo or select from your gallery?"),
          actions: [
            TextButton(
              onPressed: () async {
                Navigator.pop(context); // Close dialog
                final XFile? image = await _picker.pickImage(source: ImageSource.camera);
                if (image != null) {
                  setState(() {
                    _attachments.add(File(image.path));
                    _image = File(image.path);
                  });
                }
              },
              child: Text("Camera"),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context); // Close dialog
                final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
                if (image != null) {
                  setState(() {
                    _attachments.add(File(image.path));
                    _image = File(image.path);
                  });
                }
              },
              child: Text("Gallery"),
            ),
          ],
        );
      },
    );
  }

  // Remove an attachment from the list
  void _removeAttachment(int index) {
    setState(() {
      _attachments.removeAt(index);
    });
  }

  void _showCustomDropdownDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: _dropdownItems.map((item) {
                return ListTile(
                  title: Text(
                    item['title']!,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(item['details']!),
                  onTap: () {
                    setState(() {
                      _selectedItem = item['title'];
                    });
                    Navigator.of(context).pop();
                  },
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(child: Text("Site Visit")),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Center(
            child: Container(
              padding: EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 10,
                    offset: Offset(0, 5),
                  ),
                ],
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    GestureDetector(
                      onTap: () => _showCustomDropdownDialog(context),
                      child: InputDecorator(
                        decoration: InputDecoration(
                          labelText: 'Visit Type',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                        ),
                        child: Text(_selectedItem ?? 'Tap to select an option'),
                      ),
                    ),
                    SizedBox(height: 16),

                    TextFormField(
                      controller: _textField1Controller,
                      decoration: InputDecoration(
                        labelText: 'Location',
                        prefixIcon: Icon(Icons.location_on),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter text for Location';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16),
                    TextFormField(
                      controller: _textField2Controller,
                      decoration: InputDecoration(
                        labelText: 'Address',
                        prefixIcon: Icon(Icons.home),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter text for Address';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16),
                    TextFormField(
                      controller: _textField3Controller,
                      decoration: InputDecoration(
                        labelText: 'Objective',
                        prefixIcon: Icon(Icons.flag),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter text for Objective';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16),
                    TextFormField(
                      controller: _textField4Controller,
                      decoration: InputDecoration(
                        labelText: 'Remark',
                        prefixIcon: Icon(Icons.comment),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter text for Remark';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16),

                    // // Display Latitude and Longitude
                    // if (_latitude != null && _longitude != null)
                    //   Text(
                    //     'Current Location: Latitude $_latitude, Longitude $_longitude',
                    //     style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    //   ),
                    // SizedBox(height: 16),

                    // Map with a marker
                    Container(
                      height: 250,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15.0),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 10,
                            offset: Offset(0, 5),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(15.0),
                        child: FlutterMap(
                          mapController: _mapController,
                          options: MapOptions(
                            initialCenter: _userLocation ?? LatLng(0.0, 0.0),
                            initialZoom: 13.0,
                          ),

                          children: [
                            TileLayer(
                              urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                              subdomains: ['a', 'b', 'c'],
                            ),
                            MarkerLayer(
                              markers: [
                                if (_latitude != null && _longitude != null)
                                  Marker(
                                    point: LatLng(_latitude!, _longitude!),
                                    width: 80,
                                    height: 80,
                                    child: Icon(
                                      Icons.location_pin,
                                      color: Colors.red,
                                      size: 40.0,
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 16),

                    // Attachment Button
                    GestureDetector(
                      onTap: _pickAttachment,
                      child: Container(
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.attach_file),
                            SizedBox(width: 10),
                            Text(_image == null ? "Tap to attach image" : "Image Attached"),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 16),

                    // Display Attachments
                    if (_attachments.isNotEmpty)
                      Wrap(
                        spacing: 8.0,
                        children: _attachments.asMap().entries.map((entry) {
                          int index = entry.key;
                          File file = entry.value;
                          return Stack(
                            clipBehavior: Clip.none,  // Allow the delete icon to overlap
                            children: [
                              Image.file(
                                file,
                                width: 100,
                                height: 100,
                                fit: BoxFit.cover,
                              ),
                              Positioned(
                                top: 0,
                                right: 0,
                                child: IconButton(
                                  icon: Icon(Icons.delete, color: Colors.red),
                                  onPressed: () {
                                    _removeAttachment(index);
                                  },
                                ),
                              ),
                            ],
                          );
                        }).toList(),
                      ),
                    SizedBox(height: 16),


                    ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState?.validate() ?? false) {
                          final selectedOption = _selectedItem;
                          final field1Text = _textField1Controller.text;
                          final field2Text = _textField2Controller.text;
                          final field3Text = _textField3Controller.text;
                          final field4Text = _textField4Controller.text;

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Submitted: Option=$selectedOption, Field1=$field1Text, Field2=$field2Text, Field3=$field3Text, Field4=$field4Text',
                              ),
                            ),
                          );
                        }
                      },
                      child: Text('Submit'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
