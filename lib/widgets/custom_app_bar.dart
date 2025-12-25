import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget {
  final VoidCallback? onRefresh;
  final VoidCallback? onLogout;
  final List<PopupMenuEntry<String>>? extraItems;

  const CustomAppBar({
    super.key,
    this.onRefresh,
    this.onLogout,
    this.extraItems,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert, color: Colors.white),
      onSelected: (value) {
        switch (value) {
          case 'refresh':
            onRefresh?.call();
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
          const PopupMenuItem(
            value: 'refresh',
            child: Row(
              children: [
                Icon(Icons.refresh, size: 18),
                SizedBox(width: 8),
                Text("Refresh"),
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
            child: const Text("Batal"),
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
}
