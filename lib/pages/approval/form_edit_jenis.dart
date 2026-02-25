import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Tambah ini
import '../../models/item_model.dart';
import '../../services/database_service.dart'; // Tambah ini

class FormEditJenis extends StatefulWidget {
  final ItemType type;

  const FormEditJenis({super.key, required this.type});

  @override
  State<FormEditJenis> createState() => _FormEditJenisState();
}

class _FormEditJenisState extends State<FormEditJenis> {
  final _formKey = GlobalKey<FormState>();
  final DatabaseService _db = DatabaseService(); // Inisialisasi Service
  
  static const Color primaryTeal = Color(0xFF008996);
  
  ItemModel? selectedItem;
  final TextEditingController nameController = TextEditingController();
  final TextEditingController descController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    nameController.dispose();
    descController.dispose();
    super.dispose();
  }

  // FUNGSI UPDATE DATA KE FIRESTORE
  Future<void> _updateData() async {
    if (_formKey.currentState!.validate() && selectedItem != null) {
      setState(() => _isLoading = true);
      
      try {
        await FirebaseFirestore.instance
            .collection('items')
            .doc(selectedItem!.id)
            .update({
          'title': nameController.text.trim(),
          'description': descController.text.trim(),
        });

        if (!mounted) return;
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Data berhasil diperbarui"), backgroundColor: Colors.green),
        );
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Gagal memperbarui: $e"), backgroundColor: Colors.red),
        );
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Edit Data ${widget.type == ItemType.wisma ? 'Wisma' : 'Kelas'}",
                      style: const TextStyle(
                        fontSize: 18, 
                        fontWeight: FontWeight.bold, 
                        color: primaryTeal
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context), 
                      icon: const Icon(Icons.close)
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // MENGGUNAKAN STREAMBUILDER AGAR DATA DROPDOWN REAL-TIME
                StreamBuilder<List<ItemModel>>(
                  stream: _db.getItems(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) return const CircularProgressIndicator();
                    
                    final filteredItems = snapshot.data!
                        .where((item) => item.type == widget.type)
                        .toList();

                    return _buildDropdownField(filteredItems);
                  }
                ),
                
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 15),
                  child: Divider(),
                ),

                _buildTextField(nameController, "Nama Baru", Icons.edit_note_outlined),
                const SizedBox(height: 15),

                _buildTextField(
                  descController, 
                  "Deskripsi Baru", 
                  Icons.description_outlined, 
                  maxLines: 3
                ),

                const SizedBox(height: 25),

                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryTeal,
                    minimumSize: const Size(double.infinity, 45),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    elevation: 0,
                  ),
                  onPressed: _isLoading ? null : _updateData,
                  child: _isLoading 
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text(
                        "Simpan Perubahan", 
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)
                      ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDropdownField(List<ItemModel> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Pilih Data Eksisting", 
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Colors.grey)
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<ItemModel>(
          isExpanded: true,
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.list_alt_rounded, color: primaryTeal),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
          hint: const Text("Pilih Nama"),
          value: selectedItem != null 
              ? items.firstWhere((element) => element.id == selectedItem!.id, orElse: () => items.first) 
              : null,
          items: items.map((item) {
            return DropdownMenuItem(
              value: item,
              child: Text(item.title, style: const TextStyle(fontSize: 14)),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              selectedItem = value;
              nameController.text = value?.title ?? "";
              descController.text = value?.description ?? "";
            });
          },
        ),
      ],
    );
  }

  Widget _buildTextField(
    TextEditingController controller, 
    String label, 
    IconData icon, 
    {int maxLines = 1}
  ) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      style: const TextStyle(fontSize: 14),
      decoration: InputDecoration(
        labelText: label,
        alignLabelWithHint: true,
        prefixIcon: Icon(icon, color: primaryTeal),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        labelStyle: const TextStyle(color: Colors.grey, fontSize: 13),
      ),
      validator: (val) => (val == null || val.isEmpty) ? "Field ini wajib diisi" : null,
    );
  }
}