import 'dart:async';
// import 'dart:html';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:intl/intl.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:image_gallery_saver/image_gallery_saver.dart';
// import 'package:gallery_saver/gallery_saver.dart';

class Kamera extends StatefulWidget {
  final List<CameraDescription>? cameras;
  const Kamera({this.cameras, Key? key});

  @override
  State<Kamera> createState() => _KameraState();
}

class _KameraState extends State<Kamera> {
  late CameraController ccontroller;
  late GoogleMapController mapController;
  late Position position;
  late bool kameradepan = false;

  late String alamat1 = '';
  late String alamat2 = '';
  late String alamat3 = '';
  late String lat = '';
  late String long = '';
  late String _timeString;

  late double latitude = 0;
  late double longitude = 0;
  bool _kosong = false;

  XFile? pictureFile;
  final GlobalKey _globalKey = GlobalKey();
  late LatLng _currentPosition = LatLng(0, 0);

  @override
  void initState() {
    _timeString = _formatDateTime(DateTime.now());

    Timer.periodic(const Duration(seconds: 1), (Timer t) {
      _getTime();
      // _getAddressFromLatLng();
    });

    _getAddressFromLatLng();

    if (_currentPosition != LatLng(0, 0)) {
      _kosong = true;
    } else {
      _getAddressFromLatLng();
    }

    super.initState();
    // ccontroller = CameraController(
    //   const CameraDescription(
    //       name: "1",
    //       lensDirection: CameraLensDirection.front,
    //       sensorOrientation: 90),
    //   // widget.cameras![0],
    //   ResolutionPreset.max,
    //   enableAudio: false,
    // );

    _switchKamera();

    // ccontroller.setFlashMode(FlashMode.off); // flash off
    // // controller.setFlashMode(FlashMode.always); // flash on
    // // controller.setFlashMode(FlashMode.auto); // flash auto
    // ccontroller.initialize().then((_) {
    //   if (!mounted) {
    //     return;
    //   }
    //   setState(() {
    //     _handleLocationPermission();
    //     _getTime();
    //   });
    // });
  }

  @override
  void dispose() {
    ccontroller.dispose();
    super.dispose();
  }

  _switchKamera(){
    if(kameradepan == false){
      kameradepan = true;
      ccontroller = CameraController(
        const CameraDescription(
            name: "0",
            lensDirection: CameraLensDirection.back,
            sensorOrientation: 90),
        // widget.cameras![0],
        ResolutionPreset.max,
        enableAudio: false,
      );
    }else{
      kameradepan = false;
      ccontroller = CameraController(
        const CameraDescription(
            name: "1",
            lensDirection: CameraLensDirection.front,
            sensorOrientation: 90),
        // widget.cameras![0],
        ResolutionPreset.max,
        enableAudio: false,
      );
    }
    

    ccontroller.setFlashMode(FlashMode.off); // flash off
    // controller.setFlashMode(FlashMode.always); // flash on
    // controller.setFlashMode(FlashMode.auto); // flash auto
    ccontroller.initialize().then((_) {
      if (!mounted) {
        return;
      }  
    });
  }
  
  _saveLocalImage() async {
    RenderRepaintBoundary boundary =
        _globalKey.currentContext!.findRenderObject() as RenderRepaintBoundary;

    ui.Image image = await boundary.toImage();
    ByteData? byteData =
        await (image.toByteData(format: ui.ImageByteFormat.png));
    if (byteData != null) {
      final result =
          await ImageGallerySaver.saveImage(byteData.buffer.asUint8List());
      print(result);

      //     var filePath = await ImagePickerSaver.saveFile(
      //  fileData:byteData.buffer.asUint8List() );
      //    print(filePath);
    }
  }

  captureImage() async {
    final pixelRatio = MediaQuery.of(context).devicePixelRatio;
    final boundary =
        _globalKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
    final image = await boundary.toImage(pixelRatio: pixelRatio);
    final data = await image.toByteData(format: ui.ImageByteFormat.png);
    // return CaptureResult(data!.buffer.asUint8List(), image.width, image.height);
    ImageGallerySaver.saveImage(data!.buffer.asUint8List(), quality: 100);
  }

  Set<Marker> _createMarker() {
    return <Marker>[
      Marker(
        markerId: MarkerId("My Location"),
        position: _currentPosition,
        icon: BitmapDescriptor.defaultMarker,
        infoWindow: InfoWindow(title: "Lokasi Ku"),
      ),
    ].toSet();
  }

  _getAddressFromLatLng() async {
    // LocationPermission permission;
    // permission = await Geolocator.requestPermission();

    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    debugPrint('location: ${position.latitude}');

    latitude = position.latitude;
    longitude = position.longitude;

    LatLng location = LatLng(latitude, longitude);
    _currentPosition = location;

    List<Placemark> p =
        await placemarkFromCoordinates(position.latitude, position.longitude);
    var place = p[0];
    setState(() {
      alamat1 =
          "${place.subThoroughfare} ${place.thoroughfare} ${place.subLocality}";
      alamat2 = "${place.locality}";

      alamat3 = "${place.subAdministrativeArea} ${place.administrativeArea}";

      lat = "${latitude},";
      long = "${longitude}";

      if (_currentPosition != LatLng(0, 0)) {
        _kosong = true;
      }

      print("Hasil " + alamat1);
    });
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
    // specified current users location
    CameraPosition cameraPosition = new CameraPosition(
      target: LatLng(latitude, longitude),
      zoom: 14,
    );
    controller.animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
  }

  void _getTime() {
    final DateTime now = DateTime.now();
    final String formattedDateTime = _formatDateTime(now);
    setState(() {
      _timeString = formattedDateTime;
      if (_kosong == false) {
        _getAddressFromLatLng();
      }
      // print("JAM :" + _timeString);
    });
  }

  String _formatDateTime(DateTime dateTime) {
    return DateFormat('dd-MM-yyyy hh:mm:ss').format(dateTime);
  }

  Future<bool> _handleLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();

    if (!serviceEnabled) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'Location services are disabled. Please enable the services'),
        ),
      );
      permission = await Geolocator.requestPermission();
      return false;
    }
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Location permissions are denied')));
        return false;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
              'Location permissions are permanently denied, we cannot request permissions.')));
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    if (!ccontroller.value.isInitialized) {
      return const SizedBox(
        child: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    return Scaffold(
      appBar: AppBar(
        leading: Image.asset("assets/images/logo.png"),
        title: const Center(child: Text("LensCam")),
        actions: [
          IconButton(
              onPressed: () {
                _getAddressFromLatLng();
                _onMapCreated;
              },
              icon: const Icon(Icons.my_location))
        ],
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Center(
            child: RepaintBoundary(
              key: _globalKey,
              child: Stack(
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).size.height * .8,
                    width: MediaQuery.of(context).size.width,
                    child: CameraPreview(ccontroller),
                  ),
                  Positioned(
                    left: 0,
                    bottom: 0,
                    child: Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                            width: MediaQuery.of(context).size.width - 15,
                            decoration: BoxDecoration(
                              color: Colors.transparent.withOpacity(0.5),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        _timeString,
                                        style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      Text(
                                        lat,
                                        style: const TextStyle(
                                            color: Colors.white),
                                      ),
                                      Text(
                                        long,
                                        style: const TextStyle(
                                            color: Colors.white),
                                      ),
                                      Text(
                                        alamat1,
                                        style: const TextStyle(
                                            color: Colors.white),
                                      ),
                                      Text(
                                        alamat2,
                                        style: const TextStyle(
                                            color: Colors.white),
                                      ),
                                      Text(
                                        alamat3,
                                        style: const TextStyle(
                                            color: Colors.white),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Container(
                                        height: 80,
                                        width: 80,
                                        child: _kosong == false
                                            ? CircularProgressIndicator()
                                            :
                                            // Text(_currentPosition.toString()),
                                            Center(
                                                child: GoogleMap(
                                                  mapType: MapType.normal,
                                                  onMapCreated: _onMapCreated,
                                                  markers: _createMarker(),
                                                  myLocationEnabled: false,
                                                  zoomControlsEnabled: false,
                                                  initialCameraPosition:
                                                      CameraPosition(
                                                    target: _currentPosition,
                                                    zoom: 18.0,
                                                  ),
                                                ),
                                              ),
                                      ),
                                      // Text(_currentPosition.toString()),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                style: ButtonStyle(
                  backgroundColor: MaterialStatePropertyAll(Colors.blue),
                  
                ),
                onPressed: (){
                          _switchKamera();
                        }, child: Icon(Icons.cameraswitch, color: Colors.white,),),
              SizedBox(width: 10,),
              ElevatedButton(
                onPressed: () async {
                  // pictureFile = await ccontroller.takePicture();
                  // final docDir = await getExternalStorageDirectory();
                  // final path = docDir!.path + "/${pictureFile!.name}";
                  // print(("$path/${pictureFile!.name}"));
              
                  _saveLocalImage();
                  // captureImage();
                  // ignore: use_build_context_synchronously
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Tersimpan"),
                      backgroundColor: Colors.green,
                    ),
                  );
                  setState(() {});
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                ),
                child: Icon(Icons.camera_alt_outlined, color: Colors.white,),
              ),
            ],
          ),
          // if (pictureFile != null)
          //   Image.file(
          //     File(pictureFile!.path),
          //     height: MediaQuery.of(context).size.height / 10,
          //   ),
        ],
      ),
      // floatingActionButton: Column(
      //   crossAxisAlignment: CrossAxisAlignment.end,
      //   mainAxisAlignment: MainAxisAlignment.end,
      //   children: [
      //     FloatingActionButton(
      //       onPressed: () async {
      //         pictureFile = await controller.takePicture();
      //         final docDir = await getExternalStorageDirectory();
      //         final path = docDir!.path + "/${pictureFile!.name}";
      //         // pictureFile!.saveTo("$path/${pictureFile!.name}");
      //         print(("$path/${pictureFile!.name}"));
      //         _saveLocalImage();
      //         // ignore: use_build_context_synchronously
      //         ScaffoldMessenger.of(context).showSnackBar(
      //           const SnackBar(content: Text("Tersimpan")),
      //         );
      //         setState(() {});
      //       },
      //       child: const Icon(Icons.camera_alt),
      //     ),
      //     // FloatingActionButton(
      //     //   onPressed: () {
      //     //     _getAddressFromLatLng();
      //     //     print("LOKASI");
      //     //   },
      //     //   child: const Icon(Icons.my_location),
      //     // ),
      //   ],
      // ),
    );
  }
}
