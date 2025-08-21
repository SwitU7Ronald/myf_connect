import '../models/app_user.dart';

class PermissionsService {
  bool hasGodhra2025(AppUser? user) {
    if (user == null) return false;
    return user.permissions.contains('godhra_camp_2025');
  }

  bool hasMYF(AppUser? user) {
    if (user == null) return false;
    return user.permissions.contains('myf');
  }
}
