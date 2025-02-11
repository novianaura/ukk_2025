import 'package:flutter/material.dart';

class PenjualanPage extends StatelessWidget {
  final List<Map<String, dynamic>> transaksiItems;

  const PenjualanPage({Key? key, required this.transaksiItems}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Halaman Penjualan')),
      body: ListView.builder(
        itemCount: transaksiItems.length,
        itemBuilder: (context, index) {
          final product = transaksiItems[index];
          final price = product['price'] ?? 0;
          final quantity = product['quantity'] ?? 1;
          final subtotal = price * quantity;

          return Card(
            margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${product['name']} (${quantity}x)',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  Text('Rp $subtotal', style: TextStyle(fontSize: 16)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
