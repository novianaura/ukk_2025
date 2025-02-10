import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ukk_2025/transaksi.dart';

class Produk extends StatefulWidget {
  const Produk({super.key, required Null Function(dynamic produk) addToTransaksi});

  @override
  _ProdukState createState() => _ProdukState();
}

class _ProdukState extends State<Produk> {
  List<Map<String, dynamic>> produkList = [];
  List<Map<String, dynamic>> filteredProducts = [];

  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchProduk();
  }

  // Fungsi untuk memuat data produk dari Supabase
  Future<void> _fetchProduk() async {
    try {
      final response = await Supabase.instance.client.from('produk').select();

      setState(() {
        produkList = response.map<Map<String, dynamic>>((item) {
          return {
            'produk_id': item['produk_id'] ?? 0,
            'name': item['nama_produk'] ?? '',
            'price': item['harga'] ?? 0,
            'stock': item['stok'] ?? 0,
          };
        }).toList();
        filteredProducts = List.from(produkList);
      });
    } catch (e) {
      print('Terjadi kesalahan saat mengambil produk: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Terjadi kesalahan saat mengambil produk: $e')),
      );
    }
  }

  // Fungsi untuk menangani pencarian produk
  void _searchProducts() {
    final query = searchController.text.toLowerCase();
    setState(() {
      filteredProducts = produkList
          .where((product) => product['name']
              .toLowerCase()
              .contains(query)) // Pencarian berdasarkan nama produk
          .toList();
    });
  }

  // Fungsi untuk menambahkan produk
  Future<void> _tambahProduk(BuildContext context) async {
    TextEditingController nameController = TextEditingController();
    TextEditingController priceController = TextEditingController();
    TextEditingController stockController = TextEditingController();
    final _formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Tambah Produk',
              style: TextStyle(fontWeight: FontWeight.bold)),
          content: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: 'Nama Produk',
                    hintText: 'Masukkan nama produk',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Nama kosong';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 10),
                TextFormField(
                  controller: priceController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Harga Produk',
                    hintText: 'Masukkan harga produk',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Harga kosong';
                    }
                    final price = int.tryParse(value);
                    if (price == null) {
                      return 'Harga tidak valid';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 10),
                TextFormField(
                  controller: stockController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Stok Produk',
                    hintText: 'Masukkan stok produk',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Stok kosong';
                    }
                    final stock = int.tryParse(value);
                    if (stock == null) {
                      return 'Stok tidak valid';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Batal', style: TextStyle(color: Colors.black)),
            ),
            ElevatedButton(
              style:
                  ElevatedButton.styleFrom(backgroundColor: Colors.blue[900]),
              onPressed: () async {
                if (_formKey.currentState?.validate() ?? false) {
                  final name = nameController.text;
                  final price = int.tryParse(priceController.text) ?? 0;
                  final stock = int.tryParse(stockController.text) ?? 0;

                  try {
                    final response =
                        await Supabase.instance.client.from('produk').insert([
                      {'nama_produk': name, 'harga': price, 'stok': stock},
                    ]).select();

                    if (response != null &&
                        response is List &&
                        response.isNotEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Produk berhasil ditambahkan')),
                      );
                      _fetchProduk(); // Perbarui tampilan
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Produk gagal ditambahkan.')),
                      );
                    }
                    Navigator.pop(context);
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error occurred: $e')),
                    );
                  }
                }
              },
              child: Text('Tambah', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  // Fungsi untuk mengedit produk
  Future<void> _editProduk(
      BuildContext context, Map<String, dynamic> produk) async {
    TextEditingController nameController =
        TextEditingController(text: produk['name']);
    TextEditingController priceController =
        TextEditingController(text: produk['price'].toString());
    TextEditingController stockController =
        TextEditingController(text: produk['stock'].toString());
    final _formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit Produk',
              style: TextStyle(fontWeight: FontWeight.bold)),
          content: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: 'Nama Produk',
                    hintText: 'Masukkan nama produk',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Nama produk kosong';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 10),
                TextFormField(
                  controller: priceController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Harga Produk',
                    hintText: 'Masukkan harga produk',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Harga kosong';
                    }
                    final price = int.tryParse(value);
                    if (price == null) {
                      return 'Harga tidak valid';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 10),
                TextFormField(
                  controller: stockController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Stok Produk',
                    hintText: 'Masukkan stok produk',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Stok kosong';
                    }
                    final stock = int.tryParse(value);
                    if (stock == null) {
                      return 'Stok tidak valid';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Batal', style: TextStyle(color: Colors.black)),
            ),
            ElevatedButton(
              style:
                  ElevatedButton.styleFrom(backgroundColor: Colors.blue[900]),
              onPressed: () async {
                if (_formKey.currentState?.validate() ?? false) {
                  final updatedName = nameController.text.isNotEmpty
                      ? nameController.text
                      : produk['name'];
                  final updatedPrice = priceController.text.isNotEmpty
                      ? int.tryParse(priceController.text)
                      : produk['price'];
                  final updatedStock = stockController.text.isNotEmpty
                      ? int.tryParse(stockController.text)
                      : produk['stock'];

                  try {
                    final response = await Supabase.instance.client
                        .from('produk')
                        .update({
                          'nama_produk': updatedName,
                          'harga': updatedPrice,
                          'stok': updatedStock,
                        })
                        .eq('produk_id', produk['produk_id'])
                        .select(); // Menggunakan .select() untuk mengambil data setelah update

                    if (response != null &&
                        response is List &&
                        response.isNotEmpty) {
                      // Find the index of the product in the filteredProducts list
                      final index = filteredProducts.indexWhere(
                          (prod) => prod['produk_id'] == produk['produk_id']);
                      if (index != -1) {
                        // Update the product in the list at the same index
                        setState(() {
                          filteredProducts[index] = {
                            'produk_id': produk['produk_id'],
                            'name': updatedName,
                            'price': updatedPrice,
                            'stock': updatedStock,
                          };
                        });
                      }

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Produk berhasil diperbarui!')),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Gagal memperbarui produk.')),
                      );
                    }
                    Navigator.pop(context);
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error occurred: $e')),
                    );
                  }
                }
              },
              child: Text('Simpan', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  // Fungsi untuk menghapus produk
  Future<void> _hapusProduk(BuildContext context, int _produk_id) async {
    try {
      final response = await Supabase.instance.client
          .from('produk')
          .delete()
          .eq('produk_id', _produk_id)
          .select();

      if (response != null && response is List && response.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Produk berhasil dihapus!')),
        );
        _fetchProduk(); // Perbarui tampilan
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error occurred: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                labelText: 'Cari Produk...',
                suffixIcon: IconButton(
                  icon: Icon(Icons.clear),
                  onPressed: () {
                    searchController.clear();
                    _searchProducts();
                  },
                ),
              ),
              onChanged: (_) => _searchProducts(),
            ),
          ),
          Expanded(
              child: filteredProducts.isEmpty
                  ? Center(child: Text('Tidak ada produk ditemukan.'))
                  : ListView.builder(
                      itemCount: filteredProducts.length,
                      itemBuilder: (context, index) {
                        final product = filteredProducts[index];
                        return ListTile(
                          title: Text(product['name']),
                          subtitle: Text(
                              'Harga: ${product['price']} | Stok: ${product['stock']}'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Icon(Icons.delete, color: Colors.red),
                                onPressed: () {
                                  _hapusProduk(context, product['produk_id']);
                                },
                              ),
                              IconButton(
                                icon: Icon(Icons.edit),
                                onPressed: () => _editProduk(context, product),
                              ),
                              IconButton(
                                icon: Icon(Icons.shopping_cart),
                                onPressed: () {
    // Assume transaksiList is a state or a list in your main widget to store the selected products.
                                final selectedProduct = {
                                  'produk_id': product['produk_id'],
                                  'nama_produk': product['name'],
                                  'harga': product['price'],
                                  'jumlah': 1,  // Default quantity when added
                                  'subtotal': product['price'],  // Default subtotal (price * quantity)
                                };

    // Navigate to Transaksi screen and pass selected product
                  Navigator.push(
                  context,
                   MaterialPageRoute(
                     builder: (context) => Transaksi(transaksiList: [selectedProduct]),
                  ),
                );
              },
            ),
            ],
          ),
    );
})),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _tambahProduk(context);
        },
        child: Icon(Icons.add),
      ),
    );
  }
}

//buat ketika icon keranjang diklik, data produknya bisa beralih tertambahkan ke halaman transaksi, dan buat tampilan transaksi produk