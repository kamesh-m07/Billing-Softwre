import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:permission_handler/permission_handler.dart';
import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';
import 'package:printing/printing.dart';

class BillPdfPreviewScreen extends StatelessWidget {
  final List<Map<String, dynamic>> items;
  final int total;

  const BillPdfPreviewScreen({
    super.key,
    required this.items,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Bill PDF Preview"),
        actions: [
          IconButton(
            icon: const Icon(Icons.print),

          onPressed: () async {
  await Permission.bluetooth.request();
  await Permission.bluetoothConnect.request();
  await Permission.bluetoothScan.request();

  try {
    final List<BluetoothInfo> devices =
        await PrintBluetoothThermal.pairedBluetooths;

    if (devices.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("No paired Bluetooth printers found"),
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Select Printer"),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: devices.length,
              itemBuilder: (context, index) {
                final device = devices[index];

                return ListTile(
                  title: Text(device.name),
                  subtitle: Text(device.macAdress),
                  onTap: () async {
                    Navigator.pop(context);

                    bool connected =
                        await PrintBluetoothThermal.connect(
                      macPrinterAddress: device.macAdress,
                    );

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          connected
                              ? "Connected to ${device.name}"
                              : "Connection Failed",
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        );
      },
    );

              } catch (e) {
                showDialog(
                  context: context,
                  builder:
                      (context) => AlertDialog(
                        title: const Text("Error"),
                        content: Text(e.toString()),
                      ),
                );
              }
            },
          ),
        ],
      ),
      body: PdfPreview(build: (format) => _generatePdf()),
    );
  }

  Future<Uint8List> _generatePdf() async {
    final pdf = pw.Document();

    final tableHeaders = [
      'Description',
      'Quantity',
      'Unit Price',
      'Line Total',
    ];

    final tableData =
        items.map((item) {
          return [
            item['name'],
            item['quantity'].toString(),
            "₹${item['price']}",
            "₹${item['total']}",
          ];
        }).toList();

    pdf.addPage(
      pw.MultiPage(
        build:
            (context) => [
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        "Space Restaurant",
                        style: pw.TextStyle(
                          fontSize: 22,
                          color: PdfColors.blue,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      // pw.Text("Space Restaurant", style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
                      pw.Text("Near A1 Chips"),
                      pw.Text(
                        "Anupparpalayam Puthur,Tirupur,Tamil Nadu 641652",
                      ),
                      pw.Text("91+7092180504, Web Address, etc."),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.SizedBox(height: 16),
                      pw.Text(
                        "DATE: ${DateTime.now().toLocal().toString().split(' ')[0]}",
                      ),
                      pw.Text("INVOICE #: #001"),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 16),
              pw.Divider(),
              pw.SizedBox(height: 8),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        "BILL TO",
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                      ),
                      // pw.Text("Name: Customer Name"),
                      // pw.Text("Address: Customer Address"),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [pw.Text("Table #: 5"), pw.Text("Server #: 2")],
                  ),
                ],
              ),
              pw.SizedBox(height: 16),
              pw.Table.fromTextArray(
                headers: tableHeaders,
                headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                headerDecoration: pw.BoxDecoration(color: PdfColors.blue100),
                data: tableData,
                cellAlignment: pw.Alignment.centerLeft,
                border: pw.TableBorder.all(color: PdfColors.grey),
                columnWidths: {
                  0: const pw.FlexColumnWidth(3),
                  1: const pw.FlexColumnWidth(1),
                  2: const pw.FlexColumnWidth(2),
                  3: const pw.FlexColumnWidth(2),
                },
              ),
              pw.SizedBox(height: 20),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.end,
                children: [
                  pw.Container(
                    width: 200,
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        _buildAmountRow("SUBTOTAL", "₹$total"),
                        _buildAmountRow("DISCOUNT", "₹0"),
                        pw.Divider(),
                        _buildAmountRow("TOTAL", "₹$total", bold: true),
                      ],
                    ),
                  ),
                ],
              ),
              pw.SizedBox(height: 20),

              pw.SizedBox(height: 20),
              pw.Center(
                child: pw.Text(
                  "THANK YOU FOR COMING!",
                  style: pw.TextStyle(
                    fontStyle: pw.FontStyle.italic,
                    color: PdfColors.grey,
                  ),
                ),
              ),
            ],
      ),
    );

    return Uint8List.fromList(await pdf.save());
  }

  pw.Widget _buildAmountRow(String label, String value, {bool bold = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 2),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            label,
            style: pw.TextStyle(
              fontSize: 12,
              fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
            ),
          ),
          pw.Text(
            value,
            style: pw.TextStyle(
              fontSize: 12,
              fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
