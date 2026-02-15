// lib/features/wizard/widgets/step_2_academic.dart
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart';

import '../../../core/models/data_models.dart';
import '../../../core/models/user_session_model.dart';
import '../../../core/services/gemini_service.dart';
import '../../../core/widgets/ui_kit.dart';
import 'pre_u_result_row.dart';

class Step2Academic extends StatefulWidget {
  const Step2Academic({super.key});

  @override
  State<Step2Academic> createState() => _Step2AcademicState();
}

class _Step2AcademicState extends State<Step2Academic> {
  final GeminiService _geminiService = GeminiService();
  final ImagePicker _picker = ImagePicker();
  bool _isScanning = false;

  final List<String> _grades = [
    'A+',
    'A',
    'A-',
    'B+',
    'B',
    'C+',
    'C',
    'D',
    'E',
    'G',
  ];

  final Map<String, List<String>> _qualificationGradeOptions = {
    'SPM Graduate': ['A+', 'A', 'A-', 'B+', 'B', 'C+', 'C', 'D', 'E', 'G'],
    'STPM': ['A', 'A-', 'B+', 'B', 'C+', 'C', 'C-', 'D+', 'D', 'F'],
    'Matriculation': ['A', 'A-', 'B+', 'B', 'C+', 'C', 'C-', 'D+', 'D', 'F'],
    'A-Level': ['A*', 'A', 'B', 'C', 'D', 'E', 'U'],
    'UEC': ['A1', 'A2', 'B3', 'B4', 'B5', 'B6', 'C7', 'C8', 'F9'],
    'IGCSE': ['A*', 'A', 'B', 'C', 'D', 'E', 'F', 'G', 'U'],
  };

  List<String> _gradesForQualification(String qualification) {
    return _qualificationGradeOptions[qualification] ?? _grades;
  }

  Future<void> _showImageSourceDialog(BuildContext context) async {
    showModalBottomSheet(
      context: context,
      builder: (ctx) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Photo Library'),
                onTap: () {
                  Navigator.of(ctx).pop();
                  _pickAndScanImage(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: const Text('Camera'),
                onTap: () {
                  Navigator.of(ctx).pop();
                  _pickAndScanImage(ImageSource.camera);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickAndScanImage(ImageSource source) async {
    final picked = await _picker.pickImage(source: source, maxWidth: 1600);
    if (picked == null) return;
    setState(() => _isScanning = true);
    try {
      final bytes = kIsWeb
          ? await picked.readAsBytes()
          : await File(picked.path).readAsBytes();
      await _scanImageWithGemini(base64Encode(bytes));
    } finally {
      if (mounted) setState(() => _isScanning = false);
    }
  }

  Future<void> _scanImageWithGemini(String base64Image) async {
    try {
      final response = await _geminiService.scanDocument(base64Image);
      final results = response['results'] ?? response['subjects'];
      final List dataList = (results is List && results.isNotEmpty)
          ? results
          : const [];

      if (dataList.isEmpty) {
        throw Exception(
          'No subjects detected. Please retry with a clearer image.',
        );
      }
      final model = Provider.of<UserSessionModel>(context, listen: false);
      final current = List<SPMSubject>.from(model.academic.spmResults);

      for (final r in dataList) {
        final name = r['subject'] as String? ?? r['name'] as String? ?? '';
        final grade = r['grade'] as String? ?? 'A';
        if (name.isEmpty) continue;

        final index = current.indexWhere(
          (s) => s.name.toLowerCase() == name.toLowerCase(),
        );
        if (index >= 0) {
          current[index] = current[index].copyWith(grade: grade);
        } else {
          current.add(SPMSubject(name: name, grade: grade, isElective: true));
        }
      }

      model.updateAcademic(model.academic.copyWith(spmResults: current));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Results scanned & merged successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Scan failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _ensureFixedSubjects(AcademicData data, UserSessionModel model) {
    if (!data.hasSpm || data.spmResults.isNotEmpty) return;
    final fixed = [
      SPMSubject(name: 'Bahasa Melayu', grade: 'A'),
      SPMSubject(name: 'Bahasa Inggeris', grade: 'A'),
      SPMSubject(name: 'Sejarah', grade: 'A'),
      SPMSubject(name: 'Mathematics', grade: 'A'),
      SPMSubject(name: 'Pendidikan Islam / Moral', grade: 'A'),
    ];
    WidgetsBinding.instance.addPostFrameCallback((_) {
      model.updateAcademic(data.copyWith(spmResults: fixed));
    });
  }

  void _updateSubject(int index, SPMSubject subject, UserSessionModel model) {
    final list = List<SPMSubject>.from(model.academic.spmResults);
    list[index] = subject;
    model.updateAcademic(model.academic.copyWith(spmResults: list));
  }

  void _addElective(UserSessionModel model) {
    final list = List<SPMSubject>.from(model.academic.spmResults);
    list.add(SPMSubject(name: '', grade: 'A', isElective: true));
    model.updateAcademic(model.academic.copyWith(spmResults: list));
  }

  void _removeElective(int index, UserSessionModel model) {
    final list = List<SPMSubject>.from(model.academic.spmResults);
    if (index < 0 || index >= list.length) return;
    list.removeAt(index);
    model.updateAcademic(model.academic.copyWith(spmResults: list));
  }

  void _addPreUResult(UserSessionModel model) {
    final list = List<PreUResult>.from(model.academic.preUResults);
    list.add(PreUResult(subject: '', grade: '', score: 0.0));
    model.updateAcademic(model.academic.copyWith(preUResults: list));
  }

  void _removePreUResult(int index, UserSessionModel model) {
    final list = List<PreUResult>.from(model.academic.preUResults);
    if (index < 0 || index >= list.length) return;
    list.removeAt(index);
    model.updateAcademic(model.academic.copyWith(preUResults: list));
  }

  void _updatePreUResult(
    int index,
    PreUResult newResult,
    UserSessionModel model,
  ) {
    final list = List<PreUResult>.from(model.academic.preUResults);
    if (index < 0 || index >= list.length) return;
    list[index] = newResult;
    model.updateAcademic(model.academic.copyWith(preUResults: list));
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserSessionModel>(
      builder: (context, model, _) {
        final profile = model.profile;
        final academic = model.academic;
        final qualification = profile.academicStatus;
        final isSpmOnly = qualification == 'SPM Graduate';
        final isSubjectBased = [
          'STPM',
          'Matriculation',
          'A-Level',
          'UEC',
          'IGCSE',
        ].contains(qualification);
        final isInstitutionBased = [
          'Foundation',
          'Asasi',
          'Diploma',
        ].contains(qualification);

        // sync qualificationType
        if (academic.qualificationType != qualification) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            model.updateAcademic(
              academic.copyWith(qualificationType: qualification),
            );
          });
        }

        _ensureFixedSubjects(academic, model);

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Academic Excellence',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),

              if (profile.academicStatus.isEmpty)
                const Card(
                  color: Colors.amberAccent,
                  child: Padding(
                    padding: EdgeInsets.all(8),
                    child: Text('Please select Academic Status in Step 1'),
                  ),
                ),

              // Scan button
              Center(
                child: Container(
                  width: double.infinity,
                  height: 100,
                  margin: const EdgeInsets.only(bottom: 24),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withOpacity(0.05),
                    border: Border.all(
                      color: Theme.of(context).primaryColor.withOpacity(0.5),
                    ),
                    borderRadius: BorderRadius.circular(12),
                    image: const DecorationImage(
                      image: NetworkImage(
                        'https://www.gstatic.com/images/icons/material/system/2x/document_scanner_black_48dp.png',
                      ),
                      opacity: 0.1,
                    ),
                  ),
                  child: InkWell(
                    onTap: _isScanning
                        ? null
                        : () => _showImageSourceDialog(context),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        if (_isScanning) ...[
                          const CircularProgressIndicator(),
                          const SizedBox(height: 8),
                          const Text('Analyzing document with Gemini AI...'),
                        ] else
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                    Icons.document_scanner,
                                    size: 40,
                                    color: Colors.blue,
                                  )
                                  .animate(
                                    onPlay: (c) => c.repeat(reverse: true),
                                  )
                                  .shimmer(
                                    duration: 1200.ms,
                                    color: Colors.white,
                                  )
                                  .scaleXY(end: 1.1, duration: 600.ms),
                              const SizedBox(height: 8),
                              const Text(
                                'Scan Result Slip',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue,
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                ),
              ),

              if (!isSpmOnly) ...[
                SwitchListTile(
                  title: const Text('Do you hold an SPM Certificate?'),
                  subtitle: const Text(
                    'Toggle on if you want to include SPM results',
                  ),
                  value: academic.hasSpm,
                  onChanged: (value) =>
                      model.updateAcademicFields(hasSpm: value),
                  secondary: const Icon(Icons.school, color: Colors.blue),
                ),
                const Divider(),
              ] else ...[
                const SizedBox(height: 8),
                const Text(
                  'SPM results required',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
              ],

              if (isSpmOnly || academic.hasSpm) ...[
                const Text(
                  'SPM Results',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: academic.spmResults.length,
                  itemBuilder: (context, index) {
                    final subject = academic.spmResults[index];
                    return Card(
                      color: Colors.white,
                      elevation: 1,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: const BorderSide(
                          color: Color(0xFFB3D4FF),
                          width: 0.8,
                        ),
                      ),
                      margin: const EdgeInsets.only(bottom: 12),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TextFormField(
                              initialValue: subject.name,
                              readOnly: !subject.isElective,
                              decoration: InputDecoration(
                                labelText: 'Subject ${index + 1}',
                                helperText: subject.isElective
                                    ? 'Elective'
                                    : 'Core subject',
                              ),
                              onChanged: (val) => _updateSubject(
                                index,
                                subject.copyWith(name: val),
                                model,
                              ),
                            ),
                            const SizedBox(height: 8),
                            DropdownButtonFormField<String>(
                              value: subject.grade,
                              decoration: const InputDecoration(
                                labelText: 'Grade',
                              ),
                              items: _gradesForQualification('SPM Graduate')
                                  .map(
                                    (g) => DropdownMenuItem(
                                      value: g,
                                      child: Text(g),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (val) => _updateSubject(
                                index,
                                subject.copyWith(grade: val ?? subject.grade),
                                model,
                              ),
                            ),
                            if (subject.isElective)
                              Align(
                                alignment: Alignment.centerRight,
                                child: TextButton.icon(
                                  onPressed: () =>
                                      _removeElective(index, model),
                                  icon: const Icon(Icons.delete_outline),
                                  label: const Text('Remove Elective'),
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton.icon(
                    onPressed: () => _addElective(model),
                    icon: const Icon(Icons.add),
                    label: const Text('Add Elective Subject'),
                  ),
                ),
              ],

              if (!isSpmOnly) ...[
                const SizedBox(height: 24),
                const Divider(),
                const SizedBox(height: 16),
                Text(
                  '$qualification Information',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),

                if (isSubjectBased) ...[
                  const Text(
                    'Subject Results',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: academic.preUResults.length,
                    itemBuilder: (context, index) {
                      final result = academic.preUResults[index];
                      return PreUResultRow(
                        key: ValueKey(index),
                        index: index,
                        result: result,
                        gradeOptions: _gradesForQualification(qualification),
                        onUpdate: (idx, newResult) =>
                            _updatePreUResult(idx, newResult, model),
                        onRemove: (idx) => _removePreUResult(idx, model),
                      );
                    },
                  ),
                  TextButton.icon(
                    onPressed: () => _addPreUResult(model),
                    icon: const Icon(Icons.add),
                    label: const Text('Add Subject'),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    initialValue: academic.cgpa > 0
                        ? academic.cgpa.toString()
                        : '',
                    decoration: const InputDecoration(
                      labelText: 'CGPA / Average Score',
                      border: OutlineInputBorder(),
                      hintText: 'e.g. 3.50',
                      prefixIcon: Icon(Icons.grade),
                    ),
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    onChanged: (val) {
                      final d = double.tryParse(val);
                      if (d != null) model.updateAcademicFields(cgpa: d);
                    },
                  ),
                ],

                if (isInstitutionBased) ...[
                  TextFormField(
                    initialValue: academic.institutionName,
                    decoration: const InputDecoration(
                      labelText: 'Institution Name',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.school),
                    ),
                    onChanged: (val) {
                      model.updateAcademic(
                        academic.copyWith(institutionName: val),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    initialValue: academic.cgpa > 0
                        ? academic.cgpa.toString()
                        : '',
                    decoration: const InputDecoration(
                      labelText: 'CGPA',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.grade),
                    ),
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    onChanged: (val) {
                      final d = double.tryParse(val);
                      if (d != null) model.updateAcademicFields(cgpa: d);
                    },
                  ),
                ],

                const SizedBox(height: 24),
                const Text(
                  'English Proficiency',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: [
                    for (final option in [
                      'MUET',
                      'IELTS',
                      'TOEFL iBT',
                      "None / Haven't taken",
                    ])
                      ChoiceChip(
                        label: Text(option),
                        selected: academic.englishTest == option,
                        onSelected: (_) {
                          model.updateAcademic(
                            academic.copyWith(
                              englishTest: option,
                              englishScore: '',
                            ),
                          );
                        },
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                if (academic.englishTest == 'MUET')
                  ModernDropdown<String>(
                    label: 'MUET Band',
                    value:
                        [
                          '1.0',
                          '1.5',
                          '2.0',
                          '2.5',
                          '3.0',
                          '3.5',
                          '4.0',
                          '4.5',
                          '5.0',
                          '5.0+',
                        ].contains(academic.englishScore)
                        ? academic.englishScore
                        : null,
                    items:
                        [
                              '1.0',
                              '1.5',
                              '2.0',
                              '2.5',
                              '3.0',
                              '3.5',
                              '4.0',
                              '4.5',
                              '5.0',
                              '5.0+',
                            ]
                            .map(
                              (b) => DropdownMenuItem(value: b, child: Text(b)),
                            )
                            .toList(),
                    onChanged: (val) {
                      if (val != null) {
                        model.updateAcademic(
                          academic.copyWith(englishScore: val),
                        );
                      }
                    },
                  )
                else if (academic.englishTest == 'IELTS')
                  ModernDropdown<String>(
                    label: 'IELTS Band',
                    value: academic.englishScore.isNotEmpty
                        ? academic.englishScore
                        : null,
                    items:
                        [
                              '4.0',
                              '4.5',
                              '5.0',
                              '5.5',
                              '6.0',
                              '6.5',
                              '7.0',
                              '7.5',
                              '8.0',
                              '8.5',
                              '9.0',
                            ]
                            .map(
                              (b) => DropdownMenuItem(value: b, child: Text(b)),
                            )
                            .toList(),
                    onChanged: (val) {
                      if (val != null) {
                        model.updateAcademic(
                          academic.copyWith(englishScore: val),
                        );
                      }
                    },
                  )
                else if (academic.englishTest == 'TOEFL iBT')
                  TextFormField(
                    initialValue: academic.englishScore,
                    decoration: const InputDecoration(
                      labelText: 'TOEFL iBT Score (Max 120)',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (val) {
                      model.updateAcademic(
                        academic.copyWith(englishScore: val),
                      );
                    },
                  )
                else if (academic.englishTest == "None / Haven't taken")
                  const Text(
                    'Note: You can still apply, but some courses may require a minimum English grade.',
                    style: TextStyle(color: Colors.orange),
                  ),
                const SizedBox(height: 24),

                if (isSubjectBased || isInstitutionBased) ...[
                  Text(
                    'Cocurriculum Marks (0 - 10)',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  Slider(
                    value: model.preferences.cocurriculumScore,
                    min: 0.0,
                    max: 10.0,
                    divisions: 100,
                    label: model.preferences.cocurriculumScore.toStringAsFixed(
                      1,
                    ),
                    onChanged: (value) {
                      model.updatePreferences(
                        model.preferences.copyWith(cocurriculumScore: value),
                      );
                    },
                  ),
                ],
              ],
            ],
          ),
        );
      },
    );
  }
}
