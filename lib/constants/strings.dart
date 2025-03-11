class AppStrings {
  static const String appName = 'PM2.5 App';

  //API Path
  static const String urls = 'http://102.211.232.170:3000';
  static const String apiGetAir4thai = '$urls/api/get-air4thai';
  static const String apiGetAir4thaiStationId = '$urls/api/get-air4thai-station-id';
  static const String apiGetTopPredictions1 = '$urls/api/get-top-predictions-1';
  static const String apiSetDistanceWeatherArea = '$urls/api/set-distance-weather-area';
  static const String apiSetDistanceAir4thaiArea = '$urls/api/set-distance-air4thai-area';
}
