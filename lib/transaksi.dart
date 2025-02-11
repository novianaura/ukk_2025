import 'package:flutter/material.dart';
import 'package:ukk_2025/penjualan.dart';

class TransaksiPage extends StatefulWidget {
  final List<Map<String, dynamic>> transaksiItems;

  const TransaksiPage({Key? key, required this.transaksiItems}) : super(key: key);

  @override
  _TransaksiPageState createState() => _TransaksiPageState();
}

class _TransaksiPageState extends State<TransaksiPage> {
  String? selectedCustomer;  // Variable to hold the selected customer
  List<String> customers = ['Pelanggan 1', 'Pelanggan 2', 'Pelanggan 3']; // Example customer list

  double _calculateTotal() {
    double total = 0;
    for (var product in widget.transaksiItems) {
      final price = product['price'] ?? 0;
      final quantity = product['quantity'] ?? 1;
      total += price * quantity;
    }
    return total;
  }

  void _updateQuantity(int index, int delta) {
    setState(() {
      final product = widget.transaksiItems[index];
      product['quantity'] = (product['quantity'] ?? 1) + delta;

      // If the quantity is less than or equal to zero, remove the product from the list
      if (product['quantity'] <= 0) {
        widget.transaksiItems.removeAt(index);
      } else {
        // Ensure quantity does not go negative
        product['quantity'] = product['quantity'] ?? 1;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Customer dropdown is visible from the start
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
                items: customers.map<DropdownMenuItem<String>>((String customer) {
                  return DropdownMenuItem<String>(
                    value: customer,
                    child: Text(customer),
                  );
                }).toList(),
              ),
            ),
          ),

          // Product List Section
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
                        key: ValueKey(index), // Use ValueKey to prevent unnecessary rebuilds
                        margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
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
                                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
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
                                    onPressed: () => _updateQuantity(index, -1),
                                    color: Colors.red,
                                  ),
                                  Text(
                                    '$quantity',
                                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.add),
                                    onPressed: () => _updateQuantity(index, 1),
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

          // Total and button section
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
                          builder: (context) => PenjualanPage(transaksiItems: widget.transaksiItems),
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
}
