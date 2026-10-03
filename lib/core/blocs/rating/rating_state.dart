part of 'rating_cubit.dart';

/// Base state for [RatingCubit].
abstract class RatingState extends Equatable {
  const RatingState();

  @override
  List<Object> get props => [];
}

class RatingInitial extends RatingState {
  const RatingInitial();
}

class RatingLoading extends RatingState {
  const RatingLoading();
}

class RatingLoaded extends RatingState {
  final double avgRating;
  final double count;

  const RatingLoaded({required this.avgRating, required this.count});

  @override
  List<Object> get props => [avgRating, count];
}

class RatingError extends RatingState {
  final String message;

  const RatingError(this.message);

  @override
  List<Object> get props => [message];
}
