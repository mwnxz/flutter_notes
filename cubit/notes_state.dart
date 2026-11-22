part of 'notes_cubit.dart';

@immutable
sealed class NotesState {}

// ВАЖНО: Этот класс должен быть здесь
class Note {
  final String text;
  final bool isImportant;

  Note({required this.text, this.isImportant = false});

  Note copyWith({String? text, bool? isImportant}) {
    return Note(
      text: text ?? this.text,
      isImportant: isImportant ?? this.isImportant,
    );
  }
}

final class NotesInitial extends NotesState {
  final List<Note> notes; // Теперь список хранит объекты Note
  final String currentText;
  final int? editingIndex;

  NotesInitial({
    this.notes = const [],
    this.currentText = '',
    this.editingIndex,
  });

  NotesInitial copyWith({
    List<Note>? notes,
    String? currentText,
    int? editingIndex,
    bool clearEditing = false,
  }) {
    return NotesInitial(
      notes: notes ?? this.notes,
      currentText: currentText ?? this.currentText,
      editingIndex: clearEditing ? null : (editingIndex ?? this.editingIndex),
    );
  }
}