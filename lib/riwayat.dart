perbaikan pertama
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ukk_2025/riwayat.dart';

class TransaksiPage extends StatefulWidget {
  final List<Map<String, dynamic>> transaksiItems;

  const TransaksiPage({super.key, required this.transaksiItems});

  @override
  _TransaksiPageState createState() => _TransaksiPageState();
}

class _TransaksiPageState extends State<TransaksiPage> {
  String? selectedCustomer;
  List<Map<String, dynamic>> transaksiList = [];

  @override
  void initState() {
    super.initState();
    transaksiList = List<Map<String, dynamic>>.from(widget.transaksiItems);
  }

  Future<List<Map<String, dynamic>>> fetchCustomers() async {
    try {
      final response = await Supabase.instance.client.from('pelanggan').select();
      if (response == null || response.isEmpty) {
        return [];
      }
      return response.map<Map<String, dynamic>>((item) => {
            'pelanggan_id': item['pelanggan_id'] ?? 0,
            'nama_pelanggan': item['nama_pelanggan'] ?? 'Tanpa Nama',
          }).toList();
    } catch (e) {
      print('Error fetching customers: $e');
      return [];
    }
  }

  double _calculateTotal() {
    double total = 0;
    for (var product in transaksiList) {
      final price = product['price'] ?? 0;
      final quantity = product['quantity'] ?? 1;
      total += price * quantity;
    }
    return total;
  }

  void _updateQuantity(int index, int change) {
    setState(() {
      if (transaksiList[index]['quantity'] + change > 0) {
        transaksiList[index]['quantity'] += change;
      } else {
        transaksiList.removeAt(index);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: fetchCustomers(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final customers = snapshot.data ?? [];

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    labelText: "Pilih Pelanggan",
                    border: OutlineInputBorder(),
                  ),
                  value: selectedCustomer,
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedCustomer = newValue;
                    });
                  },
                  items: customers.map((customer) {
                    return DropdownMenuItem<String>(
                      value: customer['pelanggan_id'].toString(),
                      child: Text(customer['nama_pelanggan']),
                    );
                  }).toList(),
                ),
              ),
              Expanded(
                child: transaksiList.isEmpty
                    ? Center(child: Text('Tidak ada produk dalam transaksi.'))
                    : ListView.builder(
                        key: ValueKey(transaksiList.length),
                        itemCount: transaksiList.length,
                        itemBuilder: (context, index) {
                          final product = transaksiList[index];
                          final price = product['price'] ?? 0;
                          final quantity = product['quantity'] ?? 1;
                          final subtotal = price * quantity;

                          return Card(
                            key: ValueKey(product['name']),
                            margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                            child: Padding(
                              padding: const EdgeInsets.all(10),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    product['name'],
                                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                  ),
                                  SizedBox(height: 5),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        '$quantity x Rp ${price.toStringAsFixed(0)} = Rp ${subtotal.toStringAsFixed(0)}',
                                        style: TextStyle(color: Colors.grey[700]),
                                      ),
                                      Row(
                                        children: [
                                          IconButton(
                                            icon: Icon(Icons.remove),
                                            onPressed: () => _updateQuantity(index, -1),
                                          ),
                                          Text('$quantity', style: TextStyle(fontSize: 16)),
                                          IconButton(
                                            icon: Icon(Icons.add),
                                            onPressed: () => _updateQuantity(index, 1),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total: Rp ${_calculateTotal().toStringAsFixed(0)}',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        if (selectedCustomer == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Silakan pilih pelanggan terlebih dahulu!')),
                          );
                        } else {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => RiwayatPage(transaksiItems: transaksiList),
                            ),
                          );
                        }
                      },
                      child: Text('Masukkan ke Penjualan'),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}


perbaikan ke dua
