import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'detail.dart';
import '../../models/item_model.dart';
import 'package:monitoring_app/widgets/navbar.dart';
import '../../data/exsistingdata.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  static const Color primaryTeal = Color(0xFF008996);
  static const Color softTeal = Color(0xFFE8F1F3);
  
  ItemType selectedMenu = ItemType.wisma;
  final List<ItemModel> items = LocalData.items;

  @override
  Widget build(BuildContext context) {
    final filteredItems = items.where((item) => item.type == selectedMenu).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      // AppBar dihapus untuk tampilan yang lebih polos
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 25),
              
              // Header Teks Langsung di Body
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Selamat Datang,",
                        style: TextStyle(fontSize: 14, color: Colors.black54),
                      ),
                    ],
                  ),
                  //
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        )
                      ]
                    ),
                    child: const Icon(Icons.notifications_none, color: primaryTeal),
                  )
                ],
              ),
              
              const SizedBox(height: 20),

              // Menu Dropdown Wisma / Kelas
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: softTeal, 
                  borderRadius: BorderRadius.circular(20),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<ItemType>(
                    value: selectedMenu,
                    icon: const Icon(Icons.keyboard_arrow_down, color: primaryTeal),
                    items: ItemType.values.map((type) {
                      return DropdownMenuItem(
                        value: type,
                        child: Text(
                          type == ItemType.wisma ? "Wisma" : "Kelas",
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: primaryTeal,
                          ),
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedMenu = value!;
                      });
                    },
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Header Card (Statistik)
              SizedBox(
                height: 180,
                child: Stack(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFBFD9DE),
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    Row(
                      children: [
                        Expanded(
                          flex: 5,
                          child: Stack(
                            children: [
                              Positioned(
                                left: 0,
                                bottom: -10,
                                child: SvgPicture.asset(
                                  selectedMenu == ItemType.wisma
                                      ? "lib/assets/images/header_wisma_pict.svg"
                                      : "lib/assets/images/header_kelas_pict.svg",
                                  height: 170,
                                  fit: BoxFit.contain,
                                ),
                              ),
                              Center(
                                child: Transform.translate(
                                  offset: const Offset(0, -45),
                                  child: Padding(
                                    padding: const EdgeInsets.only(left: 30),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Icon(Icons.flash_on, color: Colors.amber, size: 22),
                                        const SizedBox(height: 6),
                                        const Text(
                                          "122",
                                          style: TextStyle(
                                            fontSize: 28,
                                            fontWeight: FontWeight.bold,
                                            color: primaryTeal,
                                          ),
                                        ),
                                        Text(
                                          selectedMenu == ItemType.wisma ? "Kamar" : "Kelas",
                                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          flex: 5, 
                          child: Padding(
                            padding: const EdgeInsets.only(right: 12, top: 16, bottom: 16),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                              decoration: BoxDecoration(
                                color: const Color(0xFFE3F2F4),
                                borderRadius: BorderRadius.circular(18),
                                border: Border.all(
                                  color: primaryTeal.withValues(alpha: 0.4),
                                  width: 1.2,
                                ),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: _buildStatus(),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 25),
              const Divider(color: Colors.black12, thickness: 1),
              const SizedBox(height: 15),
              
              Text(
                selectedMenu == ItemType.wisma ? "Jenis Wisma" : "Jenis Kelas",
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: primaryTeal),
              ),
              
              const SizedBox(height: 15),
              
              Expanded(
                child: GridView.builder(
                  itemCount: filteredItems.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 15,
                    mainAxisSpacing: 15,
                    childAspectRatio: 1.1,
                  ),
                  itemBuilder: (context, index) {
                    final item = filteredItems[index];
                    return WismaCard(
                      title: item.title,
                      imagePath: item.imagePath,
                      onTap: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => DetailKelasPage(item: item)),
                        );
                        if (!mounted) return;
                        if (result == true) {
                          setState(() {
                            item.isDone = true;
                          });
                        }
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: CustomBottomNav(
        currentIndex: 0,
        onTap: (index) {
          if (index == 2) {
            Navigator.pushReplacementNamed(context, '/profil');
          } else if (index == 1) {
            Navigator.pushReplacementNamed(context, '/riwayat');
          }
        },
      ),
    );
  }

  List<Widget> _buildStatus() {
    if (selectedMenu == ItemType.wisma) {
      return const [
        StatusRow(number: "50", label: "Terisi"),
        SizedBox(height: 6),
        StatusRow(number: "40", label: "Kosong"),
        SizedBox(height: 6),
        StatusRow(number: "15", label: "Perlu Perbaikan"),
        SizedBox(height: 6),
        StatusRow(number: "17", label: "Dalam Perbaikan"),
      ];
    } else {
      return const [
        StatusRow(number: "50", label: "Digunakan"),
        SizedBox(height: 6),
        StatusRow(number: "40", label: "Kosong"),
        SizedBox(height: 6),
        StatusRow(number: "15", label: "Perlu Perbaikan"),
      ];
    }
  }
}

class StatusRow extends StatelessWidget {
  final String number;
  final String label;

  const StatusRow({
    super.key,
    required this.number,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 28, 
          child: Text(
            number,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Color(0xFF008996),
            ),
          ),
        ),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(fontSize: 14),
            softWrap: true,
          ),
        ),
      ],
    );
  }
}

class WismaCard extends StatelessWidget {
  final String title;
  final String imagePath;
  final VoidCallback onTap;
  const WismaCard({super.key, required this.title, required this.imagePath, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          image: DecorationImage(image: AssetImage(imagePath), fit: BoxFit.cover),
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            gradient: const LinearGradient(
              colors: [Colors.black54, Colors.transparent],
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
            ),
          ),
          padding: const EdgeInsets.all(10),
          alignment: Alignment.bottomLeft,
          child: Text(
            title,
            style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500),
          ),
        ),
      ),
    );
  }
}

