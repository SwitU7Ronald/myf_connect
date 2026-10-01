import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:myf_connect/features/events/data/repositories/event_repository.dart';
import 'package:myf_connect/core/error/error_handler.dart';
import 'package:myf_connect/core/constants/app_constants.dart';

part 'rating_state.dart';

/// Shared cubit for loading the aggregate rating for any parent (Camp or MYF).
///
/// Replaces the duplicate [CampRatingCubit] and [MyfRatingCubit].
/// Pass [isCamp] to determine which Firestore collection to query.
class RatingCubit extends Cubit<RatingState> {
  final EventRepository _eventRepository;
  final String parentId;
  final bool isCamp;
  StreamSubscription<Map<String, double>>? _subscription;

  RatingCubit({
    required EventRepository eventRepository,
    required this.parentId,
    required this.isCamp,
  })  : _eventRepository = eventRepository,
        super(const RatingInitial());

  String get _collection =>
      isCamp ? AppConstants.campsCollection : AppConstants.myfsCollection;

  /// Load (or reload) the average rating for [parentId].
  void loadRating() {
    emit(const RatingLoading());
    _subscription?.cancel();
    _subscription = _eventRepository
        .getAverageRating(_collection, parentId)
        .listen(
          (ratingData) {
            emit(RatingLoaded(
              avgRating: ratingData['avgRating'] ?? 0.0,
              count: ratingData['count'] ?? 0.0,
            ));
          },
          onError: (error) {
            emit(RatingError(ErrorHandler.handle(error).message));
          },
        );
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
