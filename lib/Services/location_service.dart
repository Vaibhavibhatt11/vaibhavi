// import 'package:location/location_.dart';

// Future<LocationData?> getCurrentLocation() async {
//   Location location = Location();

//   bool serviceEnabled = await location.serviceEnabled();
//   if (!serviceEnabled) {
//     serviceEnabled = await location.requestService();
//     if (!serviceEnabled) return null;
//   }

//   PermissionStatus permissionGranted = await location.hasPermission();
//   if (permissionGranted == PermissionStatus.denied) {
//     permissionGranted = await location.requestPermission();
//     if (permissionGranted != PermissionStatus.granted) return null;
//   }

//   return await location.getLocation();
// }
