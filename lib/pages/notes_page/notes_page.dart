import 'package:flutter/material.dart';
import 'package:neuroanatomy/cubits/auth_cubit/auth_cubit.dart';
import 'package:neuroanatomy/models/note.dart';
import 'package:neuroanatomy/models/segmento_cerebro.dart';
import 'package:neuroanatomy/pages/note_form_page/note_form_page.dart';
import 'package:neuroanatomy/services/chat_gpt_service.dart';
import 'package:neuroanatomy/services/notes_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class NotesPage extends StatefulWidget {
  final SegmentoCerebro estructura;
  const NotesPage({super.key, required this.estructura});

  @override
  State<NotesPage> createState() => _NotesPageState();
}

class _NotesPageState extends State<NotesPage> {
  List<Note> currentNotes = [];

  @override
  Widget build(BuildContext context) {
    final userId = (context.read<AuthCubit>().state as AuthSuccess).user.uid;
    return Scaffold(
      appBar: AppBar(
        title: Text('Notas ${widget.estructura.nombre}'),
        actions: [
          IconButton(
            onPressed: () async {
              // show snackbar and hide it after future completes
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Generating Quiz...'),
                ),
              );
              final response = await ChatGPTService().generateQuizFromText(
                currentNotes.map((e) => e.content).join('\n'),
              );
              if (!mounted) return;
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
              NotesService(userId: userId).createNote(
                Note(
                  content: response,
                  title:
                      'Quiz generado: ${DateTime.now().toString().split(' ')[0]}',
                  structureId: widget.estructura.id,
                ),
              );
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Generated Quiz'),
                  content: Text(response),
                ),
              );
            },
            icon: const Icon(Icons.chat),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          pushNoteFormPage(userId: userId);
        },
        child: const Icon(Icons.add),
      ),
      body: StreamBuilder<List<Note>>(
        stream:
            NotesService(userId: userId).getNotesStream(widget.estructura.id),
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
                return ListTile(
                  title: Text(notes[index].title),
                  subtitle: Text(notes[index].content.length > 50
                      ? '${notes[index].content.substring(0, 50)}...'
                      : notes[index].content),
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
          structureId: widget.estructura.id,
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
