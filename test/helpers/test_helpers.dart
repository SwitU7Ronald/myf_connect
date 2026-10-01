import 'package:mockito/annotations.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:myf_connect/features/auth/data/repositories/auth_repository.dart';
import 'package:myf_connect/features/auth/data/repositories/user_repository.dart';
import 'package:myf_connect/features/admin/data/repositories/admin_repository.dart';
import 'package:myf_connect/features/camps/data/repositories/camps_repository.dart';
import 'package:myf_connect/features/myfs/data/repositories/myfs_repository.dart';
import 'package:myf_connect/features/events/data/repositories/event_repository.dart';

@GenerateMocks([
  AuthRepository,
  UserRepository,
  AdminRepository,
  CampsRepository,
  MyfsRepository,
  EventRepository,
  FirebaseAuth,
  GoogleSignIn,
])
void main() {}
