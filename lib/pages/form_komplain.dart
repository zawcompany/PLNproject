import 'package:flutter/material.dart';
import '../models/room_model.dart';

class ComplaintDialog extends StatefulWidget {
  final RoomModel room;
  final Function(RoomCondition, List<String>, String) onSubmitted;

  const ComplaintDialog({super.key, required this.room, required this.onSubmitted});

  @override
  State<ComplaintDialog> createState() => _ComplaintDialogState();
}

class _ComplaintDialogState extends State<ComplaintDialog> {
  final List<String> selectedIssues = [];
  final TextEditingController otherIssueController = TextEditingController();

  final Map<String, List<String>> categories = {
    "Umum": ["Tempat tidur rusak", "Pintu rusak", "Plafon bocor", "Kursi goyang", "Lainnya"],
    "Kelistrikan": ["Lampu mati", "Stop kontak rusak", "Saklar rusak", "Listrik padam", "Lainnya"],
    "Kebersihan": ["Bau tidak sedap", "Dinding lembap", "Sprei kotor", "Banyak serangga", "Lainnya"],
  };

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
              // HEADER
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF008996).withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.report_problem_rounded,
                        color: Color(0xFF008996), size: 22),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Form Pengaduan",
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        Text(widget.room.name,
                            style: TextStyle(color: Colors.grey[600], fontSize: 11)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // LIST KATEGORI DENGAN CHIPS
              ...categories.entries.map((entry) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(entry.key,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black87)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6, // Jarak horizontal antar chip
                      runSpacing: 0, // Jarak vertikal antar baris chip dibuat mepet
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
                          // Pengaturan agar chip rapat dan teks kecil
                          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          labelStyle: TextStyle(
                            fontSize: 10.5, // Ukuran teks item
                            color: isSelected ? Colors.white : Colors.black87,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                          selectedColor: const Color(0xFF008996),
                          checkmarkColor: Colors.white,
                          backgroundColor: Colors.grey[100],
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                            side: BorderSide(
                              color: isSelected ? const Color(0xFF008996) : Colors.transparent,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),
                  ],
                );
              }),

              // DESKRIPSI TAMBAHAN
              const Text("Detail Lainnya (Opsional)",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              const SizedBox(height: 8),
              TextField(
                controller: otherIssueController,
                maxLines: 2,
                style: const TextStyle(fontSize: 12),
                decoration: InputDecoration(
                  hintText: "Ketik di sini...",
                  hintStyle: TextStyle(fontSize: 11, color: Colors.grey[400]),
                  filled: true,
                  fillColor: Colors.grey[50],
                  contentPadding: const EdgeInsets.all(10),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.grey[200]!),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.grey[200]!),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Color(0xFF008996)),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // BUTTONS
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text("Batal",
                          style: TextStyle(color: Colors.grey[600], fontWeight: FontWeight.bold, fontSize: 13)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        widget.onSubmitted(RoomCondition.perluPerbaikan,
                            selectedIssues, otherIssueController.text);
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF008996),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                      child: const Text("Kirim",
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
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