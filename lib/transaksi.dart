import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Transaksi extends StatefulWidget {
  final List<Map<String, dynamic>> transaksiList;

  const Transaksi({super.key, required this.transaksiList});

  @override
  _TransaksiState createState() => _TransaksiState();
}

class _TransaksiState extends State<Transaksi> {
  late List<Map<String, dynamic>> transaksiList;
  int totalHarga = 0;

  @override
  void initState() {
    super.initState();
    transaksiList = widget.transaksiList;
    _hitungTotal();
  }

  void _hitungTotal() {
    totalHarga = transaksiList.fold(0, (int sum, item) => sum + (item["subtotal"] as int));
  }

  void _ubahJumlah(int id, int newJumlah, int harga) {
    setState(() {
      final index = transaksiList.indexWhere((item) => item['produk_id'] == id);
      if (index != -1) {
        transaksiList[index]['jumlah'] = newJumlah;
        transaksiList[index]['subtotal'] = newJumlah * harga;
      }
      _hitungTotal();
    });
  }

  void _prosesPembayaran() {
    setState(() {
      transaksiList.clear(); // Mengosongkan keranjang setelah pembayaran
      totalHarga = 0; // Reset total harga
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Pembayaran berhasil')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Transaksi")),
      body: Column(
        children: [
          Expanded(
            child: transaksiList.isEmpty
                ? const Center(child: Text('Belum ada transaksi'))
                : ListView.builder(
                    itemCount: transaksiList.length,
                    itemBuilder: (context, index) {
                      final item = transaksiList[index];
                      return ListTile(
                        title: Text(item['nama_produk']),
                        subtitle: Text('Subtotal: ${item['subtotal']}'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.remove),
                              onPressed: () => _ubahJumlah(item['produk_id'], item['jumlah'] - 1, item['harga']),
                            ),
                            Text('${item['jumlah']}'),
                            IconButton(
                              icon: const Icon(Icons.add),
                              onPressed: () => _ubahJumlah(item['produk_id'], item['jumlah'] + 1, item['harga']),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Text('Total: Rp$totalHarga', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: _prosesPembayaran,
                  child: const Text("Bayar"),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
