import 'package:flutter/material.dart';
import 'package:ukk_2025/penjualan.dart';

class TransaksiPage extends StatefulWidget {
  final List<Map<String, dynamic>> transaksiItems;
  final List<Map<String, dynamic>>
      customers; // Daftar pelanggan yang dikirim dari HomePage

  const TransaksiPage(
      {Key? key, required this.transaksiItems, required this.customers})
      : super(key: key);

  @override
  _TransaksiPageState createState() => _TransaksiPageState();
}

class _TransaksiPageState extends State<TransaksiPage> {
  String?
      selectedCustomer; // Untuk menyimpan pelanggan yang dipilih di dropdown

  double _calculateTotal() {
    double total = 0;
    for (var product in widget.transaksiItems) {
      final price = product['price'] ?? 0;
      final quantity = product['quantity'] ?? 1;
      total += price * quantity;
    }
    return total;
  }

  @override
  Widget build(BuildContext context) {
    print(widget.customers
        .map((customer) => customer['nama_pelanggan'])
        .toList());
    return Scaffold(
      body: Column(
        children: [
          // Dropdown untuk memilih pelanggan
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5),
                border: Border.all(color: Colors.grey),
              ),
              child: DropdownButton<String>(
                hint: Text("Pilih Pelanggan"),
                value: selectedCustomer,
                onChanged: (String? newValue) {
                  setState(() {
                    selectedCustomer = newValue;
                  });
                },
                isExpanded: true,
                underline: SizedBox(),
                items: widget.customers.isNotEmpty
                    ? widget.customers
                        .map<DropdownMenuItem<String>>((customer) {
                        return DropdownMenuItem<String>(
                          value: customer['pelanggan_id']
                              .toString(), 
                          child: Text(customer[
                              'nama_pelanggan']), 
                        );
                      }).toList()
                    : [
                        DropdownMenuItem<String>(
                          value: null,
                          child: Text('Tidak ada pelanggan ditemukan'),
                        )
                      ],
              ),
            ),
          ),

          // Menampilkan produk yang ada di transaksi
          widget.transaksiItems.isEmpty
              ? Center(child: Text('Tidak ada produk di transaksi.'))
              : Expanded(
                  child: ListView.builder(
                    itemCount: widget.transaksiItems.length,
                    itemBuilder: (context, index) {
                      final product = widget.transaksiItems[index];
                      final price = product['price'] ?? 0;
                      final quantity = product['quantity'] ?? 1;
                      final subtotal = price * quantity;

                      return Card(
                        key: ValueKey(index),
                        margin:
                            EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                        child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    product['name'],
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16),
                                  ),
                                  SizedBox(height: 5),
                                  Text(
                                    '${quantity}x Rp ${price} = Rp $subtotal',
                                    style: TextStyle(color: Colors.grey[700]),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  IconButton(
                                    icon: Icon(Icons.remove),
                                    onPressed: () {
                                      _updateQuantity(index, -1);
                                    },
                                    color: Colors.red,
                                  ),
                                  Text(
                                    '$quantity',
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.add),
                                    onPressed: () {
                                      _updateQuantity(index, 1);
                                    },
                                    color: Colors.green,
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

          // Total dan tombol untuk lanjut ke Penjualan
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
                        SnackBar(
                            content: Text(
                                'Silakan pilih pelanggan terlebih dahulu!')),
                      );
                    } else {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PenjualanPage(
                              transaksiItems: widget.transaksiItems),
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
      ),
    );
  }

  void _updateQuantity(int index, int change) {
    setState(() {
      widget.transaksiItems[index]['quantity'] += change;
    });
  }
}
