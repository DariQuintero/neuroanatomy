import 'package:flutter/material.dart';
import 'package:neuroanatomy/models/note.dart';

class NoteFormPage extends StatefulWidget {
  final Function(Note) onCreateNote;
  final String structureId;
  final Note? note;
  NoteFormPage(
      {super.key,
      required this.structureId,
      required this.onCreateNote,
      this.note});

  @override
  State<NoteFormPage> createState() => _NoteFormPageState();
}

class _NoteFormPageState extends State<NoteFormPage> {
  final titleController = TextEditingController();
  final contentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.note != null) {
      titleController.text = widget.note!.title;
      contentController.text = widget.note!.content;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.note == null ? 'Create Note' : 'Update Note'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                hintText: 'Title',
              ),
            ),
            const SizedBox(height: 8),
            // multiline text field
            Expanded(
              child: TextField(
                controller: contentController,
                maxLines: null,
                expands: true,
                keyboardType: TextInputType.multiline,
                decoration: const InputDecoration(
                  hintText: 'Content',
                ),
              ),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () {
                widget.onCreateNote(
                  Note(
                    title: titleController.text,
                    content: contentController.text,
                    structureId: widget.structureId,
                  ),
                );
              },
              child: Text(widget.note == null ? 'Create' : 'Update'),
            ),
          ],
        ),
      ),
    );
  }
}
