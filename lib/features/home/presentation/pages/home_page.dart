// lib/features/home/presentation/pages/home_page.dart

import 'package:flutter/material.dart';
import 'package:ingredient_management_app/features/home/data/services/home_service.dart';
import 'package:ingredient_management_app/features/home/presentation/widgets/export_card.dart';
import 'package:ingredient_management_app/features/home/presentation/widgets/ingredient_section.dart';
import 'package:ingredient_management_app/features/home/presentation/widgets/product_section.dart';
import 'package:ingredient_management_app/features/home/presentation/widgets/menu_bar_chart.dart';
import 'package:ingredient_management_app/features/ingredient/data/services/ingredient_service.dart';
import 'package:ingredient_management_app/services/export_service.dart';
import 'package:ingredient_management_app/utils/range_date_indonesian_style.dart';
import 'package:ingredient_management_app/widgets/custom_app_bar.dart';
import 'package:ingredient_management_app/widgets/custom_bottom_nav.dart';
import 'package:ingredient_management_app/widgets/custom_bottom_nav_handler.dart';
import 'package:intl/intl.dart';

/// ======================
/// ENUM VIEW MODE
/// ======================
enum MenuViewMode { list, chart }

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int currentIndex = 0;

  late Future<Map<String, dynamic>> dashboardFuture;

  late DateTime startDate;
  late DateTime endDate;

  late DateTime _defaultStartDate;
  late DateTime _defaultEndDate;

  bool _lowStockAlertShown = false;

  /// MODE LIST / CHART
  MenuViewMode menuViewMode = MenuViewMode.list;

  @override
  void initState() {
    super.initState();
    _initDefaultDate();
    _loadDashboard();
    _checkLowStockIngredients();
  }

  /// ======================
  /// INIT DEFAULT (MINGGU INI)
  /// ======================
  void _initDefaultDate() {
    final now = DateTime.now();
    final weekday = now.weekday; // Senin = 1

    _defaultStartDate = DateTime(now.year, now.month, now.day - (weekday - 1));
    _defaultEndDate = _defaultStartDate.add(const Duration(days: 6));

    startDate = _defaultStartDate;
    endDate = _defaultEndDate;
  }

  /// ======================
  /// LOAD DASHBOARD
  /// ======================
  void _loadDashboard() {
    _lowStockAlertShown = false;
    dashboardFuture = HomeService.getDashboard(
      startDate: startDate,
      endDate: endDate,
    );
  }

  /// ======================
  /// DATE RANGE PICKER
  /// ======================
  Future<void> _pickDateRange() async {
    final now = DateTime.now();
    final lastAllowedDate = DateTime(now.year, now.month, now.day, 23, 59, 59);

    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2024),
      lastDate: lastAllowedDate,
      initialDateRange: DateTimeRange(
        start: startDate,
        end: endDate.isAfter(lastAllowedDate) ? lastAllowedDate : endDate,
      ),
    );

    if (picked != null) {
      setState(() {
        startDate = picked.start;
        endDate = picked.end;
        _loadDashboard();
      });
    }
  }

  /// ======================
  /// RESET FILTER
  /// ======================
  void _resetFilter() {
    setState(() {
      startDate = _defaultStartDate;
      endDate = _defaultEndDate;
      _loadDashboard();
    });
  }

  bool get _isDefaultRange =>
      startDate == _defaultStartDate && endDate == _defaultEndDate;

  bool _isExporting = false;

  DateTime? _exportStartDate;
  DateTime? _exportEndDate;

  Future<void> _checkLowStockIngredients() async {
    if (_lowStockAlertShown) return;

    try {
      final ingredients = await IngredientService.getIngredients();

      final lowStockItems = ingredients
          .where((i) => (i.stock ?? 0) <= 5)
          .map((i) => i.name)
          .toList();

      if (lowStockItems.isNotEmpty) {
        _lowStockAlertShown = true;

        final message = '${lowStockItems.join(', ')} sudah mulai habis';

        WidgetsBinding.instance.addPostFrameCallback((_) {
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: Row(
                  children: const [
                    Icon(Icons.warning_amber_rounded, color: Colors.orange),
                    SizedBox(width: 8),
                    Text('Peringatan Stok'),
                  ],
                ),
                content: Text(message, style: const TextStyle(fontSize: 14)),
                actions: [
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Mengerti'),
                  ),
                ],
              );
            },
          );
        });
      }
    } catch (e) {
      // Optional: log error
      debugPrint('Gagal cek stok ingredient: $e');
    }
  }

  // =========================
  // EXPORT DIALOG
  // =========================
  Future<void> _showExportDialog() async {
    _exportStartDate = null;
    _exportEndDate = null;

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Row(
                children: [
                  Icon(Icons.file_download, color: Colors.blue[700]),
                  const SizedBox(width: 8),
                  const Text('Export Transaksi'),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Pilih rentang tanggal untuk export transaksi ke Excel.',
                  ),
                  const SizedBox(height: 20),

                  _buildDateField(
                    label: 'Tanggal Mulai',
                    date: _exportStartDate,
                    onTap: () async {
                      final picked = await _selectDate(_exportStartDate);
                      if (picked != null) {
                        setDialogState(() {
                          _exportStartDate = picked;
                        });
                      }
                    },
                  ),

                  const SizedBox(height: 15),

                  _buildDateField(
                    label: 'Tanggal Akhir',
                    date: _exportEndDate,
                    onTap: () async {
                      final picked = await _selectDate(_exportEndDate);
                      if (picked != null) {
                        setDialogState(() {
                          _exportEndDate = picked;
                        });
                      }
                    },
                  ),

                  const SizedBox(height: 10),
                  Text(
                    'Kosongkan untuk export 30 hari terakhir',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Batal'),
                ),
                ElevatedButton.icon(
                  icon: const Icon(Icons.download),
                  label: const Text('Export'),
                  onPressed: () {
                    Navigator.pop(context);
                    _exportTransactions();
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  // =========================
  // DATE PICKER
  // =========================
  Future<DateTime?> _selectDate(DateTime? initialDate) {
    return showDatePicker(
      context: context,
      initialDate: initialDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
  }

  // =========================
  // DATE FIELD UI
  // =========================
  Widget _buildDateField({
    required String label,
    required DateTime? date,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
                const SizedBox(height: 4),
                Text(
                  date != null
                      ? DateFormat('dd MMMM yyyy').format(date)
                      : 'Pilih tanggal',
                  style: TextStyle(
                    fontSize: 14,
                    color: date != null ? Colors.black87 : Colors.grey[400],
                  ),
                ),
              ],
            ),
            Icon(Icons.calendar_today, color: Colors.blue[700]),
          ],
        ),
      ),
    );
  }

  // =========================
  // EXPORT EXECUTION
  // =========================
  Future<void> _exportTransactions() async {
    setState(() => _isExporting = true);

    try {
      final startDate = _exportStartDate != null
          ? DateFormat('yyyy-MM-dd').format(_exportStartDate!)
          : null;

      final endDate = _exportEndDate != null
          ? DateFormat('yyyy-MM-dd').format(_exportEndDate!)
          : null;

      await ExportService.exportTransactions(
        startDate: startDate,
        endDate: endDate,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Export berhasil'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Export gagal: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isExporting = false);
      }
    }
  }

  void _showLowStockAlert(String message) {
    if (_lowStockAlertShown) return;

    _lowStockAlertShown = true;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Row(
              children: const [
                Icon(Icons.warning_amber_rounded, color: Colors.orange),
                SizedBox(width: 8),
                Text('Peringatan Stok'),
              ],
            ),
            content: Text(message, style: const TextStyle(fontSize: 14)),
            actions: [
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Mengerti'),
              ),
            ],
          );
        },
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      /// ======================
      /// APP BAR
      /// ======================
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: const Color(0xFF00B3E6),
        elevation: 0,
        title: const Text(
          "Dashboard",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          CustomAppBar(
            onRefresh: _loadDashboard,
            onLogout: () {
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/login',
                (route) => false,
              );
            },
          ),
        ],
      ),

      /// ======================
      /// BODY
      /// ======================
      body: FutureBuilder<Map<String, dynamic>>(
        future: dashboardFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 60, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    "Gagal memuat data\n${snapshot.error}",
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadDashboard,
                    child: const Text("Coba Lagi"),
                  ),
                ],
              ),
            );
          }

          final data = snapshot.data!;
          final menus = (data['menus'] ?? []) as List;
          final ingredients = (data['ingredients'] ?? []) as List;

          final message = data['message']?.toString() ?? '';

          if (message.contains('sudah mulai habis')) {
            _showLowStockAlert(message);
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// ======================
                /// CARD FILTER
                /// ======================
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF00B3E6), Color(0xFF0088CC)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text(
                              "Transaksi",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              FormatDateRangeIndonesianStyle(
                                startDate,
                                endDate,
                              ),
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),

                      Row(
                        children: [
                          TextButton.icon(
                            onPressed: _pickDateRange,
                            icon: const Icon(Icons.filter_alt, size: 18),
                            label: const Text("Filter"),
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.white,
                            ),
                          ),
                          IconButton(
                            onPressed: _isDefaultRange ? null : _resetFilter,
                            icon: const Icon(
                              Icons.refresh,
                              size: 18,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                ExportCard(
                  icon: Icons.file_download_outlined,
                  iconColor: Colors.blue[700]!,
                  title: 'Export Transaksi',
                  subtitle: 'Download laporan transaksi ke Excel',
                  onTap: _showExportDialog,
                  isLoading: _isExporting,
                ),

                const SizedBox(height: 24),

                /// ======================
                /// MENU TERJUAL + TOGGLE
                /// ======================
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Menu yang Terjual",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    ToggleButtons(
                      isSelected: [
                        menuViewMode == MenuViewMode.list,
                        menuViewMode == MenuViewMode.chart,
                      ],
                      onPressed: (index) {
                        setState(() {
                          menuViewMode = index == 0
                              ? MenuViewMode.list
                              : MenuViewMode.chart;
                        });
                      },
                      borderRadius: BorderRadius.circular(8),
                      children: const [
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 12),
                          child: Icon(Icons.list),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 12),
                          child: Icon(Icons.bar_chart),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                menus.isEmpty
                    ? const Center(
                        child: Padding(
                          padding: EdgeInsets.all(32),
                          child: Text(
                            "Belum ada menu yang terjual",
                            style: TextStyle(color: Colors.grey),
                          ),
                        ),
                      )
                    : menuViewMode == MenuViewMode.list
                    ? ProductSection(menus: menus)
                    : MenuBarChart(menus: menus),

                const SizedBox(height: 32),

                /// ======================
                /// STOK DIGUNAKAN
                /// ======================
                const Text(
                  "Stok yang digunakan",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),

                ingredients.isEmpty
                    ? const Center(
                        child: Padding(
                          padding: EdgeInsets.all(32),
                          child: Text(
                            "Belum ada stok yang digunakan",
                            style: TextStyle(color: Colors.grey),
                          ),
                        ),
                      )
                    : IngredientSection(ingredients: ingredients),
              ],
            ),
          );
        },
      ),

      /// ======================
      /// BOTTOM NAV
      /// ======================
      bottomNavigationBar: CustomBottomNav(
        selectedIndex: currentIndex,
        onItemTapped: (i) =>
            CustomBottomNavHandler.onItemTapped(context, currentIndex, i),
      ),
    );
  }
}
