import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class Camp extends Equatable {
  final String id;
  final String title;
  final String place;
  final String description;
  final DateTime? date;

  const Camp({
    required this.id,
    required this.title,
    required this.place,
    required this.description,
    this.date,
  });

  factory Camp.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};

    DateTime? dateObj;
    final dateVal = data['date'];
    if (dateVal is Timestamp) {
      dateObj = dateVal.toDate();
    } else if (dateVal is String) {
      dateObj = DateTime.tryParse(dateVal);
    }

    return Camp(
      id: doc.id,
      title: data['title'] as String? ?? 'Unnamed Camp',
      place: data['place'] as String? ?? '',
      description: data['description'] as String? ?? '',
      date: dateObj,
    );
  }

  @override
  List<Object?> get props => [id, title, place, description, date];
}
