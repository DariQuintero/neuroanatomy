import 'package:flutter/material.dart';
import 'package:neuroanatomy/cubits/auth_cubit/auth_cubit.dart';
import 'package:neuroanatomy/models/note.dart';
import 'package:neuroanatomy/models/segmento_cerebro.dart';
import 'package:neuroanatomy/pages/note_form_page/note_form_page.dart';
import 'package:neuroanatomy/services/chat_gpt_service.dart';
import 'package:neuroanatomy/services/notes_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class NotesPage extends StatefulWidget {
  final SegmentoCerebro segmento;
  const NotesPage({super.key, required this.segmento});

  @override
  State<NotesPage> createState() => _NotesPageState();
}

class _NotesPageState extends State<NotesPage> {
  List<Note> currentNotes = [];
  final List<Note> selectedNotesForActivity = [];
  bool isSelecting = false;

  @override
  Widget build(BuildContext context) {
    final userId = (context.read<AuthCubit>().state as AuthSuccess).user.uid;
    return Scaffold(
      appBar: AppBar(
        title: isSelecting
            ? const Text('Selecciona las notas')
            : Text('Notas ${widget.segmento.nombre}'),
        actions: [
          IconButton(
            onPressed: () async {
              selectedNotesForActivity.clear();
              setState(() {
                isSelecting = !isSelecting;
              });
            },
            icon: const Icon(Icons.chat),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          pushNoteFormPage(userId: userId);
        },
        child: isSelecting ? const Icon(Icons.check) : const Icon(Icons.add),
      ),
      body: StreamBuilder<List<Note>>(
        stream: NotesService(userId: userId).getNotesStream(widget.segmento.id),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            currentNotes = snapshot.data!;
            if (currentNotes.isEmpty) {
              return const Center(
                child: Text('No hay notas, agrega una usando el botón +'),
              );
            }
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final notes = snapshot.data!;
                final note = notes[index];
                if (isSelecting) {
                  return _buildCheckboxListTile(userId, note);
                } else {
                  return _buildListTile(userId, note);
                }
              },
            );
          } else {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
    );
  }

  Widget _buildListTile(String userId, Note note) {
    return ListTile(
      title: Text(note.title),
      subtitle: Text(
        note.content,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
      onTap: () {
        pushNoteFormPage(
          userId: userId,
          existingNote: note,
        );
      },
      onLongPress: () {
        NotesService(userId: userId).deleteNoteById(note.structureId, note.id!);
      },
    );
  }

  Widget _buildCheckboxListTile(String userId, Note note) {
    return CheckboxListTile(
      title: Text(note.title),
      subtitle: Text(
        note.content,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
      value: selectedNotesForActivity.contains(note),
      controlAffinity: ListTileControlAffinity.leading,
      onChanged: (value) {
        setState(
          () {
            // hide current snackbar
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
            if (value == true) {
              if (selectedNotesForActivity.length >= 5) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Solo puedes seleccionar hasta 5 notas por actividad',
                    ),
                  ),
                );
                return;
              }
              selectedNotesForActivity.add(note);
            } else {
              selectedNotesForActivity.remove(note);
            }
          },
        );
      },
    );
  }

  void pushNoteFormPage({required String userId, Note? existingNote}) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => NoteFormPage(
          structureId: widget.segmento.id,
          onCreateNote: (note) {
            if (existingNote != null) {
              NotesService(userId: userId)
                  .updateNoteById(existingNote.id!, note);
            } else {
              NotesService(userId: userId).createNote(note);
            }
            Navigator.of(context).pop();
          },
          note: existingNote,
        ),
      ),
    );
  }
}
