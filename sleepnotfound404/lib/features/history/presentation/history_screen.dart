import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  String _formatDate(Timestamp? timestamp) {
    if (timestamp == null) return 'Unknown Date';
    DateTime dt = timestamp.toDate();
    return "${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}";
  }

  void _deleteHistory(BuildContext context, String docId) {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('admission_history')
          .doc(docId)
          .delete()
          .then((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('History deleted.'), backgroundColor: Colors.red),
        );
      });
    }
  }

  void _showDetailsDialog(BuildContext context, Map<String, dynamic> data) {
    final qualification = data['qualification'] ?? 'Unknown';
    final timestamp = data['timestamp'] as Timestamp?;
    final gradesMap = data['grades'] is Map ? Map<String, dynamic>.from(data['grades']) : {};
    final interestsList = data['interests'] is List ? List<String>.from(data['interests']) : [];
    final topCoursesList = data['top_courses'] is List ? List<String>.from(data['top_courses']) : [];
    final aiFeedback = data['ai_feedback'] ?? 'No AI feedback generated.';
    final budget = data['budget'];

    showDialog(
        context: context,
        builder: (context) {
          return Dialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: Container(
              constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.8),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    decoration: const BoxDecoration(
                      color: Color(0xFF673AB7),
                      borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "$qualification Details",
                          style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.white),
                          onPressed: () => Navigator.pop(context),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ],
                    ),
                  ),
                  Flexible(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("📊 Academic Profile", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF673AB7))),
                          const SizedBox(height: 8),
                          Text("Date: ${_formatDate(timestamp)}", style: const TextStyle(fontSize: 13, color: Colors.grey)),
                          if (budget != null)
                            Text("Budget / Salary Expected: RM ${budget.toStringAsFixed(0)}", style: const TextStyle(fontSize: 13, color: Colors.grey)),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: gradesMap.entries.map((e) => Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey[300]!)),
                              child: Text("${e.key}: ${e.value}", style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                            )).toList(),
                          ),
                          const SizedBox(height: 24),

                          const Text("🎯 Target Fields", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF673AB7))),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: interestsList.map((i) => Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(color: Colors.blue.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                              child: Text(i, style: const TextStyle(fontSize: 13, color: Colors.blue, fontWeight: FontWeight.w600)),
                            )).toList(),
                          ),
                          const SizedBox(height: 24),

                          const Text("🏫 Recommended Courses", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF673AB7))),
                          const SizedBox(height: 8),
                          if (topCoursesList.isEmpty)
                            const Text("No specific courses saved.", style: TextStyle(fontSize: 13))
                          else
                            ...topCoursesList.map((c) => Padding(
                              padding: const EdgeInsets.only(bottom: 6),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text("• ", style: TextStyle(color: Color(0xFF673AB7), fontWeight: FontWeight.bold)),
                                  Expanded(child: Text(c, style: const TextStyle(fontSize: 13, height: 1.4))),
                                ],
                              ),
                            )).toList(),
                          const SizedBox(height: 24),

                          const Row(
                            children: [
                              Icon(Icons.auto_awesome, color: Colors.orange, size: 20),
                              SizedBox(width: 8),
                              Text("AI Analysis & Advice", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.orange)),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(color: Colors.orange.withOpacity(0.05), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.orange.withOpacity(0.3))),
                            child: Text(aiFeedback, style: const TextStyle(fontSize: 13, height: 1.5, color: Colors.black87)),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text("My Admission History"),
        backgroundColor: const Color(0xFF673AB7),
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFF5F7FA), Color(0xFFEDE7F6)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: user == null
            ? const Center(child: Text("Please login to view history."))
            : StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .collection('admission_history')
              .orderBy('timestamp', descending: true)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator(color: Color(0xFF673AB7)));
            }

            if (snapshot.hasError) {
              return Center(child: Text("Error: ${snapshot.error}"));
            }

            final docs = snapshot.data?.docs ?? [];

            if (docs.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.history_toggle_off, size: 80, color: Colors.grey[400]),
                    const SizedBox(height: 16),
                    Text("No history found yet.", style: TextStyle(color: Colors.grey[600], fontSize: 16)),
                    const SizedBox(height: 8),
                    const Text("Save a result in the Admission Predictor!"),
                  ],
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: docs.length,
              itemBuilder: (context, index) {
                final doc = docs[index];
                final data = doc.data() as Map<String, dynamic>;
                final timestamp = data['timestamp'] as Timestamp?;
                final qualification = data['qualification'] ?? 'Unknown';

                final gradesMap = data['grades'] is Map ? Map<String, dynamic>.from(data['grades']) : {};
                final interestsList = data['interests'] is List ? List<String>.from(data['interests']) : [];

                // 🌟 将成绩拆分为 普通科目 和 特殊科目 (MUET, 课外活动, CGPA 等)
                final specialKeys = ['MUET', 'CocurricularMark', 'CGPA', 'DiplomaField'];
                final mainSubjects = gradesMap.entries.where((e) => !specialKeys.contains(e.key)).toList();
                final specialSubjects = gradesMap.entries.where((e) => specialKeys.contains(e.key)).toList();

                return Card(
                  elevation: 2,
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: InkWell(
                    onTap: () => _showDetailsDialog(context, data),
                    borderRadius: BorderRadius.circular(16),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: const Color(0xFF673AB7).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Center(
                              child: Text(
                                  qualification.length > 3 ? qualification.substring(0,3).toUpperCase() : qualification,
                                  style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF673AB7), fontSize: 14)
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),

                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _formatDate(timestamp),
                                  style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                                ),
                                const SizedBox(height: 6),

                                // 🌟 1. 第一行：半透明紫色小长方形 (Main Subjects)
                                if (mainSubjects.isNotEmpty)
                                  Wrap(
                                    spacing: 6,
                                    runSpacing: 6,
                                    children: mainSubjects.map((e) => Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF673AB7).withOpacity(0.08),
                                        borderRadius: BorderRadius.circular(6),
                                        border: Border.all(color: const Color(0xFF673AB7).withOpacity(0.2)),
                                      ),
                                      child: Text(
                                        "${e.key}: ${e.value}",
                                        style: const TextStyle(fontSize: 11, color: Color(0xFF673AB7), fontWeight: FontWeight.bold),
                                      ),
                                    )).toList(),
                                  ),

                                // 🌟 2. 第二行：半透明橙色/蓝色小长方形 (MUET / CocurricularMark / CGPA)
                                if (specialSubjects.isNotEmpty) ...[
                                  const SizedBox(height: 6),
                                  Wrap(
                                    spacing: 6,
                                    runSpacing: 6,
                                    children: specialSubjects.map((e) {
                                      String displayKey = e.key;
                                      String displayValue = e.value.toString();

                                      // 优化显示名称，Koko显示分数
                                      if (e.key == 'CocurricularMark') {
                                        displayKey = 'Koko';
                                      }

                                      return Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                                        decoration: BoxDecoration(
                                          color: Colors.orange.withOpacity(0.08),
                                          borderRadius: BorderRadius.circular(6),
                                          border: Border.all(color: Colors.orange.withOpacity(0.3)),
                                        ),
                                        child: Text(
                                          "$displayKey: $displayValue",
                                          style: TextStyle(fontSize: 11, color: Colors.orange[800], fontWeight: FontWeight.bold),
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                ],

                                const SizedBox(height: 8),
                                if (interestsList.isNotEmpty)
                                  Text(
                                    "Target: ${interestsList.join(', ')}",
                                    style: const TextStyle(fontSize: 12, color: Colors.black87, fontWeight: FontWeight.w600),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                              ],
                            ),
                          ),

                          IconButton(
                            icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 22),
                            onPressed: () => _deleteHistory(context, doc.id),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}