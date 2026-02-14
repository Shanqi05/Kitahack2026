import 'package:flutter/material.dart';
import '../data/career_service.dart';

class CareerListScreen extends StatefulWidget {
  const CareerListScreen({super.key});

  @override
  State<CareerListScreen> createState() => _CareerListScreenState();
}

class _CareerListScreenState extends State<CareerListScreen> {
  late Future<List<CareerModel>> _careersFuture;
  CareerModel? _selectedCareer; // Selected career for large screens

  @override
  void initState() {
    super.initState();
    _careersFuture = CareerService().loadCareers();
  }

  @override
  Widget build(BuildContext context) {
    // Get screen width to decide layout
    final isLargeScreen = MediaQuery.of(context).size.width > 800;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text("Career Insights"),
        backgroundColor: const Color(0xFF673AB7),
        elevation: 0,
      ),
      body: FutureBuilder<List<CareerModel>>(
        future: _careersFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No career data available."));
          }

          final careers = snapshot.data!;

          // Select first item by default on large screens if none selected
          if (isLargeScreen && _selectedCareer == null && careers.isNotEmpty) {
            _selectedCareer = careers.first;
          }

          if (isLargeScreen) {
            // --- Large Screen: Split View ---
            return Row(
              children: [
                // Left Panel: List
                Expanded(
                  flex: 4,
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border(right: BorderSide(color: Colors.grey.withOpacity(0.2))),
                    ),
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: careers.length,
                      itemBuilder: (context, index) {
                        final career = careers[index];
                        final isSelected = _selectedCareer?.id == career.id;
                        return _buildCareerCard(
                          context,
                          career,
                          isSelected: isSelected,
                          onTap: () {
                            setState(() {
                              _selectedCareer = career;
                            });
                          },
                        );
                      },
                    ),
                  ),
                ),
                // Right Panel: Details
                Expanded(
                  flex: 6,
                  child: _selectedCareer != null
                      ? _buildDetailView(_selectedCareer!)
                      : const Center(child: Text("Select a career to view details")),
                ),
              ],
            );
          } else {
            // --- Small Screen: Normal List ---
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: careers.length,
              itemBuilder: (context, index) {
                final career = careers[index];
                return _buildCareerCard(
                  context,
                  career,
                  isSelected: false,
                  onTap: () {
                    // On small screens, navigate to a new page or show dialog
                    _showDetailDialog(context, career);
                  },
                );
              },
            );
          }
        },
      ),
    );
  }

  // --- Widgets ---

  Widget _buildCareerCard(
      BuildContext context,
      CareerModel career, {
        required bool isSelected,
        required VoidCallback onTap,
      }) {
    return Card(
      elevation: isSelected ? 4 : 1,
      margin: const EdgeInsets.only(bottom: 12),
      color: isSelected ? const Color(0xFF673AB7).withOpacity(0.05) : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isSelected ? const BorderSide(color: Color(0xFF673AB7), width: 2) : BorderSide.none,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFF673AB7) : const Color(0xFF673AB7).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  _getIconForCategory(career.category),
                  color: isSelected ? Colors.white : const Color(0xFF673AB7),
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      career.title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isSelected ? const Color(0xFF673AB7) : Colors.black87,
                      ),
                    ),
                    Text(career.category, style: TextStyle(fontSize: 13, color: Colors.grey[600])),
                  ],
                ),
              ),
              if (isSelected) const Icon(Icons.check_circle, color: Color(0xFF673AB7), size: 20),
            ],
          ),
        ),
      ),
    );
  }

  // The Detail View (Right Panel)
  Widget _buildDetailView(CareerModel career) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF673AB7).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(_getIconForCategory(career.category), size: 40, color: const Color(0xFF673AB7)),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(career.title, style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Color(0xFF333333))),
                    const SizedBox(height: 8),
                    Chip(
                      label: Text(career.category),
                      backgroundColor: Colors.grey[200],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),

          // Description
          Text(career.description, style: TextStyle(fontSize: 16, color: Colors.grey[700], height: 1.6)),
          const SizedBox(height: 32),

          // Stats Grid
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 2.5,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            children: [
              _buildStatCard(Icons.monetization_on_rounded, "Salary Range", career.salaryRange, Colors.green),
              _buildStatCard(Icons.trending_up_rounded, "Demand", career.demand, Colors.orange),
              _buildStatCard(Icons.school_rounded, "Education", career.pathway, Colors.blue),
            ],
          ),
          const SizedBox(height: 32),

          // Skills Section
          const Text("Key Skills", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: career.skills.map((skill) => Chip(
              label: Text(skill, style: const TextStyle(fontSize: 14)),
              backgroundColor: const Color(0xFF673AB7).withOpacity(0.1),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            )).toList(),
          ),
        ],
      ),
    );
  }

  // Dialog for small screens (instead of bottom sheet)
  void _showDetailDialog(BuildContext context, CareerModel career) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 500, maxHeight: 600),
          child: Column(
            children: [
              // Header with Close Button
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(career.title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
                  ],
                ),
              ),
              const Divider(height: 1),
              // Content
              Expanded(child: _buildDetailView(career)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(IconData icon, String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.05), blurRadius: 5, offset: const Offset(0, 2))],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _getIconForCategory(String category) {
    switch (category) {
      case 'Technology': return Icons.computer_rounded;
      case 'Healthcare': return Icons.medical_services_rounded;
      case 'Finance': return Icons.attach_money_rounded;
      case 'Engineering': return Icons.build_rounded;
      case 'Business': return Icons.business_center_rounded;
      default: return Icons.work_rounded;
    }
  }
}