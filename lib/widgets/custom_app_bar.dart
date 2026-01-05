import 'package:flutter/material.dart';
import 'package:ingredient_management_app/pages/about_page.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final VoidCallback? onRefresh;
  final VoidCallback? onLogout;
  final List<PopupMenuEntry<String>>? extraItems;

  const CustomAppBar({
    super.key,
    required this.title,
    this.onRefresh,
    this.onLogout,
    this.extraItems,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF00B3E6), Color(0xFF0088CC)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onSelected: (value) {
              switch (value) {
                case 'refresh':
                  onRefresh?.call();
                  break;
                case 'about':
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const AboutPage()),
                  );
                  break;
                case 'logout':
                  _confirmLogout(context);
                  break;
                default:
                  break;
              }
            },
            itemBuilder: (context) => [
              if (onRefresh != null)
                // const PopupMenuItem(
                //   value: 'refresh',
                //   child: Row(
                //     children: [
                //       Icon(Icons.refresh, size: 18),
                //       SizedBox(width: 8),
                //       Text("Refresh"),
                //     ],
                //   ),
                // ),
                const PopupMenuItem(
                  value: 'about',
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        size: 18,
                        color: Color(0xFF00B3E6),
                      ),
                      SizedBox(width: 8),
                      Text("Tentang Aplikasi"),
                    ],
                  ),
                ),

              if (extraItems != null) ...extraItems!,

              if (onLogout != null) const PopupMenuDivider(),

              if (onLogout != null)
                const PopupMenuItem(
                  value: 'logout',
                  child: Row(
                    children: [
                      Icon(Icons.logout, size: 18, color: Colors.red),
                      SizedBox(width: 8),
                      Text("Logout", style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Logout"),
        content: const Text("Yakin ingin keluar dari aplikasi?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Batal", style: TextStyle(color: Colors.black)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              onLogout?.call();
            },
            child: const Text("Logout", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
