// lib/features/wizard/widgets/step_4_talents.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/models/data_models.dart';
import '../../../core/models/user_session_model.dart';
import '../../../core/widgets/ui_kit.dart';

class Step4Talents extends StatefulWidget {
  const Step4Talents({super.key});

  @override
  State<Step4Talents> createState() => _Step4TalentsState();
}

class _Step4TalentsState extends State<Step4Talents> {
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

  void _addAchievement(UserSessionModel model) {
    final list = List<String>.from(model.preferences.achievements);
    list.add('');
    model.updatePreferences(model.preferences.copyWith(achievements: list));
  }

  void _removeAchievement(int index, UserSessionModel model) {
    final list = List<String>.from(model.preferences.achievements);
    list.removeAt(index);
    model.updatePreferences(model.preferences.copyWith(achievements: list));
  }

  void _updateAchievement(int index, String val, UserSessionModel model) {
    final list = List<String>.from(model.preferences.achievements);
    if (index >= 0 && index < list.length) {
      list[index] = val;
      model.updatePreferences(model.preferences.copyWith(achievements: list));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserSessionModel>(
      builder: (context, model, child) {
        final prefs = model.preferences;
        final qualification = model.profile.academicStatus;
        final hasSpm = model.academic.hasSpm || qualification == 'SPM Graduate';
        final needsCocu = [
          'STPM',
          'Matriculation',
          'Diploma',
        ].contains(qualification);

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Co-curricular & Talents",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),

              // 1. Cocurriculum / PAJSK
              if (hasSpm) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'PAJSK Score (SPM holders)',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        prefs.pajskScore.toStringAsFixed(1),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                Slider(
                  value: prefs.pajskScore,
                  min: 0.0,
                  max: 10.0,
                  divisions: 100,
                  label: prefs.pajskScore.toStringAsFixed(1),
                  onChanged: (value) {
                    model.updatePreferences(prefs.copyWith(pajskScore: value));
                  },
                ),
                const Text(
                  "Swipe to set your PAJSK score (0 - 10)",
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
                const SizedBox(height: 32),
              ] else if (needsCocu) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Cocurriculum Marks (0 - 10)',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    Text(
                      prefs.cocurriculumScore.toStringAsFixed(1),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                Slider(
                  value: prefs.cocurriculumScore,
                  min: 0.0,
                  max: 10.0,
                  divisions: 100,
                  label: prefs.cocurriculumScore.toStringAsFixed(1),
                  onChanged: (value) {
                    model.updatePreferences(
                      prefs.copyWith(cocurriculumScore: value),
                    );
                  },
                ),
                const SizedBox(height: 32),
              ],

              // 2. Leadership Roles (free text, up to 10)
              Text(
                'Leadership Roles (up to 10)',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: prefs.leadership.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            key: ValueKey('leader_$index'),
                            initialValue: prefs.leadership[index],
                            decoration: const InputDecoration(
                              labelText: 'Role / Position',
                              border: OutlineInputBorder(),
                            ),
                            onChanged: (val) {
                              final list = List<String>.from(prefs.leadership);
                              list[index] = val;
                              model.updatePreferences(
                                prefs.copyWith(leadership: list),
                              );
                            },
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            final list = List<String>.from(prefs.leadership);
                            list.removeAt(index);
                            model.updatePreferences(
                              prefs.copyWith(leadership: list),
                            );
                          },
                        ),
                      ],
                    ),
                  );
                },
              ),
              if (prefs.leadership.length < 10)
                TextButton.icon(
                  onPressed: () {
                    final list = List<String>.from(prefs.leadership);
                    list.add('');
                    model.updatePreferences(prefs.copyWith(leadership: list));
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Add Leadership Role'),
                ),

              const SizedBox(height: 32),

              // 3. Area of Interest
              Text(
                'Area of Interest',
                style: Theme.of(context).textTheme.titleMedium,
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
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8.0,
                          runSpacing: 8.0,
                          children: entry.value.map((interest) {
                            final isSelected = prefs.interests.contains(interest);
                            return FilterChip(
                              label: Text(interest),
                              selected: isSelected,
                              checkmarkColor: Colors.white,
                              selectedColor: Theme.of(context).primaryColor,
                              labelStyle: TextStyle(
                                color: isSelected ? Colors.white : Colors.black87,
                              ),
                              onSelected: (bool selected) {
                                List<String> newInterests = List.from(prefs.interests);
                                if (selected) {
                                  newInterests.add(interest);
                                } else {
                                  newInterests.remove(interest);
                                }
                                model.updatePreferences(
                                  prefs.copyWith(interests: newInterests),
                                );
                              },
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
              // 4. Achievements
              const SizedBox(height: 32),
              Text(
                'Achievements',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              if (prefs.achievements.isEmpty)
                Text(
                  "No achievements added yet.",
                  style: TextStyle(color: Colors.grey[600]),
                ),
              const SizedBox(height: 8),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: prefs.achievements.length,
                itemBuilder: (context, index) {
                  // We use a key to preserve focus when list updates, though less critical for simple list
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            key: ValueKey("ach_$index"), // Attempt to keep focus
                            initialValue: prefs.achievements[index],
                            decoration: const InputDecoration(
                              labelText: 'Add Achievement',
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 12,
                              ),
                            ),
                            onChanged: (val) =>
                                _updateAchievement(index, val, model),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _removeAchievement(index, model),
                        ),
                      ],
                    ),
                  );
                },
              ),
              TextButton.icon(
                onPressed: () => _addAchievement(model),
                icon: const Icon(Icons.add),
                label: const Text("Add Achievement"),
              ),

              const SizedBox(height: 32),

              // Competitions / Awards
              Text(
                'Competitions & Placements (up to 20)',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: prefs.competitions.length,
                itemBuilder: (context, index) {
                  final entry = prefs.competitions[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: TextFormField(
                            key: ValueKey('comp_${index}_name'),
                            initialValue: entry.name,
                            decoration: const InputDecoration(
                              labelText: 'Competition / Event',
                              border: OutlineInputBorder(),
                            ),
                            onChanged: (val) {
                              final list = List<CompetitionEntry>.from(
                                prefs.competitions,
                              );
                              list[index] =
                                  entry.copyWith(name: val);
                              model.updatePreferences(
                                prefs.copyWith(competitions: list),
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          flex: 2,
                          child: TextFormField(
                            key: ValueKey('comp_${index}_result'),
                            initialValue: entry.result,
                            decoration: const InputDecoration(
                              labelText: 'Placement (e.g. Champion)',
                              border: OutlineInputBorder(),
                            ),
                            onChanged: (val) {
                              final list = List<CompetitionEntry>.from(
                                prefs.competitions,
                              );
                              list[index] =
                                  entry.copyWith(result: val);
                              model.updatePreferences(
                                prefs.copyWith(competitions: list),
                              );
                            },
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            final list = List<CompetitionEntry>.from(
                              prefs.competitions,
                            );
                            list.removeAt(index);
                            model.updatePreferences(
                              prefs.copyWith(competitions: list),
                            );
                          },
                        ),
                      ],
                    ),
                  );
                },
              ),
              if (prefs.competitions.length < 20)
                TextButton.icon(
                  onPressed: () {
                    final list = List<CompetitionEntry>.from(
                      prefs.competitions,
                    );
                    list.add(CompetitionEntry(name: '', result: ''));
                    model.updatePreferences(
                      prefs.copyWith(competitions: list),
                    );
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Add Competition / Placement'),
                ),

              // 5. Top Interest (Crucial for Analysis)
              if (prefs.interests.isNotEmpty) ...[
                Text(
                  'Primary Interest (for matching)',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                ModernDropdown<String>(
                  label: "Select your main interest",
                  value:
                      prefs.interests.contains(prefs.topInterest)
                          ? prefs.topInterest
                          : null,
                  icon: Icons.star,
                  items:
                      prefs.interests.map((i) {
                        return DropdownMenuItem(value: i, child: Text(i));
                      }).toList(),
                  onChanged: (val) {
                    if (val != null) {
                      model.updateTalent(topInterest: val);
                    }
                  },
                ),
              ] else
                const Text(
                  "Select interests above to choose a Primary Interest.",
                  style: TextStyle(color: Colors.amber, fontStyle: FontStyle.italic),
                ),
            ],
          ),
        );
      },
    );
  }
}
