import 'package:flutter/material.dart';
import '../widgets/custom_bottom_nav.dart';

class HitungPage extends StatefulWidget {
  const HitungPage({super.key});

  @override
  State<HitungPage> createState() => _HitungPageState();
}

class _HitungPageState extends State<HitungPage> {
  int currentIndex = 1;

  List<Map<String, dynamic>> menuList = [
    {
      "nama": "Nasi Goreng",
      "harga": 10000,
      "img": "assets/img/nasigoreng.png",
      "porsi": 5,
    },
    {
      "nama": "Karedok",
      "harga": 8000,
      "img": "assets/img/nasigoreng.png",
      "porsi": 5,
    },
    {
      "nama": "Kukubima Susu",
      "harga": 5000,
      "img": "assets/img/nasigoreng.png",
      "porsi": 5,
    },
  ];

  late List<TextEditingController> controllers;

  @override
  void initState() {
    super.initState();
    controllers = [
      for (var item in menuList)
        TextEditingController(text: item["porsi"].toString()),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF7F8FA),

      appBar: AppBar(
        title: const Text(
          "Hitung",
          style: TextStyle(
            fontSize: 22,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xff28C8E6),
      ),

      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          for (int i = 0; i < menuList.length; i++) ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// --- CARD MENU MAKANAN ---
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    margin: const EdgeInsets.only(bottom: 15),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.12),
                          blurRadius: 3,
                          spreadRadius: 1,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.asset(
                            menuList[i]["img"],
                            width: 55,
                            height: 55,
                            fit: BoxFit.cover,
                          ),
                        ),

                        const SizedBox(width: 10),

                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              menuList[i]["nama"],
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              "Harga : Rp. ${menuList[i]["harga"]}",
                              style: const TextStyle(
                                fontSize: 13,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),

                        const Spacer(),
                        const Icon(Icons.keyboard_arrow_down_rounded, size: 27),
                      ],
                    ),
                  ),
                ),

                const SizedBox(width: 10),

                /// --- INPUT PORSI ---
                Container(
                  margin: const EdgeInsets.only(top: 4),
                  width: 68,
                  height: 74,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.10),
                        blurRadius: 3,
                        spreadRadius: 1,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment
                        .center, // <-- ini bikin rata tengah horizontal
                    children: [
                      SizedBox(
                        height: 30,
                        child: TextField(
                          controller: controllers[i],
                          textAlign: TextAlign.center,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                          ),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                          onChanged: (v) => setState(
                            () => menuList[i]["porsi"] = int.tryParse(v) ?? 0,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),

                      /// TEKS PORSI RATA TENGAH
                      const Text(
                        "Porsi",
                        textAlign: TextAlign.center, // <-- tambah ini juga
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],

          const SizedBox(height: 12),

          /// --- BUTTON TAMBAH MENU ---
          SizedBox(
            width: double.infinity,
            height: 55,
            child: ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.add, size: 26, color: Colors.white),
              label: const Text(
                "Menu Lainnya",
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xff28C8E6),
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
        ],
      ),

      /// --- BOTTOM NAV ---
      bottomNavigationBar: CustomBottomNav(
        selectedIndex: currentIndex,
        onItemTapped: (index) {
          setState(() => currentIndex = index);

          if (index == 0) Navigator.pushNamed(context, '/beranda');
          if (index == 1) return;
          if (index == 2) Navigator.pushNamed(context, '/kelola');
          if (index == 3) Navigator.pushNamed(context, '/menu');
          if (index == 4) Navigator.pushNamed(context, '/profile');
        },
      ),
    );
  }
}
