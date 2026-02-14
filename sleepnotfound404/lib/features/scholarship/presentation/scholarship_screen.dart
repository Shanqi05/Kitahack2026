import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart'; // For opening links (Optional)
import '../data/scholarship_service.dart';

class ScholarshipScreen extends StatefulWidget {
  const ScholarshipScreen({super.key});

  @override
  State<ScholarshipScreen> createState() => _ScholarshipScreenState();
}

class _ScholarshipScreenState extends State<ScholarshipScreen> {
  late Future<List<ScholarshipModel>> _scholarshipsFuture;
  List<ScholarshipModel> _allScholarships = [];
  List<ScholarshipModel> _filteredScholarships = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() async {
    final service = ScholarshipService();
    final data = await service.loadScholarships();
    setState(() {
      _allScholarships = data;
      _filteredScholarships = data;
    });
  }

  void _filterScholarships(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredScholarships = _allScholarships;
      } else {
        _filteredScholarships = _allScholarships
            .where((s) =>
        s.name.toLowerCase().contains(query.toLowerCase()) ||
            s.provider.toLowerCase().contains(query.toLowerCase()) ||
            s.category.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text("Scholarship Finder"),
        backgroundColor: const Color(0xFF673AB7),
        elevation: 0,
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: Color(0xFF673AB7),
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
            ),
            child: TextField(
              controller: _searchController,
              onChanged: _filterScholarships,
              decoration: InputDecoration(
                hintText: "Search by name or provider...",
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 20),
              ),
            ),
          ),

          // List
          Expanded(
            child: _filteredScholarships.isEmpty
                ? const Center(child: Text("No scholarships found."))
                : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _filteredScholarships.length,
              itemBuilder: (context, index) {
                final scholarship = _filteredScholarships[index];
                return _buildScholarshipCard(scholarship);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScholarshipCard(ScholarshipModel scholarship) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF673AB7).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.school, color: Color(0xFF673AB7)),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        scholarship.name,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        scholarship.provider,
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    scholarship.category,
                    style: const TextStyle(fontSize: 12, color: Colors.green, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const Divider(height: 30),
            _buildInfoRow(Icons.attach_money, "Amount", scholarship.amount),
            const SizedBox(height: 8),
            _buildInfoRow(Icons.calendar_today, "Deadline", scholarship.deadline),
            const SizedBox(height: 8),
            _buildInfoRow(Icons.check_circle_outline, "Criteria", scholarship.criteria),

            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  // Open Link logic (requires url_launcher package)
                  // _launchURL(scholarship.link);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Opening ${scholarship.link}")),
                  );
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF673AB7),
                  side: const BorderSide(color: Color(0xFF673AB7)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text("Apply Now"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: Colors.grey[500]),
        const SizedBox(width: 8),
        Text("$label: ", style: TextStyle(color: Colors.grey[600], fontSize: 13)),
        Expanded(
          child: Text(value, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13)),
        ),
      ],
    );
  }
}