import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:myf_connect/features/events/data/models/event.dart';
import 'package:myf_connect/features/events/data/repositories/event_repository.dart';
import 'package:myf_connect/core/error/error_handler.dart';
import 'package:myf_connect/core/constants/app_constants.dart';

part 'events_state.dart';

/// Shared cubit for loading events for any parent (Camp or MYF).
///
/// Replaces the duplicate [CampEventsCubit] and [MyfEventsCubit].
/// Pass [isCamp] to determine which Firestore collection to query.
class EventsCubit extends Cubit<EventsState> {
  final EventRepository _eventRepository;
  final String parentId;
  final bool isCamp;
  StreamSubscription<List<AppEvent>>? _subscription;

  EventsCubit({
    required EventRepository eventRepository,
    required this.parentId,
    required this.isCamp,
  })  : _eventRepository = eventRepository,
        super(const EventsInitial());

  String get _collection =>
      isCamp ? AppConstants.campsCollection : AppConstants.myfsCollection;

  /// Load (or reload) events for [parentId].
  void loadEvents() {
    emit(const EventsLoading());
    _subscription?.cancel();
    _subscription = _eventRepository
        .getAllEvents(_collection, parentId)
        .listen(
          (events) {
            final now = DateTime.now();
            emit(EventsLoaded(
              upcomingEvents: events
                  .where((e) => !e.dateTime.isBefore(now))
                  .toList(),
              pastEvents: events
                  .where((e) => e.dateTime.isBefore(now))
                  .toList(),
            ));
          },
          onError: (error) {
            emit(EventsError(ErrorHandler.handle(error).message));
          },
        );
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
