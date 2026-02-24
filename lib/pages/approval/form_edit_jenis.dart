import 'package:flutter/material.dart';
import '../../models/item_model.dart';
import '../../data/exsistingdata.dart';

class FormEditJenis extends StatefulWidget {
  final ItemType type;

  const FormEditJenis({super.key, required this.type});

  @override
  State<FormEditJenis> createState() => _FormEditJenisState();
}

class _FormEditJenisState extends State<FormEditJenis> {
  final _formKey = GlobalKey<FormState>();
  static const Color primaryTeal = Color(0xFF008996);
  static const Color blueBoxColor = Color(0xffbfe0e6); 
  
  ItemModel? selectedItem;
  final TextEditingController nameController = TextEditingController();
  final TextEditingController descController = TextEditingController();

  late List<ItemModel> filteredItems;

  @override
  void initState() {
    super.initState();
    filteredItems = LocalData.items.where((item) => item.type == widget.type).toList();
  }

  @override
  void dispose() {
    nameController.dispose();
    descController.dispose();
    super.dispose();
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

                _buildDropdownField(),
                
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 15),
                  child: Divider(),
                ),

                // FIELD NAMA BARU
                _buildTextField(nameController, "Nama Baru", Icons.edit_note_outlined),
                const SizedBox(height: 15),

                // FIELD DESKRIPSI BARU
                _buildTextField(
                  descController, 
                  "Deskripsi Baru", 
                  Icons.description_outlined, 
                  maxLines: 3
                ),

                const SizedBox(height: 25),

                // BUTTON SIMPAN
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryTeal,
                    minimumSize: const Size(double.infinity, 45),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    elevation: 0,
                  ),
                  onPressed: () {
                    if (_formKey.currentState!.validate() && selectedItem != null) {
                      Navigator.pop(context, true);
                    } else if (selectedItem == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Pilih data terlebih dahulu")),
                      );
                    }
                  },
                  child: const Text(
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

  Widget _buildDropdownField() {
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
          value: selectedItem,
          items: filteredItems.map((item) {
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