part of 'myfs_bloc.dart';

enum MyfsStatus { initial, loading, success, failure }

class MyfsState extends Equatable {
  final MyfsStatus status;
  final List<Myf> myfs;
  final List<String> userPermissions;
  final String? errorMessage;

  const MyfsState({
    this.status = MyfsStatus.initial,
    this.myfs = const [],
    this.userPermissions = const [],
    this.errorMessage,
  });

  MyfsState copyWith({
    MyfsStatus? status,
    List<Myf>? myfs,
    List<String>? userPermissions,
    String? errorMessage,
  }) {
    return MyfsState(
      status: status ?? this.status,
      myfs: myfs ?? this.myfs,
      userPermissions: userPermissions ?? this.userPermissions,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, myfs, userPermissions, errorMessage];
}
