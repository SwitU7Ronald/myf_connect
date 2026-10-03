import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

/// A simple, immutable model for a MYF group.
class Myf extends Equatable {
  final String id;
  final String title;
  final String description;

  const Myf({required this.id, required this.title, required this.description});

  factory Myf.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return Myf(
      id: doc.id,
      title: data['title'] as String? ?? 'Untitled MYF',
      description: data['description'] as String? ?? '',
    );
  }

  @override
  List<Object?> get props => [id, title, description];
}
