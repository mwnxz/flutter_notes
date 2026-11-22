import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'cubit/notes_cubit.dart';

void main() {
  runApp(const NotesApp());
}

class NotesApp extends StatelessWidget {
  const NotesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => NotesCubit(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Заметки',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          scaffoldBackgroundColor: Colors.grey[100],
        ),
        home: const NotesScreen(),
      ),
    );
  }
}

class NotesScreen extends StatelessWidget {
  const NotesScreen({super.key});

  // Функция для показа полного текста (по обычному нажатию)
  void _showFullText(BuildContext context, Note note) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(note.isImportant ? '⭐ Важная заметка' : 'Заметка'),
        content: SingleChildScrollView(child: Text(note.text)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Закрыть'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Мои заметки'),
        centerTitle: true,
      ),
      body: BlocBuilder<NotesCubit, NotesState>(
        builder: (context, state) {
          if (state is NotesInitial) {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  TextField(
                    controller: TextEditingController(text: state.currentText)
                      ..selection = TextSelection.collapsed(offset: state.currentText.length),
                    onChanged: (value) {
                      context.read<NotesCubit>().updateText(value);
                    },
                    decoration: InputDecoration(
                      hintText: 'Введите текст заметки',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    maxLines: null,
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {
                        context.read<NotesCubit>().saveNote();
                        FocusScope.of(context).unfocus();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        state.editingIndex != null ? 'Сохранить изменения' : 'Сохранить',
                        style: const TextStyle(fontSize: 16, color: Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: state.notes.isEmpty
                        ? const Center(
                            child: Text(
                              'Список заметок пуст',
                              style: TextStyle(color: Colors.grey, fontSize: 16),
                            ),
                          )
                        : ListView.builder(
                            itemCount: state.notes.length,
                            itemBuilder: (context, index) {
                              final note = state.notes[index];

                              return Dismissible(
                                key: ValueKey(note.text + index.toString()), // Уникальный ключ
                                // Свайп влево - удаление
                                direction: DismissDirection.horizontal,
                                confirmDismiss: (direction) async {
                                  if (direction == DismissDirection.endToStart) {
                                    // Удаление
                                    return true;
                                  } else if (direction == DismissDirection.startToEnd) {
                                    // Свайп вправо - сброс важности
                                    if (note.isImportant) {
                                      context.read<NotesCubit>().resetImportant(index);
                                    }
                                    return false; // Не удаляем карточку
                                  }
                                  return false;
                                },
                                onDismissed: (direction) {
                                  // Если свайп влево (удаление)
                                  if (direction == DismissDirection.endToStart) {
                                    context.read<NotesCubit>().deleteNote(index);
                                  }
                                },
                                background: Container(
                                  alignment: Alignment.centerLeft,
                                  padding: const EdgeInsets.only(left: 20),
                                  color: Colors.green,
                                  child: const Icon(Icons.star, color: Colors.white),
                                ),
                                secondaryBackground: Container(
                                  alignment: Alignment.centerRight,
                                  padding: const EdgeInsets.only(right: 20),
                                  color: Colors.red,
                                  child: const Icon(Icons.delete, color: Colors.white),
                                ),
                                child: GestureDetector(
                                  // ОБЫЧНОЕ НАЖАТИЕ - просмотр
                                  onTap: () => _showFullText(context, note),
                                  // ДВОЙНОЕ НАЖАТИЕ - важность
                                  onDoubleTap: () {
                                    context.read<NotesCubit>().toggleImportant(index);
                                  },
                                  // ДОЛГОЕ НАЖАТИЕ - редактирование
                                  onLongPress: () {
                                    context.read<NotesCubit>().editNote(index);
                                  },
                                  child: Card(
                                    margin: const EdgeInsets.only(bottom: 10),
                                    color: note.isImportant ? Colors.yellow[100] : Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: ListTile(
                                      title: Text(
                                        note.text,
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: note.isImportant
                                              ? FontWeight.bold
                                              : FontWeight.normal,
                                        ),
                                      ),
                                      trailing: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          if (note.isImportant)
                                            const Icon(Icons.star, color: Colors.amber),
                                          IconButton(
                                            icon: const Icon(Icons.edit, color: Colors.orange),
                                            onPressed: () {
                                              context.read<NotesCubit>().editNote(index);
                                            },
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.delete, color: Colors.red),
                                            onPressed: () {
                                              context.read<NotesCubit>().deleteNote(index);
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            );
          }
          return const SizedBox();
        },
      ),
    );
  }
}