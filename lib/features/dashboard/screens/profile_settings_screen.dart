// lib/features/dashboard/screens/profile_settings_screen.dart
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart';
import '../../../core/models/user_session_model.dart';
import '../../../core/models/data_models.dart';
import '../../../core/services/gemini_service.dart';
import '../../../core/widgets/ui_kit.dart';

class ProfileSettingsScreen extends StatefulWidget {
  const ProfileSettingsScreen({super.key});

  @override
  State<ProfileSettingsScreen> createState() => _ProfileSettingsScreenState();
}

class _ProfileSettingsScreenState extends State<ProfileSettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _icController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _stateController;
  late TextEditingController _ethnicityController;
  late TextEditingController _subgroupController;
  late TextEditingController _incomeController;
  late TextEditingController _englishScoreController;
  late TextEditingController _cgpaController;
  late TextEditingController _institutionController;

  String _englishTest = '';
  List<String> _leadership = [];
  List<String> _achievements = [];
  List<CompetitionEntry> _competitions = [];
  List<String> _interests = [];
  List<SPMSubject> _spmResults = [];
  List<PreUResult> _preUResults = [];
  double _pajsk = 0.0;
  double _cocurriculum = 0.0;
  bool _hasSpm = false;
  String _qualification = '';
  bool _isFirstGen = false;
  bool _isOku = false;
  List<String> _specialConsiderations = [];

  final GeminiService _geminiService = GeminiService();
  final ImagePicker _picker = ImagePicker();
  bool _isScanning = false;

  // Options
  final List<String> _ethnicityOptions = ['Bumiputera', 'Non-Bumiputera'];

  final List<String> _statusOptions = [
    'SPM Graduate',
    'STPM',
    'Matriculation',
    'Diploma',
    'UEC',
    'IGCSE',
    'A-Level',
    'Foundation',
    'Asasi',
  ];

  final List<String> _stateOptions = [
    'Johor',
    'Kedah',
    'Kelantan',
    'Melaka',
    'Negeri Sembilan',
    'Pahang',
    'Penang',
    'Perak',
    'Perlis',
    'Sabah',
    'Sarawak',
    'Selangor',
    'Terengganu',
    'Kuala Lumpur',
    'Labuan',
    'Putrajaya',
  ];

  final Map<String, List<String>> _ethnicitySubgroupOptions = {
    'Bumiputera': [
      'Melayu',
      'Bumiputera Sabah',
      'Bumiputera Sarawak',
      'Orang Asli',
    ],
    'Non-Bumiputera': ['Chinese', 'Indian', 'Others'],
  };

  final Map<String, List<String>> _interestGroups = {
    'STEM & Tech': [
      'Computer Science',
      'Artificial Intelligence & Data Science',
      'Software Engineering',
      'Civil / Mechanical / Electrical Engineering',
      'Biotechnology & Life Sciences',
    ],
    'Medical & Health': [
      'Medicine & Surgery',
      'Pharmacy',
      'Dentistry',
      'Nursing & Physiotherapy',
      'Biomedical Science',
    ],
    'Business & Economics': [
      'Accounting & Finance',
      'Business Management',
      'Marketing & Digital Commerce',
      'Economics',
      'Logistics & Supply Chain',
    ],
    'Arts & Creative': [
      'Graphic & Multimedia Design',
      'Architecture & Interior Design',
      'Animation & Game Development',
      'Fashion Design',
      'Film & Broadcasting',
    ],
    'Social Sciences & Law': [
      'Law',
      'Psychology',
      'Mass Communication',
      'International Relations',
      'Early Childhood Education',
    ],
    'Hospitality & TVET': [
      'Culinary Arts',
      'Hotel & Tourism Management',
      'Event Management',
      'Automotive Technology',
    ],
    'Built Environment': [
      'Quantity Surveying',
      'Urban Planning',
      'Real Estate Management',
    ],
  };

  final List<String> _specialOptions = [
    'Athlete',
    'Single Parent Household',
    'Children of Police/Army',
    'Orphan / Piatu',
    'Chronic Illness',
    'Large Family (>5 siblings)',
    'Refugee Status',
  ];

  final List<String> _englishTests = [
    'MUET',
    'IELTS',
    'TOEFL iBT',
    "None / Haven't taken",
  ];

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

  List<SPMSubject> _defaultSpmSubjects() {
    return [
      SPMSubject(name: 'Bahasa Melayu', grade: 'A'),
      SPMSubject(name: 'Bahasa Inggeris', grade: 'A'),
      SPMSubject(name: 'Sejarah', grade: 'A'),
      SPMSubject(name: 'Mathematics', grade: 'A'),
      SPMSubject(name: 'Pendidikan Islam / Moral', grade: 'A'),
    ];
  }

  @override
  void initState() {
    super.initState();
    final model = Provider.of<UserSessionModel>(context, listen: false);
    _qualification = model.academic.qualificationType.isNotEmpty
        ? model.academic.qualificationType
        : model.profile.academicStatus;
    _hasSpm = model.academic.hasSpm || _qualification == 'SPM Graduate';
    _nameController = TextEditingController(text: model.fullName);
    _icController = TextEditingController(text: model.profile.identityNumber);
    _emailController = TextEditingController(text: model.profile.email);
    _phoneController = TextEditingController(text: model.profile.phone);
    _stateController = TextEditingController(text: model.state);
    _ethnicityController = TextEditingController(text: model.ethnicity);
    _subgroupController = TextEditingController(
      text: model.profile.ethnicitySubgroup,
    );
    _incomeController = TextEditingController(
      text: model.householdIncome.toStringAsFixed(2),
    );
    _englishScoreController = TextEditingController(
      text: model.academic.englishScore,
    );
    _cgpaController = TextEditingController(
      text: model.academic.cgpa > 0 ? model.academic.cgpa.toString() : '',
    );
    _institutionController = TextEditingController(
      text: model.academic.institutionName,
    );

    _englishTest = model.academic.englishTest.isNotEmpty
        ? model.academic.englishTest
        : "None / Haven't taken";
    _leadership = List<String>.from(model.preferences.leadership);
    _achievements = List<String>.from(model.preferences.achievements);
    _competitions = List<CompetitionEntry>.from(model.preferences.competitions);
    _interests = List<String>.from(model.preferences.interests);
    _pajsk = model.preferences.pajskScore;
    _cocurriculum = model.preferences.cocurriculumScore;
    _isFirstGen = model.profile.isFirstGen;
    _isOku = model.profile.isOku;
    _specialConsiderations = List<String>.from(
      model.profile.specialConsiderations,
    );
    _spmResults = List<SPMSubject>.from(model.academic.spmResults);
    _preUResults = List<PreUResult>.from(model.academic.preUResults);
    if ((_hasSpm || _qualification == 'SPM Graduate') && _spmResults.isEmpty) {
      _spmResults = _defaultSpmSubjects();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _icController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _stateController.dispose();
    _ethnicityController.dispose();
    _subgroupController.dispose();
    _incomeController.dispose();
    _englishScoreController.dispose();
    _cgpaController.dispose();
    _institutionController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      final model = Provider.of<UserSessionModel>(context, listen: false);

      // Update Profile
      model.updateProfile(
        model.profile.copyWith(
          name: _nameController.text,
          identityNumber: _icController.text,
          email: _emailController.text,
          phone: _phoneController.text,
          state: _stateController.text,
          ethnicity: _ethnicityController.text,
          ethnicitySubgroup: _subgroupController.text,
          academicStatus: _qualification,
          isFirstGen: _isFirstGen,
          isOku: _isOku,
          specialConsiderations: _specialConsiderations,
        ),
      );

      // Update Financial
      model.updateFinancial(
        income: double.tryParse(_incomeController.text) ?? 0.0,
      );

      // Update Academic (Partial)
      model.updateAcademic(
        model.academic.copyWith(
          englishTest: _englishTest,
          englishScore: _englishScoreController.text,
          hasSpm: _hasSpm,
          qualificationType: _qualification,
          spmResults: _spmResults,
          preUResults: _preUResults,
          cgpa: double.tryParse(_cgpaController.text) ?? model.academic.cgpa,
          institutionName: _institutionController.text,
          coCurriculumScore: _cocurriculum,
        ),
      );

      model.updatePreferences(
        model.preferences.copyWith(
          leadership: _leadership,
          achievements: _achievements,
          competitions: _competitions,
          interests: _interests,
          pajskScore: _pajsk,
          cocurriculumScore: _cocurriculum,
        ),
      );

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Saving changes...")));

      try {
        await model.saveUserProfileToFirebase();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Profile updated successfully!"),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Error updating profile: $e"),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  void _updateSpmSubject(int index, SPMSubject subject) {
    final list = List<SPMSubject>.from(_spmResults);
    if (index < 0 || index >= list.length) return;
    list[index] = subject;
    setState(() => _spmResults = list);
  }

  void _addElective() {
    setState(() {
      _spmResults = [
        ..._spmResults,
        SPMSubject(name: '', grade: 'A', isElective: true),
      ];
    });
  }

  void _removeElective(int index) {
    final list = List<SPMSubject>.from(_spmResults);
    if (index < 0 || index >= list.length) return;
    list.removeAt(index);
    setState(() => _spmResults = list);
  }

  void _addPreUResult() {
    setState(() {
      _preUResults = [
        ..._preUResults,
        PreUResult(subject: '', grade: '', score: 0.0),
      ];
    });
  }

  void _removePreUResult(int index) {
    final list = List<PreUResult>.from(_preUResults);
    if (index < 0 || index >= list.length) return;
    list.removeAt(index);
    setState(() => _preUResults = list);
  }

  void _updatePreUResult(int index, PreUResult newResult) {
    final list = List<PreUResult>.from(_preUResults);
    if (index < 0 || index >= list.length) return;
    list[index] = newResult;
    setState(() => _preUResults = list);
  }

  Future<void> _pickAndScanImage() async {
    final picked = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1600,
    );
    if (picked == null) return;
    setState(() => _isScanning = true);
    try {
      final bytes = kIsWeb
          ? await picked.readAsBytes()
          : await picked.readAsBytes();
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

      final current = List<SPMSubject>.from(_spmResults);
      for (final r in dataList) {
        final name = r['subject'] as String? ?? r['name'] as String? ?? '';
        final grade = r['grade'] as String? ?? 'A';
        if (name.isEmpty) continue;
        final idx = current.indexWhere(
          (s) => s.name.toLowerCase() == name.toLowerCase(),
        );
        if (idx >= 0) {
          current[idx] = current[idx].copyWith(grade: grade);
        } else {
          current.add(SPMSubject(name: name, grade: grade, isElective: true));
        }
      }
      setState(() {
        _spmResults = current;
        _hasSpm = true;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Scan successful — subjects added/updated.'),
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

  @override
  Widget build(BuildContext context) {
    final isSpmOnly = _qualification == 'SPM Graduate';
    final isSubjectBased = [
      'STPM',
      'Matriculation',
      'A-Level',
      'UEC',
      'IGCSE',
    ].contains(_qualification);
    final isInstitutionBased = [
      'Foundation',
      'Asasi',
      'Diploma',
    ].contains(_qualification);

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFF3F8FF), Color(0xFFE9F6F2)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              const Text(
                "Profile Settings",
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 12),
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 20,
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        Theme(
                          data: Theme.of(context).copyWith(
                            inputDecorationTheme: const InputDecorationTheme(
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(10),
                                ),
                                borderSide: BorderSide(
                                  color: Color(0xFFB3D4FF),
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(10),
                                ),
                                borderSide: BorderSide(
                                  color: Color(0xFFB3D4FF),
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(10),
                                ),
                                borderSide: BorderSide(
                                  color: Color(0xFF4A90E2),
                                  width: 1.2,
                                ),
                              ),
                            ),
                          ),
                          child: Column(
                            children: [
                              _buildSectionTitle("Personal Identity"),
                              TextFormField(
                                controller: _nameController,
                                decoration: const InputDecoration(
                                  labelText: "Full Name",
                                ),
                                validator: (v) =>
                                    v!.isEmpty ? "Required" : null,
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                controller: _icController,
                                decoration: const InputDecoration(
                                  labelText: "IC Number",
                                ),
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                controller: _emailController,
                                decoration: const InputDecoration(
                                  labelText: "Email",
                                ),
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                controller: _phoneController,
                                decoration: const InputDecoration(
                                  labelText: "Phone",
                                ),
                              ),
                              const SizedBox(height: 16),
                              DropdownButtonFormField<String>(
                                value:
                                    _stateOptions.contains(
                                      _stateController.text,
                                    )
                                    ? _stateController.text
                                    : null,
                                decoration: const InputDecoration(
                                  labelText: "State",
                                ),
                                items: _stateOptions
                                    .map(
                                      (s) => DropdownMenuItem(
                                        value: s,
                                        child: Text(s),
                                      ),
                                    )
                                    .toList(),
                                onChanged: (val) => setState(() {
                                  _stateController.text = val ?? '';
                                }),
                              ),
                              const SizedBox(height: 16),
                              DropdownButtonFormField<String>(
                                value:
                                    _ethnicityOptions.contains(
                                      _ethnicityController.text,
                                    )
                                    ? _ethnicityController.text
                                    : null,
                                decoration: const InputDecoration(
                                  labelText: "Ethnicity",
                                ),
                                items: _ethnicityOptions.map((e) {
                                  return DropdownMenuItem(
                                    value: e,
                                    child: Text(e),
                                  );
                                }).toList(),
                                onChanged: (val) => setState(() {
                                  _ethnicityController.text = val ?? '';
                                  _subgroupController.text = '';
                                }),
                              ),
                              const SizedBox(height: 16),
                              if (_ethnicitySubgroupOptions.containsKey(
                                _ethnicityController.text,
                              )) ...[
                                const SizedBox(height: 16),
                                DropdownButtonFormField<String>(
                                  value:
                                      _ethnicitySubgroupOptions[_ethnicityController
                                              .text]!
                                          .contains(_subgroupController.text)
                                      ? _subgroupController.text
                                      : null,
                                  decoration: const InputDecoration(
                                    labelText: "Ethnicity Subgroup",
                                  ),
                                  items:
                                      _ethnicitySubgroupOptions[_ethnicityController
                                              .text]!
                                          .map(
                                            (e) => DropdownMenuItem(
                                              value: e,
                                              child: Text(e),
                                            ),
                                          )
                                          .toList(),
                                  onChanged: (val) => setState(
                                    () => _subgroupController.text = val ?? '',
                                  ),
                                ),
                              ],

                              SwitchListTile(
                                value: _isFirstGen,
                                title: const Text("First-Generation Student"),
                                onChanged: (val) =>
                                    setState(() => _isFirstGen = val),
                              ),
                              SwitchListTile(
                                value: _isOku,
                                title: const Text(
                                  "Person with Disability (OKU)",
                                ),
                                onChanged: (val) =>
                                    setState(() => _isOku = val),
                              ),
                              const SizedBox(height: 8),
                              Align(
                                alignment: Alignment.centerLeft,
                                child: Wrap(
                                  spacing: 8,
                                  runSpacing: 4,
                                  children: _specialOptions
                                      .map(
                                        (e) => FilterChip(
                                          label: Text(e),
                                          selected: _specialConsiderations
                                              .contains(e),
                                          onSelected: (selected) {
                                            setState(() {
                                              if (selected) {
                                                _specialConsiderations.add(e);
                                              } else {
                                                _specialConsiderations.remove(
                                                  e,
                                                );
                                              }
                                            });
                                          },
                                        ),
                                      )
                                      .toList(),
                                ),
                              ),
                              const SizedBox(height: 32),
                              _buildSectionTitle("Academic Info"),
                              DropdownButtonFormField<String>(
                                value: _statusOptions.contains(_qualification)
                                    ? _qualification
                                    : null,
                                decoration: const InputDecoration(
                                  labelText: "Academic Status",
                                ),
                                items: _statusOptions
                                    .map(
                                      (s) => DropdownMenuItem(
                                        value: s,
                                        child: Text(s),
                                      ),
                                    )
                                    .toList(),
                                onChanged: (val) {
                                  if (val != null) {
                                    setState(() {
                                      _qualification = val;
                                      if (val == 'SPM Graduate') {
                                        _hasSpm = true;
                                        if (_spmResults.isEmpty) {
                                          _spmResults = _defaultSpmSubjects();
                                        }
                                      } else {
                                        _hasSpm = _hasSpm;
                                      }
                                    });
                                  }
                                },
                              ),
                              SwitchListTile(
                                contentPadding: EdgeInsets.zero,
                                value: _hasSpm,
                                title: const Text("Completed SPM"),
                                onChanged: (val) =>
                                    setState(() => _hasSpm = val),
                              ),
                              if (isSpmOnly || _hasSpm) ...[
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: Wrap(
                                    spacing: 8,
                                    crossAxisAlignment:
                                        WrapCrossAlignment.center,
                                    children: [
                                      ElevatedButton.icon(
                                        onPressed: _isScanning
                                            ? null
                                            : _pickAndScanImage,
                                        icon: _isScanning
                                            ? const SizedBox(
                                                width: 16,
                                                height: 16,
                                                child:
                                                    CircularProgressIndicator(
                                                      strokeWidth: 2,
                                                    ),
                                              )
                                            : const Icon(
                                                Icons.document_scanner_outlined,
                                              ),
                                        label: Text(
                                          _isScanning
                                              ? 'Scanning...'
                                              : 'Scan Result Slip',
                                        ),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.blueAccent,
                                          foregroundColor: Colors.white,
                                        ),
                                      ),
                                      const Text(
                                        'Scanned subjects fill electives automatically',
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 12),
                                ListView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: _spmResults.length,
                                  itemBuilder: (context, index) {
                                    final subject = _spmResults[index];
                                    return Card(
                                      color: Colors.white,
                                      margin: const EdgeInsets.only(bottom: 12),
                                      elevation: 1,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        side: const BorderSide(
                                          color: Color(0xFFB3D4FF),
                                          width: 0.8,
                                        ),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(12.0),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            TextFormField(
                                              initialValue: subject.name,
                                              readOnly: !subject.isElective,
                                              decoration: InputDecoration(
                                                labelText:
                                                    'Subject ${index + 1}',
                                                helperText: subject.isElective
                                                    ? 'Elective'
                                                    : 'Core subject',
                                              ),
                                              onChanged: (val) =>
                                                  _updateSpmSubject(
                                                    index,
                                                    subject.copyWith(name: val),
                                                  ),
                                            ),
                                            const SizedBox(height: 8),
                                            DropdownButtonFormField<String>(
                                              value: subject.grade,
                                              decoration: const InputDecoration(
                                                labelText: 'Grade',
                                              ),
                                              items:
                                                  _gradesForQualification(
                                                        'SPM Graduate',
                                                      )
                                                      .map(
                                                        (g) => DropdownMenuItem(
                                                          value: g,
                                                          child: Text(g),
                                                        ),
                                                      )
                                                      .toList(),
                                              onChanged: (val) =>
                                                  _updateSpmSubject(
                                                    index,
                                                    subject.copyWith(
                                                      grade:
                                                          val ?? subject.grade,
                                                    ),
                                                  ),
                                            ),
                                            if (subject.isElective)
                                              Align(
                                                alignment:
                                                    Alignment.centerRight,
                                                child: TextButton.icon(
                                                  onPressed: () =>
                                                      _removeElective(index),
                                                  icon: const Icon(
                                                    Icons.delete_outline,
                                                  ),
                                                  label: const Text(
                                                    'Remove Elective',
                                                  ),
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
                                    onPressed: _addElective,
                                    icon: const Icon(Icons.add),
                                    label: const Text('Add Elective Subject'),
                                  ),
                                ),
                                const SizedBox(height: 12),
                              ],

                              if (isSubjectBased) ...[
                                const SizedBox(height: 8),
                                const Divider(),
                                const SizedBox(height: 12),
                                const Text(
                                  'Subject Results',
                                  style: TextStyle(fontWeight: FontWeight.w700),
                                ),
                                const SizedBox(height: 8),
                                ListView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: _preUResults.length,
                                  itemBuilder: (context, index) {
                                    final result = _preUResults[index];
                                    return Card(
                                      color: Colors.white,
                                      margin: const EdgeInsets.only(bottom: 12),
                                      elevation: 1,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        side: const BorderSide(
                                          color: Color(0xFFB3E0DB),
                                          width: 0.8,
                                        ),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(12.0),
                                        child: Column(
                                          children: [
                                            TextFormField(
                                              initialValue: result.subject,
                                              decoration: InputDecoration(
                                                labelText:
                                                    'Subject ${index + 1}',
                                              ),
                                              onChanged: (val) =>
                                                  _updatePreUResult(
                                                    index,
                                                    result.copyWith(
                                                      subject: val,
                                                    ),
                                                  ),
                                            ),
                                            const SizedBox(height: 8),
                                            DropdownButtonFormField<String>(
                                              value: result.grade.isNotEmpty
                                                  ? result.grade
                                                  : null,
                                              decoration: const InputDecoration(
                                                labelText: 'Grade',
                                              ),
                                              items:
                                                  _gradesForQualification(
                                                        _qualification,
                                                      )
                                                      .map(
                                                        (g) => DropdownMenuItem(
                                                          value: g,
                                                          child: Text(g),
                                                        ),
                                                      )
                                                      .toList(),
                                              onChanged: (val) =>
                                                  _updatePreUResult(
                                                    index,
                                                    result.copyWith(
                                                      grade:
                                                          val ?? result.grade,
                                                    ),
                                                  ),
                                            ),
                                            const SizedBox(height: 8),
                                            TextFormField(
                                              initialValue: result.score > 0
                                                  ? result.score.toString()
                                                  : '',
                                              decoration: const InputDecoration(
                                                labelText:
                                                    'Score / Points (optional)',
                                              ),
                                              keyboardType:
                                                  const TextInputType.numberWithOptions(
                                                    decimal: true,
                                                  ),
                                              onChanged: (val) {
                                                final score =
                                                    double.tryParse(val) ?? 0.0;
                                                _updatePreUResult(
                                                  index,
                                                  result.copyWith(score: score),
                                                );
                                              },
                                            ),
                                            Align(
                                              alignment: Alignment.centerRight,
                                              child: TextButton.icon(
                                                onPressed: () =>
                                                    _removePreUResult(index),
                                                icon: const Icon(
                                                  Icons.delete_outline,
                                                ),
                                                label: const Text('Remove'),
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
                                    onPressed: _addPreUResult,
                                    icon: const Icon(Icons.add),
                                    label: const Text('Add Subject'),
                                  ),
                                ),
                              ],

                              if (isInstitutionBased) ...[
                                const SizedBox(height: 12),
                                const Divider(),
                                const SizedBox(height: 12),
                                TextFormField(
                                  controller: _institutionController,
                                  decoration: const InputDecoration(
                                    labelText:
                                        "Institution (Foundation/Asasi/Diploma)",
                                  ),
                                ),
                              ],

                              if (!isSpmOnly ||
                                  isSubjectBased ||
                                  isInstitutionBased) ...[
                                const SizedBox(height: 16),
                                TextFormField(
                                  controller: _cgpaController,
                                  decoration: const InputDecoration(
                                    labelText: "CGPA",
                                    helperText:
                                        "Cumulative Grade Point Average",
                                  ),
                                  keyboardType:
                                      const TextInputType.numberWithOptions(
                                        decimal: true,
                                      ),
                                ),
                              ],
                              const SizedBox(height: 16),
                              Align(
                                alignment: Alignment.centerLeft,
                                child: Wrap(
                                  spacing: 8,
                                  runSpacing: 4,
                                  children: _englishTests.map((test) {
                                    final isSelected = _englishTest == test;
                                    return ChoiceChip(
                                      label: Text(test),
                                      selected: isSelected,
                                      onSelected: (_) {
                                        setState(() {
                                          _englishTest = test;
                                          if (test == "None / Haven't taken") {
                                            _englishScoreController.text = '';
                                          }
                                        });
                                      },
                                    );
                                  }).toList(),
                                ),
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                controller: _englishScoreController,
                                decoration: const InputDecoration(
                                  labelText: "English Test Score",
                                  helperText: "e.g. Band 5, 7.5",
                                ),
                                enabled: _englishTest != "None / Haven't taken",
                              ),
                              const SizedBox(height: 16),
                              if (_hasSpm) ...[
                                _buildSlider(
                                  label: "PAJSK Score (0-10)",
                                  value: _pajsk,
                                  onChanged: (v) => setState(() => _pajsk = v),
                                ),
                              ] else ...[
                                _buildSlider(
                                  label: "Cocurriculum Score (0-10)",
                                  value: _cocurriculum,
                                  onChanged: (v) =>
                                      setState(() => _cocurriculum = v),
                                ),
                              ],

                              const SizedBox(height: 32),
                              _buildSectionTitle("Leadership & Achievements"),
                              _buildInterestsChips(),
                              const SizedBox(height: 16),
                              _buildStringListEditor(
                                title: "Leadership Roles (max 10)",
                                values: _leadership,
                                maxItems: 10,
                                onChanged: (updated) =>
                                    setState(() => _leadership = updated),
                              ),
                              const SizedBox(height: 16),
                              _buildStringListEditor(
                                title: "Achievements (max 10)",
                                values: _achievements,
                                maxItems: 10,
                                onChanged: (updated) =>
                                    setState(() => _achievements = updated),
                              ),
                              const SizedBox(height: 16),
                              _buildCompetitionEditor(
                                title: "Competitions (max 20)",
                                values: _competitions,
                                maxItems: 20,
                                onChanged: (updated) =>
                                    setState(() => _competitions = updated),
                              ),

                              const SizedBox(height: 32),
                              _buildSectionTitle("Financial Info"),
                              TextFormField(
                                controller: _incomeController,
                                decoration: const InputDecoration(
                                  labelText: "Household Income (RM)",
                                ),
                                keyboardType: TextInputType.number,
                              ),

                              const SizedBox(height: 32),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton.icon(
                                  onPressed: _saveProfile,
                                  icon: const Icon(Icons.save),
                                  label: const Text("Save Changes"),
                                  style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 16,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: Color(0xFF1E88E5),
          ),
        ),
        const Divider(),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildSlider({
    required String label,
    required double value,
    required ValueChanged<double> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label),
        Slider(
          value: value,
          divisions: 20,
          min: 0,
          max: 10,
          label: value.toStringAsFixed(1),
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildStringListEditor({
    required String title,
    required List<String> values,
    required int maxItems,
    required ValueChanged<List<String>> onChanged,
  }) {
    final controllers = values
        .map((value) => TextEditingController(text: value))
        .toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        ...controllers.asMap().entries.map((entry) {
          final idx = entry.key;
          final controller = entry.value;
          return Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: controller,
                    onChanged: (v) {
                      final updated = List<String>.from(values);
                      updated[idx] = v;
                      onChanged(updated);
                    },
                    decoration: InputDecoration(labelText: "Entry ${idx + 1}"),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () {
                    final updated = List<String>.from(values)..removeAt(idx);
                    onChanged(updated);
                  },
                ),
              ],
            ),
          );
        }),
        if (values.length < maxItems)
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: () {
                final updated = List<String>.from(values)..add('');
                onChanged(updated);
              },
              icon: const Icon(Icons.add),
              label: const Text("Add"),
            ),
          ),
      ],
    );
  }

  Widget _buildCompetitionEditor({
    required String title,
    required List<CompetitionEntry> values,
    required int maxItems,
    required ValueChanged<List<CompetitionEntry>> onChanged,
  }) {
    final nameControllers = values
        .map((e) => TextEditingController(text: e.name))
        .toList();
    final resultControllers = values
        .map((e) => TextEditingController(text: e.result))
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        ...values.asMap().entries.map((entry) {
          final idx = entry.key;
          final item = entry.value;
          final nameController = nameControllers[idx];
          final resultController = resultControllers[idx];
          return Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Column(
              children: [
                TextFormField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: "Competition ${idx + 1}",
                  ),
                  onChanged: (v) {
                    final updated = List<CompetitionEntry>.from(values);
                    updated[idx] = item.copyWith(name: v);
                    onChanged(updated);
                  },
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: resultController,
                        decoration: const InputDecoration(
                          labelText: "Result / Placement",
                        ),
                        onChanged: (v) {
                          final updated = List<CompetitionEntry>.from(values);
                          updated[idx] = item.copyWith(result: v);
                          onChanged(updated);
                        },
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline),
                      onPressed: () {
                        final updated = List<CompetitionEntry>.from(values)
                          ..removeAt(idx);
                        onChanged(updated);
                      },
                    ),
                  ],
                ),
              ],
            ),
          );
        }),
        if (values.length < maxItems)
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: () {
                final updated = List<CompetitionEntry>.from(values)
                  ..add(CompetitionEntry(name: '', result: ''));
                onChanged(updated);
              },
              icon: const Icon(Icons.add),
              label: const Text("Add Competition"),
            ),
          ),
      ],
    );
  }

  Widget _buildInterestsChips() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Areas of Interest",
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: _interestGroups.entries.map((entry) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    entry.key,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: entry.value.map((interest) {
                      final selected = _interests.contains(interest);
                      return FilterChip(
                        label: Text(interest),
                        selected: selected,
                        onSelected: (val) {
                          setState(() {
                            if (val) {
                              _interests = [..._interests, interest];
                            } else {
                              _interests = _interests
                                  .where((i) => i != interest)
                                  .toList();
                            }
                          });
                        },
                      );
                    }).toList(),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
