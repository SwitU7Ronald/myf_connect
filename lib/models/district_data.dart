// lib/models/district_data.dart
class DistrictData {
  // Original district list
  static const List<String> _baseDistricts = [
    'Ahmedabad North District',
    'Ahmedabad East District',
    'Ahmedabad West District',
    'Bharuch District',
    'Surat District',
    'Anand District',
    'Kathlal District',
    'Umreth District',
    'Godhra District',
    'Vadodara District',
  ];

  // District list with "Other" option
  static List<String> get districts => [..._baseDistricts, 'Other'];

  // Base districts without "Other" (for validation)
  static List<String> get baseDistricts => _baseDistricts;

  static const Map<String, List<String>> districtMyfMap = {
    'Ahmedabad North District': [
      'Carmel Methodist Church MYF',
      'Aden Methodist Church MYF',
      'Tamil Methodist Church MYF',
      'Sinai Methodist Church MYF',
    ],
    'Ahmedabad East District': [
      'Maninagar Methodist Church MYF',
      'Shalom Methodist Church MYF',
      'Christ Methodist Church (Barejdi) MYF',
    ],
    'Ahmedabad West District': [
      'Raikhad Methodist Church MYF',
      'Bethani Jubilee Methodist Church MYF',
      'Agape Methodist Church MYF',
      'Shahpur Methodist Church MYF',
    ],
    'Bharuch District': [
      'Eben Ezer Methodist Church MYF',
    ],
    'Surat District': [
      'Epworth Methodist Church MYF',
    ],
    'Anand District': [
      'Hebron Badapura Methodist Church MYF',
      'Ajarpura/ Karasan Pura MYF',
      'Wesley Kunjrav Methodist Church MYF',
      'Bless Methodist Church MYF',
      'Bethel Methodist Church MYF',
      'Horeb Methodist Church MYF',
    ],
    'Kathlal District': [
      'Kathlal Methodist Church MYF',
      'Wesley Mahudha Methodist Church MYF',
      'Anara Methodist Church MYF',
      'Bethel dhandhodi Methodist Church MYF',
      'Alpha Vansoli Methodist Church MYF',
    ],
    'Umreth District': [
      'Thasra Methodist Church MYF',
      'Rasulpur Methodist Church MYF',
      'Sureli Methodist Church MYF',
      'Sundalpura Methodist Church MYF',
      'Khijalpur Methodist Church MYF',
      'Thamna Methodist Church MYF',
      'Kalsar Methodist Church MYF',
      'Pansora Methodist Church MYF',
    ],
    'Godhra District': [
      'Godhra Methodist Church MYF',
      'Kalol Methodist Church MYF',
      'Halol Methodist Church MYF',
      'Rabod Methodist Church MYF',
    ],
    'Vadodara District': [
      'Hosanna Methodist Church MYF',
      'Sharon Methodist Church MYF',
      'Centenary Methodist Church MYF',
      'Canan Methodist Church MYF',
      'Hope Methodist Church MYF',
      'Faith Methodist Church MYF',
      'City Christ Methodist Church MYF',
      'Bethlehem Methodist Church MYF',
    ],
  };

  // Statistics
  static int get totalDistricts => _baseDistricts.length;
  static int get totalMyfs => districtMyfMap.values.fold(0, (sum, myfs) => sum + myfs.length);

  // Helper methods
  static List<String> getMyfsByDistrict(String district) {
    return districtMyfMap[district] ?? [];
  }

  static bool isValidDistrict(String district) {
    return _baseDistricts.contains(district) || district == 'Other';
  }

  static bool isValidMyfForDistrict(String district, String myf) {
    if (district == 'Other') return true; // Allow any MYF for "Other" district
    return getMyfsByDistrict(district).contains(myf);
  }

  static String? getDistrictByMyf(String myf) {
    for (final entry in districtMyfMap.entries) {
      if (entry.value.contains(myf)) {
        return entry.key;
      }
    }
    return null;
  }
}
