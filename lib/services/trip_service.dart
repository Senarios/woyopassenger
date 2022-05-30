import 'package:cheetah_redux/models/direction_details.dart';

class TripService {
  static double calculateFares(DirectionDetails directionDetails) {
    if (directionDetails == null) {
      return 0;
    }

    //in terms USD
    double timeTraveledFare = (directionDetails.durationValue / 60) * 0.20;
    double distancTraveledFare = (directionDetails.distanceValue / 1000) * 0.20;
    double totalFareAmount = timeTraveledFare + distancTraveledFare;

    //Local Currency
    //1$ = 160 RS
    //double totalLocalAmount = totalFareAmount * 160;
    double valueInCFA = totalFareAmount * 420;
    return valueInCFA.truncateToDouble();
  }
}
