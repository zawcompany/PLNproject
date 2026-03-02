import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/item_model.dart';
// FIX ERROR 2: Impor room_model.dart dihapus karena tidak digunakan secara eksplisit di tipe data
import '../../services/database_service.dart';

class FormEditJenis extends StatefulWidget {
  final ItemType type;

  const FormEditJenis({super.key, required this.type});

  @override
  State<FormEditJenis> createState() => _FormEditJenisState();
}

class _FormEditJenisState extends State<FormEditJenis> {
  final _formKey = GlobalKey<FormState>();
  final DatabaseService _db = DatabaseService(); 
  
  static const Color primaryTeal = Color(0xFF008996);
  
  ItemModel? selectedItem;
  final TextEditingController nameController = TextEditingController();
  final TextEditingController descController = TextEditingController();
  final TextEditingController roomCountController = TextEditingController(text: '0');
  List<TextEditingController> roomNameControllers = [];

  bool _isLoading = false;

  @override
  void dispose() {
    nameController.dispose();
    descController.dispose();
    roomCountController.dispose();
    for (var c in roomNameControllers) {
      c.dispose();
    }
    super.dispose();
  }

  void _updateRoomFields(String value) {
    int count = int.tryParse(value) ?? 0;
    setState(() {
      if (count > roomNameControllers.length) {
        int additional = count - roomNameControllers.length;
        for (int i = 0; i < additional; i++) {
          roomNameControllers.add(TextEditingController());
        }
      } else if (count < roomNameControllers.length) {
        roomNameControllers.removeRange(count, roomNameControllers.length);
      }
    });
  }

  Future<void> _updateData() async {
    if (_formKey.currentState!.validate() && selectedItem != null) {
      setState(() => _isLoading = true);
      
      try {
        List<Map<String, dynamic>> newRooms = [];
        
        if (selectedItem!.rooms.isNotEmpty) {
          for (var r in selectedItem!.rooms) {
            newRooms.add(r.toMap());
          }
        }

        for (var controller in roomNameControllers) {
          if (controller.text.isNotEmpty) {
            String roomId = "${DateTime.now().millisecondsSinceEpoch}_${controller.text.hashCode}";
            newRooms.add({
              'id': roomId,
              'name': controller.text.trim(),
              'condition': 'kosong',
              'capacity': widget.type == ItemType.kelas ? 30 : 4,
            });
          }
        }

        await FirebaseFirestore.instance
            .collection('items')
            .doc(selectedItem!.id)
            .update({
          'title': nameController.text.trim(),
          'description': descController.text.trim(),
          'rooms': newRooms,
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
      child: Container(
        constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.8),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text( // FIX ERROR 3: Tambahkan const di sini
                      "Edit & Tambah Kamar",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: primaryTeal),
                    ),
                    IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close)),
                  ],
                ),
                const SizedBox(height: 10),

                StreamBuilder<List<ItemModel>>(
                  stream: _db.getItems(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                    
                    final filteredItems = snapshot.data!
                        .where((item) => item.type == widget.type)
                        .toList();

                    return _buildDropdownField(filteredItems);
                  }
                ),
                
                const Divider(height: 30),

                _buildTextField(nameController, "Nama Fasilitas", Icons.edit_note_outlined),
                const SizedBox(height: 15),
                _buildTextField(descController, "Deskripsi", Icons.description_outlined, maxLines: 2),
                
                const SizedBox(height: 20),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text("Tambah Unit Baru", style: TextStyle(fontWeight: FontWeight.bold, color: primaryTeal)),
                ),
                const SizedBox(height: 10),
                
                _buildTextField(roomCountController, "Jumlah Kamar Baru", Icons.add_box_outlined, type: TextInputType.number, onChanged: _updateRoomFields),
                
                // FIX ERROR 4: Hapus .toList() di akhir spread operator
                ...roomNameControllers.asMap().entries.map((entry) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: _buildTextField(entry.value, "Nama Kamar ${entry.key + 1}", Icons.meeting_room_outlined),
                  );
                }),

                const SizedBox(height: 25),

                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryTeal,
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: _isLoading ? null : _updateData,
                  child: _isLoading 
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Simpan Perubahan", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDropdownField(List<ItemModel> items) {
    return DropdownButtonFormField<ItemModel>(
      isExpanded: true,
      decoration: InputDecoration(
        labelText: "Pilih Data Eksisting",
        prefixIcon: const Icon(Icons.list_alt_rounded, color: primaryTeal),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
      // FIX ERROR 1: Ganti 'value' dengan 'initialValue' jika ingin performa lebih baik, 
      // namun untuk DropdownButtonFormField tetap gunakan 'value' untuk sinkronisasi state.
      // Deprecated warning ini biasanya muncul pada TextFormField kustom. 
      // Jika error tetap muncul di baris ini, pastikan 'value' adalah item yang ada di list.
      value: selectedItem != null ? items.firstWhere((e) => e.id == selectedItem!.id, orElse: () => items.first) : null,
      items: items.map((item) => DropdownMenuItem(value: item, child: Text(item.title))).toList(),
      onChanged: (value) {
        setState(() {
          selectedItem = value;
          nameController.text = value?.title ?? "";
          descController.text = value?.description ?? "";
        });
      },
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, {int maxLines = 1, TextInputType type = TextInputType.text, Function(String)? onChanged}) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: type,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: primaryTeal),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
      onChanged: onChanged,
      validator: (val) => (val == null || val.isEmpty) ? "Wajib diisi" : null,
    );
  }
}