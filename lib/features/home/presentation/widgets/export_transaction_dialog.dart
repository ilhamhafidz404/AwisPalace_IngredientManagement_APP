import 'package:flutter/material.dart';
import 'package:ingredient_management_app/features/home/presentation/widgets/export_date_field.dart';
import 'package:intl/intl.dart';

class ExportTransactionDialog extends StatefulWidget {
  final Future<void> Function({String? startDate, String? endDate}) onExport;

  const ExportTransactionDialog({super.key, required this.onExport});

  @override
  State<ExportTransactionDialog> createState() =>
      _ExportTransactionDialogState();
}

class _ExportTransactionDialogState extends State<ExportTransactionDialog> {
  DateTime? _startDate;
  DateTime? _endDate;

  Future<DateTime?> _selectDate(DateTime? initialDate) {
    return showDatePicker(
      context: context,
      initialDate: initialDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),

      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.blue.shade700,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
            datePickerTheme: DatePickerThemeData(
              todayForegroundColor: WidgetStateProperty.all(Colors.black),
              todayBorder: const BorderSide(color: Colors.blue, width: 1),
            ),
          ),
          child: child!,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
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
          const Text('Pilih rentang tanggal untuk export transaksi ke Excel.'),
          const SizedBox(height: 20),

          ExportDateField(
            label: 'Tanggal Mulai',
            date: _startDate,
            onTap: () async {
              final picked = await _selectDate(_startDate);
              if (picked != null) {
                setState(() => _startDate = picked);
              }
            },
          ),

          const SizedBox(height: 15),

          ExportDateField(
            label: 'Tanggal Akhir',
            date: _endDate,
            onTap: () async {
              final picked = await _selectDate(_endDate);
              if (picked != null) {
                setState(() => _endDate = picked);
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
          child: const Text('Batal', style: TextStyle(color: Colors.black)),
        ),
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue[700],
            foregroundColor: Colors.white,
          ),
          icon: const Icon(Icons.download),
          label: const Text('Export'),
          onPressed: () async {
            Navigator.pop(context);

            await widget.onExport(
              startDate: _startDate != null
                  ? DateFormat('yyyy-MM-dd').format(_startDate!)
                  : null,
              endDate: _endDate != null
                  ? DateFormat('yyyy-MM-dd').format(_endDate!)
                  : null,
            );
          },
        ),
      ],
    );
  }
}
