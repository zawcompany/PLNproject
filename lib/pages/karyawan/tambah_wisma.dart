import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import '../../models/item_model.dart';

class AddWismaPopUp extends StatefulWidget {
  final ItemType type;
  final Function(ItemModel) onSave;

  const AddWismaPopUp({
    super.key,
    required this.type,
    required this.onSave,
  });

  @override
  State<AddWismaPopUp> createState() => _AddWismaPopUpState();
}

class _AddWismaPopUpState extends State<AddWismaPopUp> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController descController = TextEditingController();
  final TextEditingController dailyPriceController = TextEditingController();
  final TextEditingController monthlyPriceController = TextEditingController();
  final TextEditingController capacityController = TextEditingController();

  final Color primaryTeal = const Color(0xFF008996);

  File? selectedImage;
  final ImagePicker picker = ImagePicker();

  void _resetForm() {
    setState(() {
      nameController.clear();
      descController.clear();
      dailyPriceController.clear();
      monthlyPriceController.clear();
      capacityController.clear();
      selectedImage = null;
    });
  }

  Future<void> _pickImage() async {
    final XFile? image =
        await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        selectedImage = File(image.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isKelas = widget.type == ItemType.kelas;

    return Dialog(
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment:
                    MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox(width: 20),
                  Text(
                    isKelas
                        ? "Tambah Jenis Kelas"
                        : "Tambah Jenis Wisma",
                    style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),

              _buildLabel("Nama"),
              _buildTextField(nameController, "Masukkan nama"),

              _buildLabel("Deskripsi"),
              _buildTextField(descController,
                  "Masukkan deskripsi",
                  maxLines: 3),

              if (!isKelas) ...[
                _buildLabel("Harga per Hari"),
                _buildTextField(dailyPriceController,
                    "Contoh: 150000",
                    isNumber: true),

                _buildLabel("Harga per Bulan"),
                _buildTextField(monthlyPriceController,
                    "Contoh: 2500000",
                    isNumber: true),
              ],

              if (isKelas) ...[
                _buildLabel("Kapasitas (Jumlah Orang)"),
                _buildTextField(capacityController,
                    "Contoh: 24",
                    isNumber: true),
              ],

              _buildLabel("Gambar"),

              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 120,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius:
                        BorderRadius.circular(10),
                    border: Border.all(
                        color: Colors.grey.shade300),
                  ),
                  child: selectedImage == null
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                        Icon(
                            Icons.cloud_upload_outlined,
                            size: 38,
                            color: primaryTeal,
                        ),
                        const SizedBox(height: 8),
                        const Text(
                            "Unggah gambar",
                            style: TextStyle(fontSize: 13),
                        ),
                        ],
                    )

                      : ClipRRect(
                          borderRadius:
                              BorderRadius.circular(10),
                          child: Image.file(
                            selectedImage!,
                            fit: BoxFit.cover,
                            width: double.infinity,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 30),

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _resetForm,
                      style:
                          OutlinedButton.styleFrom(
                        side:
                            BorderSide(color: primaryTeal),
                        shape:
                            RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(10),
                        ),
                        padding:
                            const EdgeInsets.symmetric(
                                vertical: 15),
                      ),
                      child: Text("Reset",
                          style: TextStyle(
                              color: primaryTeal)),
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        if (nameController.text
                            .trim()
                            .isEmpty) return;

                        final newItem = ItemModel(
                          title:
                              nameController.text.trim(),
                          imagePath: selectedImage !=
                                  null
                              ? selectedImage!.path
                              : "lib/assets/images/anggrek.jpg",
                          type: widget.type,
                        );

                        widget.onSave(newItem);
                        Navigator.pop(context);
                      },
                      style:
                          ElevatedButton.styleFrom(
                        backgroundColor:
                            primaryTeal,
                        shape:
                            RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(10),
                        ),
                        padding:
                            const EdgeInsets.symmetric(
                                vertical: 15),
                      ),
                      child: const Text("Simpan",
                          style: TextStyle(
                              color: Colors.white)),
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

  Widget _buildLabel(String text) {
    return Padding(
      padding:
          const EdgeInsets.only(bottom: 8, top: 12),
      child: Text(
        text,
        style: const TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 12),
      ),
    );
  }

  Widget _buildTextField(
      TextEditingController controller,
      String hint,
      {int maxLines = 1,
      bool isNumber = false}) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: isNumber
          ? TextInputType.number
          : TextInputType.text,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: Colors.grey[50],
        contentPadding:
            const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 10),
        enabledBorder: OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(8),
          borderSide: BorderSide(
              color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(8),
          borderSide:
              BorderSide(color: primaryTeal),
        ),
      ),
    );
  }
}
