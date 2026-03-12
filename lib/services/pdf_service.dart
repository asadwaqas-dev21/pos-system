import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';

import 'package:pos_app/models/order_model.dart';
import 'package:hive_flutter/hive_flutter.dart';

class PdfService {
  static Future<void> printReceipt(OrderModel order) async {
    final settingsBox = Hive.box('settings');
    final storeName = settingsBox.get('storeName', defaultValue: 'Super Store');
    final storeAddress = settingsBox.get('storeAddress', defaultValue: '123 Main Street, City');
    final storePhone = settingsBox.get('storePhone', defaultValue: '+92 300 1234567');

    final doc = pw.Document();

    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.roll80, // Thermal 80mm format
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.center,
            mainAxisSize: pw.MainAxisSize.min,
            children: [
              pw.SizedBox(height: 10),
              pw.Text(
                storeName,
                style: pw.TextStyle(
                  fontSize: 24,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              if (storeAddress.isNotEmpty) pw.Text(storeAddress),
              if (storePhone.isNotEmpty) pw.Text('Tel: $storePhone'),
              pw.Text(
                'Receipt: ${order.orderId}',
                style: const pw.TextStyle(fontSize: 12),
              ),
              if (order.customerName != null && order.customerName!.isNotEmpty)
                pw.Text(
                  'Customer: ${order.customerName}',
                  style: const pw.TextStyle(fontSize: 12),
                ),
              pw.Text(
                'Date: ${DateFormat('dd-MM-yyyy HH:mm:ss').format(order.date)}',
                style: const pw.TextStyle(fontSize: 12),
              ),

              pw.Divider(thickness: 1, height: 20),
              // Headers
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Expanded(
                    flex: 3,
                    child: pw.Text(
                      'Item',
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                    ),
                  ),
                  pw.Expanded(
                    flex: 1,
                    child: pw.Text(
                      'Qty',
                      textAlign: pw.TextAlign.center,
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                    ),
                  ),
                  pw.Expanded(
                    flex: 2,
                    child: pw.Text(
                      'Total',
                      textAlign: pw.TextAlign.right,
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                    ),
                  ),
                ],
              ),
              pw.SizedBox(height: 5),
              // Items
              ...order.items.map((item) {
                return pw.Padding(
                  padding: const pw.EdgeInsets.symmetric(vertical: 2),
                  child: pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Expanded(
                        flex: 3,
                        child: pw.Text(item.product.name, maxLines: 2),
                      ),
                      pw.Expanded(
                        flex: 1,
                        child: pw.Text(
                          '${item.quantity}',
                          textAlign: pw.TextAlign.center,
                        ),
                      ),
                      pw.Expanded(
                        flex: 2,
                        child: pw.Text(
                          'PKR ${item.totalPrice.toStringAsFixed(2)}',
                          textAlign: pw.TextAlign.right,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),

              pw.Divider(thickness: 1, height: 20),
              // Totals
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('Subtotal:'),
                  pw.Text('PKR ${order.subtotal.toStringAsFixed(2)}'),
                ],
              ),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('GST:'),
                  pw.Text('PKR ${order.tax.toStringAsFixed(2)}'),
                ],
              ),
              pw.SizedBox(height: 5),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    'TOTAL:',
                    style: pw.TextStyle(
                      fontWeight: pw.FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  pw.Text(
                    'PKR ${order.total.toStringAsFixed(2)}',
                    style: pw.TextStyle(
                      fontWeight: pw.FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),

              pw.Divider(thickness: 1, height: 20),
              pw.Text(
                'Thank you so much for shopping with us!',
                textAlign: pw.TextAlign.center,
              ),
              pw.BarcodeWidget(
                data: order.orderId,
                barcode: pw.Barcode.code128(),
                width: 150,
                height: 50,
                margin: const pw.EdgeInsets.only(top: 15),
              ),
              pw.SizedBox(height: 20),
            ],
          );
        },
      ),
    );

    // This will open a print dialog natively on Windows and Android
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => doc.save(),
      name: 'Receipt_${order.orderId}',
    );
  }
}
