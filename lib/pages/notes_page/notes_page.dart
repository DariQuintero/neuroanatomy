import 'package:flutter/material.dart';
import 'package:neuroanatomy/cubits/auth_cubit/auth_cubit.dart';
import 'package:neuroanatomy/models/note.dart';
import 'package:neuroanatomy/pages/note_form_page/note_form_page.dart';
import 'package:neuroanatomy/services/notes_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class NotesPage extends StatefulWidget {
  final String structureId;
  const NotesPage({super.key, required this.structureId});

  @override
  State<NotesPage> createState() => _NotesPageState();
}

class _NotesPageState extends State<NotesPage> {
  @override
  Widget build(BuildContext context) {
    final userId = (context.read<AuthCubit>().state as AuthSuccess).user.uid;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notes Page'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          pushNoteFormPage(userId: userId);
        },
        child: const Icon(Icons.add),
      ),
      body: StreamBuilder<List<Note>>(
        stream: NotesService(userId: userId).getNotesStream(widget.structureId),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final notes = snapshot.data!;
                return ListTile(
                  title: Text(notes[index].title),
                  subtitle: Text(notes[index].content),
                  onTap: () {
                    pushNoteFormPage(
                      userId: userId,
                      existingNote: notes[index],
                    );
                  },
                  onLongPress: () {
                    NotesService(userId: userId).deleteNoteById(
                        notes[index].structureId, notes[index].id!);
                  },
                );
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

  void pushNoteFormPage({required String userId, Note? existingNote}) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => NoteFormPage(
          structureId: widget.structureId,
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
