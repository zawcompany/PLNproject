import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/room_model.dart';
import '../models/complaint_model.dart';
import '../services/database_service.dart';

class ComplaintDialog extends StatefulWidget {
  final RoomModel room;
  final String itemId; 
  final Function(RoomCondition, List<String>, String) onSubmitted;

  const ComplaintDialog({
    super.key, 
    required this.room, 
    required this.itemId, 
    required this.onSubmitted
  });

  @override
  State<ComplaintDialog> createState() => _ComplaintDialogState();
}

class _ComplaintDialogState extends State<ComplaintDialog> {

  // state
  final List<String> selectedIssues = [];
  final TextEditingController otherIssueController = TextEditingController();
  final DatabaseService _db = DatabaseService();
  bool _isLoading = false;

  // kategori kerusakan
  final Map<String, List<String>> categories = {
    "Umum": ["Tempat tidur rusak", "Pintu rusak", "Plafon bocor", "Kursi goyang", "Lainnya"],
    "Kelistrikan": ["Lampu mati", "Stop kontak rusak", "Saklar rusak", "Listrik padam", "Lainnya"],
    "Kebersihan": ["Bau tidak sedap", "Dinding lembap", "Sprei kotor", "Banyak serangga", "Lainnya"],
  };

  // submit complaint
  Future<void> _submitComplaint() async {
    if (selectedIssues.isEmpty && otherIssueController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Silakan pilih atau tuliskan detail kerusakan"))
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      // --- LOGIKA PENENTUAN TEKNISI ---
      // Cek apakah ada salah satu issue yang mengandung kata "Kelistrikan"
      bool hasElectrical = selectedIssues.any((issue) => issue.startsWith("Kelistrikan:"));
      String assignedCategory = hasElectrical ? "listrik" : "lapangan";

      // Gabungkan deskripsi
      String finalDescription = "Kategori: ${selectedIssues.join(", ")}";
      if (otherIssueController.text.isNotEmpty) {
        finalDescription += ". Catatan Tambahan: ${otherIssueController.text}";
      }

      // Buat object complaint dengan category baru
      final complaint = ComplaintModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        roomId: widget.room.id,
        roomName: widget.room.name,
        userId: user.uid,
        description: finalDescription,
        createdAt: DateTime.now(),
        status: ComplaintStatus.pending,
        category: assignedCategory, // Masukkan kategori di sini
      );

      // Simpan ke firestore
      await _db.createComplaint(complaint, widget.itemId);

      if (!mounted) return;
      
      widget.onSubmitted(
        RoomCondition.perluPerbaikan, 
        selectedIssues, 
        otherIssueController.text
      );

      Navigator.pop(context);

    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: Colors.white,
      child: Container(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF008996).withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.report_problem_rounded, 
                      color: Color(0xFF008996), 
                      size: 22
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Form Pengaduan",
                          style: TextStyle(
                            fontWeight: FontWeight.bold, 
                            fontSize: 16
                          )
                        ),
                        Text(
                          widget.room.name, 
                          style: TextStyle(
                            color: Colors.grey[600], 
                            fontSize: 11
                          )
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // list kategori
              ...categories.entries.map((entry) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      entry.key,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold, 
                        fontSize: 13, 
                        color: Colors.black87
                      )
                    ),
                    const SizedBox(height: 8),

                    // chip pilihan
                    Wrap(
                      spacing: 6,
                      children: entry.value.map((issue) {
                        final fullIssueName = "${entry.key}: $issue";
                        final isSelected = selectedIssues.contains(fullIssueName);

                        return FilterChip(
                          label: Text(issue),
                          selected: isSelected,
                          onSelected: (bool selected) {
                            setState(() {
                              if (selected) {
                                selectedIssues.add(fullIssueName);
                              } else {
                                selectedIssues.remove(fullIssueName);
                              }
                            });
                          },
                          labelStyle: TextStyle(
                            fontSize: 10.5,
                            color: isSelected 
                                ? Colors.white 
                                : Colors.black87,
                          ),
                          selectedColor: const Color(0xFF008996),
                          checkmarkColor: Colors.white,
                          backgroundColor: Colors.grey[100],
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)
                          ),
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 16),
                  ],
                );
              }),

              // detail tambahan
              const Text(
                "Detail Lainnya (Opsional)", 
                style: TextStyle(
                  fontWeight: FontWeight.bold, 
                  fontSize: 13
                )
              ),
              const SizedBox(height: 8),

              TextField(
                controller: otherIssueController,
                maxLines: 2,
                style: const TextStyle(fontSize: 12),
                decoration: InputDecoration(
                  hintText: "Ketik detail kerusakan di sini...",
                  filled: true,
                  fillColor: Colors.grey[50],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(
                      color: Colors.grey[200]!
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // tombol aksi
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        "Batal",
                        style: TextStyle(
                          color: Colors.grey[600], 
                          fontWeight: FontWeight.bold
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _submitComplaint,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF008996),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)
                        ),
                        elevation: 0,
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              height: 15,
                              width: 15,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text(
                              "Kirim",
                              style: TextStyle(
                                fontWeight: FontWeight.bold
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}