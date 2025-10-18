import 'package:adhan/adhan.dart';
import 'package:geolocator/geolocator.dart';

class PrayerTimeService {
  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    final position = await Geolocator.getCurrentPosition();
    print('📍 Location fetched: Lat=${position.latitude}, Lng=${position.longitude}');
    return position;
  }


  Future<PrayerTimes> getPrayerTimes({
    CalculationMethod method = CalculationMethod.egyptian, 
    Madhab madhab = Madhab.shafi, 
  }) async {
    try {
      final position = await _determinePosition();
      final coordinates = Coordinates(position.latitude, position.longitude);

      final params = method.getParameters();
      params.madhab = madhab;

      final prayerTimes = PrayerTimes.today(coordinates, params);
      
      return prayerTimes;
    } catch (e) {
      throw Exception('Failed to get prayer times: ${e.toString()}');
    }
  }
}