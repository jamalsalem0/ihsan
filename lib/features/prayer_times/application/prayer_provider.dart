import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:adhan/adhan.dart';
import '../data/prayer_service.dart';

class PrayerInfo {
  final PrayerTimes prayerTimes;
  final Prayer nextPrayer;
  final Duration timeRemaining;

  PrayerInfo({
    required this.prayerTimes,
    required this.nextPrayer,
    required this.timeRemaining,
  });
}

final prayerServiceProvider = Provider((_) => PrayerTimeService());

final prayerTimesFutureProvider = FutureProvider<PrayerTimes>((ref) async {
  final service = ref.watch(prayerServiceProvider);
  return service.getPrayerTimes(
    method: CalculationMethod.egyptian, 
    madhab: Madhab.shafi,
  );
});

final prayerInfoProvider = StreamProvider<PrayerInfo>((ref) {
  final prayerTimesAsyncValue = ref.watch(prayerTimesFutureProvider);

  return prayerTimesAsyncValue.when(
    data: (prayerTimesToday) {
      return Stream.periodic(const Duration(seconds: 1), (_) {
        final now = DateTime.now();
        PrayerTimes activePrayerTimes = prayerTimesToday;
        Prayer nextPrayer = activePrayerTimes.nextPrayer();

        if (nextPrayer == Prayer.none) {
          final tomorrow = DateComponents.from(now.add(const Duration(days: 1)));
          activePrayerTimes = PrayerTimes(
            prayerTimesToday.coordinates,
            tomorrow,
            prayerTimesToday.calculationParameters,
          );
          nextPrayer = Prayer.fajr;
        }

        final timeRemaining = activePrayerTimes.timeForPrayer(nextPrayer)!.difference(now);

        return PrayerInfo(
          prayerTimes: activePrayerTimes,
          nextPrayer: nextPrayer,
          timeRemaining: timeRemaining,
        );
      });
    },
    error: (err, stack) => Stream.error(err, stack),
    loading: () => const Stream.empty(),
  );
});