import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../models/trip_model.dart';
import '../models/expense_model.dart';
import '../models/user_model.dart';
import 'balance_service.dart';

class ExportService {
  static final ExportService _instance = ExportService._internal();

  factory ExportService() {
    return _instance;
  }

  ExportService._internal();

  /// PDF rapor oluştur
  static Future<File> generateTripReportPDF(
    Trip trip,
    List<Expense> expenses,
    List<User> users,
  ) async {
    final doc = pw.Document();
    final balance = BalanceService.calculateBalance(
      expenses,
      trip.participantIds,
    );

    // Başlık ve özet
    final summary = BalanceService.getPersonSummary(expenses, users);
    final categoryExpenses = BalanceService.getCategoryExpenseSummary(expenses);
    final topSpender = BalanceService.getTopSpender(expenses);
    final mostExpensiveDay = BalanceService.getMostExpensiveDay(expenses);

    doc.addPage(
      pw.MultiPage(
        build: (context) => [
          // Başlık
          pw.Header(
            level: 0,
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  trip.name,
                  style: const pw.TextStyle(fontSize: 28, fontWeight: pw.FontWeight.bold),
                ),
                pw.SizedBox(height: 8),
                pw.Text(
                  trip.description,
                  style: const pw.TextStyle(fontSize: 12, color: PdfColors.grey700),
                ),
                pw.Divider(),
              ],
            ),
          ),

          // Seyahat Bilgileri
          pw.Heading(level: 1, text: 'Seyahat Bilgileri'),
          pw.Table(
            border: pw.TableBorder.all(),
            children: [
              pw.TableRow(
                children: [
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(8),
                    child: pw.Text('Başlama Tarihi:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(8),
                    child: pw.Text(_formatDate(trip.startDate)),
                  ),
                ],
              ),
              pw.TableRow(
                children: [
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(8),
                    child: pw.Text('Bitiş Tarihi:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(8),
                    child: pw.Text(_formatDate(trip.endDate)),
                  ),
                ],
              ),
              pw.TableRow(
                children: [
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(8),
                    child: pw.Text('Başlangıç Yeri:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(8),
                    child: pw.Text(trip.startLocation.fullLocation),
                  ),
                ],
              ),
              pw.TableRow(
                children: [
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(8),
                    child: pw.Text('Varış Yeri:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(8),
                    child: pw.Text(trip.endLocation.fullLocation),
                  ),
                ],
              ),
            ],
          ),

          pw.SizedBox(height: 20),

          // Özet İstatistikler
          pw.Heading(level: 1, text: 'Özet İstatistikler'),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
            children: [
              _buildStatCard('Toplam Harcama', '₺${expenses.fold(0.0, (sum, e) => sum + e.amount).toStringAsFixed(2)}'),
              _buildStatCard('Katılımcı Sayısı', trip.participantIds.length.toString()),
              _buildStatCard('Harcama Sayısı', expenses.length.toString()),
            ],
          ),

          pw.SizedBox(height: 20),

          // Kişi Bazında Özet
          pw.Heading(level: 1, text: 'Kişi Bazında Özet'),
          pw.Table(
            border: pw.TableBorder.all(),
            children: [
              pw.TableRow(
                children: [
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(8),
                    child: pw.Text('Ad Soyad', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(8),
                    child: pw.Text('Ödenmiş', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(8),
                    child: pw.Text('Payı', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(8),
                    child: pw.Text('Bakiye', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                  ),
                ],
              ),
              ...summary.values.map((person) {
                final user = users.firstWhere((u) => u.id == person.userId);
                return pw.TableRow(
                  children: [
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(8),
                      child: pw.Text(person.userName),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(8),
                      child: pw.Text('₺${person.totalPaid.toStringAsFixed(2)}'),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(8),
                      child: pw.Text('₺${person.totalShare.toStringAsFixed(2)}'),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(8),
                      child: pw.Text(person.balanceStatus),
                    ),
                  ],
                );
              }).toList(),
            ],
          ),

          pw.SizedBox(height: 20),

          // Ödeme İşlemleri
          pw.Heading(level: 1, text: 'Ödeme İşlemleri'),
          ...balance.transactions.map((transaction) {
            final fromUser = users.firstWhere((u) => u.id == transaction.from);
            final toUser = users.firstWhere((u) => u.id == transaction.to);
            return pw.Paragraph(
              text:
                  '${fromUser.fullName}, ${toUser.fullName} e ₺${transaction.amount.toStringAsFixed(2)} ödeyecek',
            );
          }).toList(),

          pw.SizedBox(height: 20),

          // Ödeme Detayları (En yüksek alacaklı)
          if (topSpender != null)
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Heading(level: 2, text: 'Ödeme Bilgileri'),
                pw.SizedBox(height: 10),
                pw.Text(
                  'Lütfen ödemenizi aşağıdaki IBAN\'a yapınız:',
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                ),
                pw.SizedBox(height: 5),
                ...summary.values
                    .where((p) => p.isCreditor)
                    .map((person) {
                  final user = users.firstWhere((u) => u.id == person.userId);
                  return pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('${user.fullName}'),
                      pw.Text('Banka: ${user.bankName}'),
                      pw.Text('IBAN: ${user.iban}'),
                      pw.Text('Alacak: ₺${person.balance.toStringAsFixed(2)}'),
                      pw.SizedBox(height: 10),
                    ],
                  );
                }).toList(),
              ],
            ),

          pw.SizedBox(height: 20),

          // Kategori Bazında Harcama
          pw.Heading(level: 1, text: 'Kategori Bazında Harcama'),
          pw.Table(
            border: pw.TableBorder.all(),
            children: [
              pw.TableRow(
                children: [
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(8),
                    child: pw.Text('Kategori', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(8),
                    child: pw.Text('Tutar', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(8),
                    child: pw.Text('Yüzde', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                  ),
                ],
              ),
              ...categoryExpenses.entries.map((entry) {
                final total = expenses.fold(0.0, (sum, e) => sum + e.amount);
                final percentage = (entry.value / total * 100).toStringAsFixed(2);
                return pw.TableRow(
                  children: [
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(8),
                      child: pw.Text(entry.key),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(8),
                      child: pw.Text('₺${entry.value.toStringAsFixed(2)}'),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(8),
                      child: pw.Text('%$percentage'),
                    ),
                  ],
                );
              }).toList(),
            ],
          ),

          pw.SizedBox(height: 20),

          // Detaylı Harcama Listesi
          pw.Heading(level: 1, text: 'Detaylı Harcama Listesi'),
          pw.Table(
            border: pw.TableBorder.all(),
            children: [
              pw.TableRow(
                children: [
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(8),
                    child: pw.Text('Tarih', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(8),
                    child: pw.Text('Kategori', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(8),
                    child: pw.Text('Açıklama', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(8),
                    child: pw.Text('Ödedi', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(8),
                    child: pw.Text('Tutar', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                  ),
                ],
              ),
              ...expenses.map((expense) {
                final paidBy = users.firstWhere((u) => u.id == expense.paidBy);
                return pw.TableRow(
                  children: [
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(8),
                      child: pw.Text(_formatDate(expense.date)),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(8),
                      child: pw.Text(expense.category),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(8),
                      child: pw.Text(expense.description),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(8),
                      child: pw.Text(paidBy.fullName),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(8),
                      child: pw.Text('₺${expense.amount.toStringAsFixed(2)}'),
                    ),
                  ],
                );
              }).toList(),
            ],
          ),
        ],
      ),
    );

    // PDF'i dosya sistemine kaydet
    final appDir = Directory.systemTemp;
    final fileName = '${trip.name}_Rapor_${DateTime.now().millisecondsSinceEpoch}.pdf';
    final file = File('${appDir.path}/$fileName');

    await file.writeAsBytes(await doc.save());
    return file;
  }

  static pw.Widget _buildStatCard(String title, String value) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
      ),
      child: pw.Column(
        children: [
          pw.Text(title, style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 8),
          pw.Text(value, style: const pw.TextStyle(fontSize: 16)),
        ],
      ),
    );
  }

  static String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  /// Seyahat raporunu yazdır
  static Future<void> printReport(File pdfFile) async {
    try {
      await Printing.layoutPdf(
        onPageFormat: () => PdfPageFormat.a4,
        name: pdfFile.path,
        format: PdfPageFormat.a4,
      );
    } catch (e) {
      print('Print Error: $e');
    }
  }
}
