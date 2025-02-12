import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RiwayatPage extends StatefulWidget {
  const RiwayatPage({Key? key, required List<Map<String, dynamic>> transaksiItems}) : super(key: key);

  @override
  _RiwayatPageState createState() => _RiwayatPageState();
}

class _RiwayatPageState extends State<RiwayatPage> {
Future<List<Map<String, dynamic>>> fetchRiwayat() async {
  try {
    final response = await Supabase.instance.client
        .from('penjualan')
        .select('penjualan_id, tanggal_penjualan, total_harga, nama_pelanggan, pelanggan_id')
        .order('tanggal_penjualan', ascending: false);

    return response.map<Map<String, dynamic>>((item) => {
          'penjualan_id': item['penjualan_id'],
          'tanggal_penjualan': item['tanggal_penjualan'],
          'total_harga': item['total_harga'],
          'nama_pelanggan': item['nama_pelanggan'],
          'pelanggan_id': item['pelanggan_id'],
        }).toList();
  } catch (e) {
    print('Error fetching history: $e');
    return [];
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Riwayat Penjualan')),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: fetchRiwayat(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final riwayat = snapshot.data ?? [];

          return ListView.builder(
            itemCount: riwayat.length,
            itemBuilder: (context, index) {
              final transaksi = riwayat[index];

              return Card(
                margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                child: ListTile(
                  title: Text(
                    'ID: ${transaksi['penjualan_id']} - Pelanggan: ${transaksi['nama_pelanggan']} - Id: ${transaksi['pelanggan_id']}',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text('Tanggal: ${transaksi['tanggal_penjualan']}'),
                  trailing: Text(
                    'Rp ${transaksi['total_harga'].toStringAsFixed(0)}',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
