import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';
import 'package:intl/intl.dart';

class ExportService {
  static const String baseUrl = "http://localhost:8080";

  /// Export transactions to Excel
  ///
  /// If [startDate] and [endDate] are null, exports last 30 days
  ///
  /// Parameters:
  /// - [startDate]: Start date in 'yyyy-MM-dd' format
  /// - [endDate]: End date in 'yyyy-MM-dd' format
  static Future<void> exportTransactions({
    String? startDate,
    String? endDate,
  }) async {
    try {
      // Build URL with query parameters
      var url = '$baseUrl/export/transactions/';
      var params = <String>[];

      if (startDate != null && startDate.isNotEmpty) {
        params.add('start_date=$startDate');
      }
      if (endDate != null && endDate.isNotEmpty) {
        params.add('end_date=$endDate');
      }

      if (params.isNotEmpty) {
        url += '?${params.join('&')}';
      }

      print('Export URL: $url');

      // Make request
      final response = await http
          .get(
            Uri.parse(url),
            headers: {
              'Accept':
                  'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
            },
          )
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () {
              throw Exception('Request timeout. Server tidak merespons.');
            },
          );

      print('Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        // Get downloads directory
        final directory = await _getDownloadDirectory();

        // Generate filename
        final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
        final filename = 'transactions_$timestamp.xlsx';
        final filePath = '${directory.path}/$filename';

        print('Saving to: $filePath');

        // Save file
        final file = File(filePath);
        await file.writeAsBytes(response.bodyBytes);

        print('File saved successfully');

        // Open file
        final result = await OpenFilex.open(filePath);
        print('Open file result: ${result.message}');

        if (result.type != ResultType.done) {
          throw Exception('Gagal membuka file: ${result.message}');
        }
      } else if (response.statusCode == 404) {
        throw Exception(
          'Tidak ada transaksi dalam rentang tanggal yang dipilih',
        );
      } else if (response.statusCode == 400) {
        throw Exception('Format tanggal tidak valid');
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } on SocketException {
      throw Exception(
        'Tidak dapat terhubung ke server. Periksa koneksi internet Anda.',
      );
    } catch (e) {
      print('Export error: $e');
      rethrow;
    }
  }

  /// Get appropriate download directory based on platform
  static Future<Directory> _getDownloadDirectory() async {
    if (Platform.isAndroid) {
      // For Android, try to get Downloads directory
      try {
        final directory = Directory('/storage/emulated/0/Download');
        if (await directory.exists()) {
          return directory;
        }
      } catch (e) {
        print('Failed to access Downloads directory: $e');
      }
    }

    // Fallback to application documents directory
    return await getApplicationDocumentsDirectory();
  }

  /// Check if export endpoint is available
  static Future<bool> checkExportAvailability() async {
    try {
      final url = '$baseUrl/export/transactions';
      final response = await http
          .head(Uri.parse(url))
          .timeout(const Duration(seconds: 5));
      return response.statusCode != 404;
    } catch (e) {
      return false;
    }
  }
}
