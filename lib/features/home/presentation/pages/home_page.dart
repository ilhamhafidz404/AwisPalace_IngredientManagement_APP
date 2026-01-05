import 'package:flutter/material.dart';
import 'package:ingredient_management_app/data/services/auth_service.dart';
import 'package:ingredient_management_app/features/home/data/services/home_service.dart';
import 'package:ingredient_management_app/features/home/presentation/widgets/dashboard_filter_card.dart';
import 'package:ingredient_management_app/features/home/presentation/widgets/export_card.dart';
import 'package:ingredient_management_app/features/home/presentation/widgets/export_transaction_dialog.dart';
import 'package:ingredient_management_app/features/home/presentation/widgets/low_stock_alert_dialog.dart';
import 'package:ingredient_management_app/features/home/presentation/widgets/menu_bar_chart.dart';
import 'package:ingredient_management_app/features/home/presentation/widgets/menu_sold_section.dart';
import 'package:ingredient_management_app/features/home/presentation/widgets/product_section.dart';
import 'package:ingredient_management_app/features/home/presentation/widgets/stock_used_section.dart';
import 'package:ingredient_management_app/features/ingredient/data/services/ingredient_service.dart';
import 'package:ingredient_management_app/services/export_service.dart';
import 'package:ingredient_management_app/widgets/custom_app_bar.dart';
import 'package:ingredient_management_app/widgets/custom_bottom_nav.dart';
import 'package:ingredient_management_app/widgets/custom_bottom_nav_handler.dart';
import 'package:ingredient_management_app/widgets/error_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// ======================
/// ENUM VIEW MODE
/// ======================
enum MenuViewMode { list, chart }

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

const String lowStockAlertKey = 'low_stock_alert_last_closed';
const Duration lowStockCooldown = Duration(minutes: 5);

class _HomePageState extends State<HomePage> {
  int currentIndex = 0;

  late Future<Map<String, dynamic>> dashboardFuture;

  late DateTime startDate;
  late DateTime endDate;
  late DateTime _defaultStartDate;
  late DateTime _defaultEndDate;

  bool _lowStockAlertShown = false;
  bool _isExporting = false;

  MenuViewMode menuViewMode = MenuViewMode.list;

  @override
  void initState() {
    super.initState();
    _initDefaultDate();
    _loadDashboard();
    // _checkLowStockIngredients();
  }

  /// ======================
  /// INIT DEFAULT DATE
  /// ======================
  /// ======================
  /// INIT DEFAULT DATE
  /// ======================
  void _initDefaultDate() {
    final now = DateTime.now();

    // Default: 7 hari terakhir
    _defaultEndDate = DateTime(now.year, now.month, now.day);
    _defaultStartDate = _defaultEndDate.subtract(const Duration(days: 6));

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

    _checkLowStockIngredients();
  }

  /// ======================
  /// DATE RANGE PICKER
  /// ======================
  /// ======================
  /// DATE RANGE PICKER
  /// ======================
  Future<void> _pickDateRange() async {
    final now = DateTime.now();

    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2024),
      lastDate: now,
      initialDateRange: DateTimeRange(start: startDate, end: endDate),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.blue[700]!,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
            datePickerTheme: DatePickerThemeData(
              rangeSelectionBackgroundColor: Colors.blue[700]!.withOpacity(
                0.15,
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        startDate = picked.start;
        endDate = picked.end;
        _loadDashboard();
      });
    }
  }

  void _resetFilter() {
    setState(() {
      startDate = _defaultStartDate;
      endDate = _defaultEndDate;
      _loadDashboard();
    });
  }

  bool get _isDefaultRange =>
      startDate == _defaultStartDate && endDate == _defaultEndDate;

  /// ======================
  /// LOW STOCK CHECK
  /// ======================

  Future<void> _checkLowStockIngredients() async {
    final prefs = await SharedPreferences.getInstance();

    final lastClosedMillis = prefs.getInt(lowStockAlertKey);
    if (lastClosedMillis != null) {
      final lastClosedTime = DateTime.fromMillisecondsSinceEpoch(
        lastClosedMillis,
      );

      final diff = DateTime.now().difference(lastClosedTime);

      // ⛔ Jangan tampilkan jika masih dalam cooldown 5 menit
      if (diff < lowStockCooldown) {
        return;
      }
    }

    final ingredients = await IngredientService.getIngredients();
    final lowStockItems = ingredients
        .where((i) => i.stock <= 5)
        .map((i) => i.name)
        .toList();

    if (lowStockItems.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        await showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => LowStockAlertDialog(
            items: lowStockItems,
            onClose: () async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.setInt(
                lowStockAlertKey,
                DateTime.now().millisecondsSinceEpoch,
              );
              Navigator.pop(context);
            },
          ),
        );
      });
    }
  }

  /// ======================
  /// EXPORT HANDLER
  /// ======================
  Future<void> _handleExport({String? startDate, String? endDate}) async {
    setState(() => _isExporting = true);

    try {
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
      if (mounted) setState(() => _isExporting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      /// ======================
      /// APP BAR
      /// ======================
      appBar: CustomAppBar(
        title: 'Dashboard',
        onRefresh: _loadDashboard,
        onLogout: () =>
            Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false),
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
            return ErrorPage(
              title: 'Gagal Memuat Dashboard',
              error: snapshot.error,
              onRetry: _loadDashboard,
            );
          }

          final data = snapshot.data!;
          final menus = data['menus'] as List;
          final ingredients = data['ingredients'] as List;

          return FutureBuilder<String?>(
            future: AuthService.getUserEmail(),
            builder: (context, emailSnapshot) {
              final userEmail = emailSnapshot.data;

              return SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    DashboardFilterCard(
                      startDate: startDate,
                      endDate: endDate,
                      onPickDate: _pickDateRange,
                      onReset: _isDefaultRange ? null : _resetFilter,
                    ),

                    const SizedBox(height: 24),

                    // CHECK EMAIL
                    if (userEmail == 'ilhammhafidzz@gmail.com' ||
                        userEmail == 'rizal08crb@gmail.com' ||
                        userEmail == 'fitrihandayani556677@gmail.com' ||
                        userEmail == 'firdanfauzan5@gmail.com') ...[
                      ExportCard(
                        title: 'Export Transaksi',
                        subtitle: 'Download laporan transaksi ke Excel',
                        icon: Icons.file_download_outlined,
                        iconColor: Colors.blue,
                        isLoading: _isExporting,
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (_) => ExportTransactionDialog(
                              onExport: _handleExport,
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 24),
                    ],

                    MenuSoldSection(
                      mode: menuViewMode,
                      menus: menus,
                      onChangeMode: (m) => setState(() => menuViewMode = m),
                      listView: ProductSection(menus: menus),
                      chartView: MenuBarChart(menus: menus),
                    ),

                    const SizedBox(height: 24),

                    StockUsedSection(ingredients: ingredients),
                  ],
                ),
              );
            },
          );
        },
      ),

      bottomNavigationBar: CustomBottomNav(
        selectedIndex: currentIndex,
        onItemTapped: (i) =>
            CustomBottomNavHandler.onItemTapped(context, currentIndex, i),
      ),
    );
  }
}
