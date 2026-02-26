// ignore_for_file: no_logic_in_create_state

import 'package:flutter/material.dart';
import '../../../core/models/data_models.dart';

class PreUResultRow extends StatefulWidget {
  final int index;
  final PreUResult result;
  final Function(int, PreUResult) onUpdate;
  final Function(int) onRemove;
  final List<String> gradeOptions;

  const PreUResultRow({
    super.key,
    required this.index,
    required this.result,
    required this.onUpdate,
    required this.onRemove,
    this.gradeOptions = const [],
  });

  @override
  State<PreUResultRow> createState() => _PreUResultRowState();
}

class _PreUResultRowState extends State<PreUResultRow> {
  late TextEditingController _subjectController;
  late TextEditingController _gradeController;
  late TextEditingController _scoreController;

  @override
  void initState() {
    super.initState();
    _subjectController = TextEditingController(text: widget.result.subject);
    _gradeController = TextEditingController(text: widget.result.grade);
    _scoreController = TextEditingController(
      text: widget.result.score > 0 ? widget.result.score.toString() : '',
    );
  }

  // We intentionally do NOT override didUpdateWidget to sync text back from parent
  // in this specific 'wizard' case because the parent source of truth IS us typing.
  // If we reset text on rebuild, we lose cursor position. 
  // Exception: If the parent data changed from a non-typing source (like an API load),
  // we would need a more complex sync. For now, ignoring didUpdateWidget prevents 
  // the cursor jump/focus loss loop completely.

  @override
  void didUpdateWidget(PreUResultRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.result.subject != _subjectController.text) {
      _subjectController.text = widget.result.subject;
      _subjectController.selection = TextSelection.fromPosition(
        TextPosition(offset: _subjectController.text.length),
      );
    }
    if (widget.result.grade != _gradeController.text) {
      _gradeController.text = widget.result.grade;
      _gradeController.selection = TextSelection.fromPosition(
        TextPosition(offset: _gradeController.text.length),
      );
    }
    final scoreStr =
        widget.result.score > 0 ? widget.result.score.toString() : '';
    if (scoreStr != _scoreController.text) {
      _scoreController.text = scoreStr;
      _scoreController.selection = TextSelection.fromPosition(
        TextPosition(offset: _scoreController.text.length),
      );
    }
  }

  @override
  void dispose() {
    _subjectController.dispose();
    _gradeController.dispose();
    _scoreController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            Expanded(
              flex: 3,
              child: TextFormField(
                controller: _subjectController,
                decoration: const InputDecoration(
                  labelText: 'Subject',
                  isDense: true,
                ),
                onChanged: (val) {
                  widget.onUpdate(
                    widget.index,
                    widget.result.copyWith(subject: val),
                  );
                },
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              flex: 2,
              child: widget.gradeOptions.isNotEmpty
                  ? DropdownButtonFormField<String>(
                      value: widget.gradeOptions.contains(_gradeController.text)
                          ? _gradeController.text
                          : null,
                      items: widget.gradeOptions
                          .map((g) => DropdownMenuItem(
                                value: g,
                                child: Text(g),
                              ))
                          .toList(),
                      decoration: const InputDecoration(
                        labelText: 'Grade',
                        isDense: true,
                      ),
                      onChanged: (val) {
                        if (val != null) {
                          _gradeController.text = val;
                          widget.onUpdate(
                            widget.index,
                            widget.result.copyWith(grade: val),
                          );
                        }
                      },
                    )
                  : TextFormField(
                      controller: _gradeController,
                      decoration: const InputDecoration(
                        labelText: 'Grade',
                        isDense: true,
                      ),
                      onChanged: (val) {
                        widget.onUpdate(
                          widget.index,
                          widget.result.copyWith(grade: val),
                        );
                      },
                    ),
            ),
            const SizedBox(width: 8),
            Expanded(
              flex: 2,
              child: TextFormField(
                controller: _scoreController,
                decoration: const InputDecoration(
                  labelText: 'Score (Opt)',
                  isDense: true,
                ),
                keyboardType: TextInputType.number,
                onChanged: (val) {
                  final s = double.tryParse(val);
                  if (s != null) {
                    widget.onUpdate(
                      widget.index,
                      widget.result.copyWith(score: s),
                    );
                  }
                },
              ),
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => widget.onRemove(widget.index),
            ),
          ],
        ),
      ),
    );
  }
}
