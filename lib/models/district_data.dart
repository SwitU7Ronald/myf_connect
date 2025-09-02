// lib/utils/district_data.dart
class DistrictData {
  // Static map containing all districts and their corresponding MYFs
  static const Map<String, List<String>> districtMyfMap = {
    "Ahmedabad North District": [
      "Carmel Methodist Church MYF",
      "Aden Methodist Church MYF",
      "Tamil Methodist Church MYF",
      "Sinai Methodist Church MYF",
    ],
    "Ahmedabad East District": [
      "Maninagar Methodist Church MYF",
      "Shalom Methodist Church MYF",
      "Christ Methodist Church (Barejdi) MYF",
    ],
    "Ahmedabad West District": [
      "Raikhad Methodist Church MYF",
      "Bethani Jubilee Methodist Church MYF",
      "Agape Methodist Church MYF",
      "Shahpur Methodist Church MYF",
    ],
    "Bharuch District": [
      "Eben Ezer Methodist Church MYF",
    ],
    "Surat District": [
      "Epworth Methodist Church MYF",
    ],
    "Anand District": [
      "Hebron Badapura Methodist Church MYF",
      "Ajarpura/ Karasan Pura MYF",
      "Wesley Kunjrav Methodist Church MYF",
      "Bless Methodist Church MYF",
      "Bethel Methodist Church MYF",
      "Horeb Methodist Church MYF",
    ],
    "Kathlal District": [
      "Kathlal Methodist Church MYF",
      "Wesley Mahudha Methodist Church MYF",
      "Anara Methodist Church MYF",
      "Bethel dhandhodi Methodist Church MYF",
      "Alpha Vansoli Methodist Church MYF",
    ],
    "Umreth District": [
      "Thasra Methodist Church MYF",
      "Rasulpur Methodist Church MYF",
      "Sureli Methodist Church MYF",
      "Sundalpura Methodist Church MYF",
      "Khijalpur Methodist Church MYF",
      "Thamna Methodist Church MYF",
      "Kalsar Methodist Church MYF",
      "Pansora Methodist Church MYF",
    ],
    "Godhra District": [
      "Godhra Methodist Church MYF",
      "Kalol Methodist Church MYF",
      "Halol Methodist Church MYF",
      "Rabod Methodist Church MYF",
    ],
    "Vadodara District": [
      "Hosanna Methodist Church MYF",
      "Sharon Methodist Church MYF",
      "Centenary Methodist Church MYF",
      "Canan Methodist Church MYF",
      "Hope Methodist Church MYF",
      "Faith Methodist Church MYF",
      "City Christ Methodist Church MYF",
      "Bethlehem Methodist Church MYF",
    ],
  };

  /// Get all available districts
  static List<String> get districts => districtMyfMap.keys.toList()..sort();

  /// Get MYFs for a specific district
  static List<String> getMyfsByDistrict(String district) {
    return districtMyfMap[district] ?? [];
  }

  /// Check if a district exists
  static bool isValidDistrict(String district) {
    return districtMyfMap.containsKey(district);
  }

  /// Check if a MYF exists for a given district
  static bool isValidMyfForDistrict(String district, String myf) {
    final myfs = districtMyfMap[district];
    return myfs?.contains(myf) ?? false;
  }

  /// Get district by MYF name (reverse lookup)
  static String? getDistrictByMyf(String myf) {
    for (final entry in districtMyfMap.entries) {
      if (entry.value.contains(myf)) {
        return entry.key;
      }
    }
    return null;
  }

  /// Get total count of districts
  static int get totalDistricts => districtMyfMap.length;

  /// Get total count of MYFs
  static int get totalMyfs =>
      districtMyfMap.values.fold(0, (sum, myfs) => sum + myfs.length);

  /// Get statistics
  static Map<String, int> get statistics => {
    'districts': totalDistricts,
    'myfs': totalMyfs,
  };
}