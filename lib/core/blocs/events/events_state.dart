part of 'events_cubit.dart';

/// Base state for [EventsCubit].
abstract class EventsState extends Equatable {
  const EventsState();

  @override
  List<Object> get props => [];
}

class EventsInitial extends EventsState {
  const EventsInitial();
}

class EventsLoading extends EventsState {
  const EventsLoading();
}

class EventsLoaded extends EventsState {
  final List<AppEvent> upcomingEvents;
  final List<AppEvent> pastEvents;

  const EventsLoaded({required this.upcomingEvents, required this.pastEvents});

  @override
  List<Object> get props => [upcomingEvents, pastEvents];
}

class EventsError extends EventsState {
  final String message;

  const EventsError(this.message);

  @override
  List<Object> get props => [message];
}
