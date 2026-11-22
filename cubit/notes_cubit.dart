import 'package:flutter/material.dart';
import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

part 'notes_state.dart';

class NotesCubit extends Cubit<NotesState> {
  NotesCubit() : super(NotesInitial());

  void updateText(String text) {
    if (state is NotesInitial) {
      final currentState = state as NotesInitial;
      emit(currentState.copyWith(currentText: text));
    }
  }

  void saveNote() {
    if (state is NotesInitial) {
      final currentState = state as NotesInitial;
      if (currentState.currentText.trim().isEmpty) return;

      List<Note> updatedNotes = List.from(currentState.notes);
      
      if (currentState.editingIndex != null) {
        final oldNote = updatedNotes[currentState.editingIndex!];
        updatedNotes[currentState.editingIndex!] = Note(
          text: currentState.currentText,
          isImportant: oldNote.isImportant,
        );
      } else {
        updatedNotes.add(Note(text: currentState.currentText));
      }

      emit(currentState.copyWith(
        notes: updatedNotes,
        currentText: '',
        clearEditing: true,
      ));
    }
  }

  void editNote(int index) {
    if (state is NotesInitial) {
      final currentState = state as NotesInitial;
      emit(currentState.copyWith(
        editingIndex: index,
        currentText: currentState.notes[index].text,
      ));
    }
  }

  void deleteNote(int index) {
    if (state is NotesInitial) {
      final currentState = state as NotesInitial;
      List<Note> updatedNotes = List.from(currentState.notes);
      updatedNotes.removeAt(index);
      bool clearText = currentState.editingIndex == index;
      
      emit(currentState.copyWith(
        notes: updatedNotes,
        clearEditing: clearText,
        currentText: clearText ? '' : currentState.currentText,
      ));
    }
  }

  void toggleImportant(int index) {
    if (state is NotesInitial) {
      final currentState = state as NotesInitial;
      List<Note> updatedNotes = List.from(currentState.notes);
      updatedNotes[index] = updatedNotes[index].copyWith(
        isImportant: !updatedNotes[index].isImportant,
      );
      emit(currentState.copyWith(notes: updatedNotes));
    }
  }

  void resetImportant(int index) {
    if (state is NotesInitial) {
      final currentState = state as NotesInitial;
      List<Note> updatedNotes = List.from(currentState.notes);
      updatedNotes[index] = updatedNotes[index].copyWith(isImportant: false);
      emit(currentState.copyWith(notes: updatedNotes));
    }
  }
}