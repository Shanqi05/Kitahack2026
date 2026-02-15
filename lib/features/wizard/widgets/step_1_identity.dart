// lib/features/wizard/widgets/step_1_identity.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/models/data_models.dart';
import '../../../core/models/user_session_model.dart';
import '../../../core/widgets/ui_kit.dart';

class Step1Identity extends StatefulWidget {
  const Step1Identity({super.key});

  @override
  State<Step1Identity> createState() => _Step1IdentityState();
}

class _Step1IdentityState extends State<Step1Identity> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  late TextEditingController _nameController;
  late TextEditingController _icController;
  late TextEditingController _phoneController;

  // State
  String _academicStatus = 'SPM Graduate';
  String _state = 'Kuala Lumpur';
  String _ethnicity = 'Bumiputera';
  String _ethnicitySubgroup = '';
  bool _isFirstGen = false;
  bool _isOku = false;
  List<String> _specialConsiderations = [];

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

  final List<String> _ethnicityOptions = ['Bumiputera', 'Non-Bumiputera'];

  final Map<String, List<String>> _ethnicitySubgroupOptions = {
    'Bumiputera': [
      'Melayu',
      'Bumiputera Sabah',
      'Bumiputera Sarawak',
      'Orang Asli',
    ],
    'Non-Bumiputera': ['Chinese', 'Indian', 'Others'],
  };

  @override
  void initState() {
    super.initState();
    final model = context.read<UserSessionModel>();
    _nameController = TextEditingController(text: model.profile.name);
    _icController = TextEditingController(text: model.profile.identityNumber);
    _phoneController = TextEditingController(text: model.profile.phone);

    if (model.profile.academicStatus.isNotEmpty) {
      _academicStatus = model.profile.academicStatus;
    }
    if (model.profile.state.isNotEmpty) {
      _state = model.profile.state;
    }
    if (model.profile.ethnicity.isNotEmpty) {
      _ethnicity = model.profile.ethnicity;
    }
    if (model.profile.ethnicitySubgroup.isNotEmpty) {
      _ethnicitySubgroup = model.profile.ethnicitySubgroup;
    }
    _isFirstGen = model.profile.isFirstGen;
    _isOku = model.profile.isOku;
    _specialConsiderations = List.from(model.profile.specialConsiderations);

    // Initial sync
    WidgetsBinding.instance.addPostFrameCallback((_) => _updateModel());
  }

  @override
  void dispose() {
    _nameController.dispose();
    _icController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _updateModel() {
    final model = context.read<UserSessionModel>();

    final newProfileData = model.profile.copyWith(
      name: _nameController.text,
      identityNumber: _icController.text,
      phone: _phoneController.text,
      academicStatus: _academicStatus,
      state: _state,
      ethnicity: _ethnicity,
      ethnicitySubgroup: _ethnicitySubgroup,
      isFirstGen: _isFirstGen,
      isOku: _isOku,
      specialConsiderations: _specialConsiderations,
    );

    model.updateProfile(newProfileData);

    // Sync academic status -> hasSpm?
    // If status is 'SPM Graduate', assumes they HAVE SPM or just finished it.
    // We let Step 2 handle the specific 'hasSpm' toggle based on user input,
    // but we could set a default here if needed.
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFF3F8FF), Color(0xFFE9F6F2)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              onChanged: _updateModel,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Identity Information',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 24),
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Full Name',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.person),
                    ),
                    validator: (v) => v?.isEmpty == true ? 'Required' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _icController,
                    decoration: const InputDecoration(
                      labelText: 'Identity Number (IC)',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.badge),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _phoneController,
                    decoration: const InputDecoration(
                      labelText: 'Phone Number',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.phone),
                    ),
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 16),
                  ModernDropdown<String>(
                    label: 'Academic Status',
                    value: _academicStatus,
                    icon: Icons.school,
                    items: _statusOptions
                        .map(
                          (status) => DropdownMenuItem(
                            value: status,
                            child: Text(status),
                          ),
                        )
                        .toList(),
                    onChanged: (val) {
                      if (val != null) {
                        setState(() => _academicStatus = val);
                        _updateModel();
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  ModernDropdown<String>(
                    label: 'State of Residence',
                    value: _state,
                    icon: Icons.map,
                    items: _stateOptions
                        .map(
                          (state) => DropdownMenuItem(
                            value: state,
                            child: Text(state),
                          ),
                        )
                        .toList(),
                    onChanged: (val) {
                      if (val != null) {
                        setState(() => _state = val);
                        _updateModel();
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFF6FF),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFB3D4FF)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Background & Support',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Ethnicity',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Column(
                          children: _ethnicityOptions.map((e) {
                            return RadioListTile<String>(
                              title: Text(e),
                              value: e,
                              groupValue: _ethnicity,
                              onChanged: (value) {
                                if (value != null) {
                                  setState(() {
                                    _ethnicity = value;
                                    _ethnicitySubgroup = '';
                                  });
                                  _updateModel();
                                }
                              },
                            );
                          }).toList(),
                        ),
                        if (_ethnicitySubgroupOptions.containsKey(_ethnicity))
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8.0,
                            ),
                            child: ModernDropdown<String>(
                              label: 'Subgroup',
                              value:
                                  _ethnicitySubgroupOptions[_ethnicity]!
                                      .contains(_ethnicitySubgroup)
                                  ? _ethnicitySubgroup
                                  : null,
                              icon: Icons.group,
                              items: _ethnicitySubgroupOptions[_ethnicity]!
                                  .map(
                                    (sub) => DropdownMenuItem(
                                      value: sub,
                                      child: Text(sub),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (val) {
                                if (val != null) {
                                  setState(() => _ethnicitySubgroup = val);
                                  _updateModel();
                                }
                              },
                            ),
                          ),
                        const SizedBox(height: 12),
                        const Text(
                          'Special Status',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        CheckboxListTile(
                          title: const Text(
                            'First-generation university student',
                          ),
                          value: _isFirstGen,
                          onChanged: (value) {
                            setState(() => _isFirstGen = value ?? false);
                            _updateModel();
                          },
                          controlAffinity: ListTileControlAffinity.leading,
                        ),
                        CheckboxListTile(
                          title: const Text(
                            'OKU (Person with Disabilities) status',
                          ),
                          value: _isOku,
                          onChanged: (value) {
                            setState(() => _isOku = value ?? false);
                            _updateModel();
                          },
                          controlAffinity: ListTileControlAffinity.leading,
                        ),
                        const Divider(),
                        const Text(
                          'Other Considerations',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        ...[
                          'Athlete',
                          'Single Parent Household',
                          'Children of Police/Army',
                          'Orphan / Piatu',
                          'Chronic Illness',
                          'Large Family (>5 siblings)',
                          'Refugee Status',
                        ].map((option) {
                          return CheckboxListTile(
                            title: Text(option),
                            value: _specialConsiderations.contains(option),
                            onChanged: (bool? value) {
                              setState(() {
                                if (value == true) {
                                  _specialConsiderations.add(option);
                                } else {
                                  _specialConsiderations.remove(option);
                                }
                              });
                              _updateModel();
                            },
                            controlAffinity: ListTileControlAffinity.leading,
                          );
                        }),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
