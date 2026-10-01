class DistrictData {
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

  static List<String> get districts => [..._baseDistricts, 'Other'];

  static List<String> get baseDistricts => _baseDistricts;

  static const Map<String, List<String>> districtMyfMap = {
    'Ahmedabad North District': [
      'Carmel MYF Church MYF',
      'Aden MYF Church MYF',
      'Tamil MYF Church MYF',
      'Sinai MYF Church MYF',
    ],
    'Ahmedabad East District': [
      'Maninagar MYF Church MYF',
      'Shalom MYF Church MYF',
      'Christ MYF Church (Barejdi) MYF',
    ],
    'Ahmedabad West District': [
      'Raikhad MYF Church MYF',
      'Bethani Jubilee MYF Church MYF',
      'Agape MYF Church MYF',
      'Shahpur MYF Church MYF',
    ],
    'Bharuch District': ['Eben Ezer MYF Church MYF'],
    'Surat District': ['Epworth MYF Church MYF'],
    'Anand District': [
      'Hebron Badapura MYF Church MYF',
      'Ajarpura/ Karasan Pura MYF',
      'Wesley Kunjrav MYF Church MYF',
      'Bless MYF Church MYF',
      'Bethel MYF Church MYF',
      'Horeb MYF Church MYF',
    ],
    'Kathlal District': [
      'Kathlal MYF Church MYF',
      'Wesley Mahudha MYF Church MYF',
      'Anara MYF Church MYF',
      'Bethel dhandhodi MYF Church MYF',
      'Alpha Vansoli MYF Church MYF',
    ],
    'Umreth District': [
      'Thasra MYF Church MYF',
      'Rasulpur MYF Church MYF',
      'Sureli MYF Church MYF',
      'Sundalpura MYF Church MYF',
      'Khijalpur MYF Church MYF',
      'Thamna MYF Church MYF',
      'Kalsar MYF Church MYF',
      'Pansora MYF Church MYF',
    ],
    'Godhra District': [
      'Godhra MYF Church MYF',
      'Kalol MYF Church MYF',
      'Halol MYF Church MYF',
      'Rabod MYF Church MYF',
    ],
    'Vadodara District': [
      'Hosanna MYF Church MYF',
      'Sharon MYF Church MYF',
      'Centenary MYF Church MYF',
      'Canan MYF Church MYF',
      'Hope MYF Church MYF',
      'Faith MYF Church MYF',
      'City Christ MYF Church MYF',
      'Bethlehem MYF Church MYF',
    ],
  };

  static int get totalDistricts => _baseDistricts.length;
  static int get totalMyfs =>
      districtMyfMap.values.fold(0, (sum, myfs) => sum + myfs.length);

  static List<String> getMyfsByDistrict(String district) {
    return districtMyfMap[district] ?? [];
  }

  static bool isValidDistrict(String district) {
    return _baseDistricts.contains(district) || district == 'Other';
  }

  static bool isValidMyfForDistrict(String district, String myf) {
    if (district == 'Other') return true;
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
