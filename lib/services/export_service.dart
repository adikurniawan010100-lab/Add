import 'dart:io';
import 'package:csv/csv.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:permission_handler/permission_handler.dart';
import '../models/transaction_model.dart';

class ExportService {
  static Future<String?> _getDownloadPath() async {
    Directory? dir;
    try {
      if (Platform.isAndroid) {
        // Gunakan external storage directory (terdapat di /storage/emulated/0/)
        dir = await getExternalStorageDirectory();
        if (dir == null) {
          dir = await getApplicationDocumentsDirectory();
        }
      } else {
        dir = await getApplicationDocumentsDirectory();
      }
      if (!await dir.exists()) {
        await dir.create(recursive: true);
      }
    } catch (e) {
      dir = await getApplicationDocumentsDirectory();
    }
    return dir.path;
  }

  static Future<PermissionStatus> _requestPermission() async {
    if (Platform.isAndroid) {
      final status = await Permission.storage.request();
      if (status.isGranted) return status;

      // Untuk Android 11+ (API 30+), coba manageExternalStorage
      final manageStatus = await Permission.manageExternalStorage.request();
      return manageStatus;
    }
    return PermissionStatus.granted;
  }

  static Future<File?> exportToCsv(List<TransactionModel> transactions, {void Function(String?)? onResult}) async {
    final status = await _requestPermission();
    if (!status.isGranted) {
      onResult?.call("Permission ditolak");
      return null;
    }

    final path = await _getDownloadPath();
    if (path == null) {
      onResult?.call("Gagal mendapatkan path penyimpanan");
      return null;
    }

    final csvRows = [
      ['Tipe', 'Jumlah', 'Kategori', 'Deskripsi', 'Tanggal'],
      ...transactions.map((tx) => [
        tx.type == 'income' ? 'Pemasukan' : 'Pengeluaran',
        tx.amount.toStringAsFixed(0),
        tx.category,
        tx.description,
        DateFormat.yMMMd('id_ID').format(tx.date),
      ])
    ];

    final csvData = const ListToCsvConverter().convert(csvRows);
    final file = File('$path/kasku_transactions.csv');
    await file.writeAsString(csvData);
    onResult?.call("CSV tersimpan di ${file.path}");
    return file;
  }

  static Future<File?> exportToPdf(List<TransactionModel> transactions, {void Function(String?)? onResult}) async {
    final status = await _requestPermission();
    if (!status.isGranted) {
      onResult?.call("Permission ditolak");
      return null;
    }

    final pdf = pw.Document();
    final formatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp', decimalDigits: 0);

    pdf.addPage(
      pw.Page(
        build: (context) => pw.Column(
          children: transactions.map((tx) => pw.Container(
            margin: const pw.EdgeInsets.symmetric(vertical: 4),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(DateFormat.yMMMd('id_ID').format(tx.date), style: pw.TextStyle(fontSize: 10)),
                pw.Text("${tx.type == 'income' ? 'Pemasukan' : 'Pengeluaran'} | ${tx.category}", style: pw.TextStyle(fontSize: 10)),
                pw.Text(formatter.format(tx.amount), style: pw.TextStyle(fontSize: 10)),
              ],
            ),
          )).toList(),
        ),
      ),
    );

    final path = await _getDownloadPath();
    if (path == null) {
      onResult?.call("Gagal mendapatkan path penyimpanan");
      return null;
    }

    final file = File('$path/kasku_report.pdf');
    await file.writeAsBytes(await pdf.save());
    onResult?.call("PDF tersimpan di ${file.path}");
    return file;
  }
}
