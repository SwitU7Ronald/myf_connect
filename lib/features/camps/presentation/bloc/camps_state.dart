part of 'camps_bloc.dart';

enum CampsStatus { initial, loading, success, failure }

class CampsState extends Equatable {
  final CampsStatus status;
  final List<Camp> camps;
  final List<String> userPermissions;
  final String? errorMessage;

  const CampsState({
    this.status = CampsStatus.initial,
    this.camps = const [],
    this.userPermissions = const [],
    this.errorMessage,
  });

  CampsState copyWith({
    CampsStatus? status,
    List<Camp>? camps,
    List<String>? userPermissions,
    String? errorMessage,
  }) {
    return CampsState(
      status: status ?? this.status,
      camps: camps ?? this.camps,
      userPermissions: userPermissions ?? this.userPermissions,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, camps, userPermissions, errorMessage];
}
