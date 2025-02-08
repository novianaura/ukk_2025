import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Produk extends StatefulWidget {
  const Produk({super.key});

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
    _fetchProduk(); // Memuat data produk saat halaman diinisialisasi
  }

  // Fungsi untuk memuat data produk dari Supabase
  Future<void> _fetchProduk() async {
    try {
      final response = await Supabase.instance.client
          .from('produk')
          .select();

      setState(() {
        produkList = response.map<Map<String, dynamic>>((item) {
          return {
            'id': item['id'],
            'name': item['nama_produk'],
            'price': item['harga'],
            'stock': item['stok'],
          };
        }).toList();
        filteredProducts = List.from(produkList);
      });
    } catch (e) {
      print('Error fetching produk: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching produk: $e')),
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

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Tambah Produk', style: TextStyle(fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: 'Nama Produk',
                  hintText: 'Masukkan nama produk',
                ),
              ),
              SizedBox(height: 10),
              TextField(
                controller: priceController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Harga Produk',
                  hintText: 'Masukkan harga produk',
                ),
              ),
              SizedBox(height: 10),
              TextField(
                controller: stockController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Stok Produk',
                  hintText: 'Masukkan stok produk',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Batal', style: TextStyle(color: Colors.red)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue[900]),
              onPressed: () async {
                final name = nameController.text;
                final price = int.tryParse(priceController.text) ?? 0;
                final stock = int.tryParse(stockController.text) ?? 0;

                try {
                  final response = await Supabase.instance.client
                      .from('product')
                      .insert([
                        {'nama_produk': name, 'harga': price, 'stok': stock},
                      ])
                      .select();

                  if (response.isNotEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Produk baru ditambahkan ke database!')),
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
              },
              child: Text('Tambah', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  // Fungsi untuk mengedit produk
  Future<void> _editProduk(BuildContext context, Map<String, dynamic> produk) async {
    TextEditingController nameController = TextEditingController(text: produk['name']);
    TextEditingController priceController = TextEditingController(text: produk['price'].toString());
    TextEditingController stockController = TextEditingController(text: produk['stock'].toString());

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit Produk', style: TextStyle(fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: 'Nama Produk',
                  hintText: 'Masukkan nama produk',
                ),
              ),
              SizedBox(height: 10),
              TextField(
                controller: priceController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Harga Produk',
                  hintText: 'Masukkan harga produk',
                ),
              ),
              SizedBox(height: 10),
              TextField(
                controller: stockController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Stok Produk',
                  hintText: 'Masukkan stok produk',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Batal', style: TextStyle(color: Colors.black)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue[900]),
              onPressed: () async {
                final updatedName = nameController.text;
                final updatedPrice = int.tryParse(priceController.text) ?? produk['price'];
                final updatedStock = int.tryParse(stockController.text) ?? produk['stock'];

                try {
                  final response = await Supabase.instance.client
                      .from('product')
                      .update({
                        'nama_produk': updatedName,
                        'harga': updatedPrice,
                        'stok': updatedStock,
                      })
                      .eq('id', produk['id']);

                  if (response.isNotEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Produk berhasil diperbarui!')),
                    );
                    _fetchProduk(); // Perbarui tampilan
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
              },
              child: Text('Simpan', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  // Fungsi untuk menghapus produk
  Future<void> _hapusProduk(BuildContext context, int id) async {
    try {
      final response = await Supabase.instance.client
          .from('product')
          .delete()
          .eq('id', id)
          .select();

      if (response.isNotEmpty) {
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
                ? const Center(child: Text('Tidak ada produk ditemukan.'))
                : ListView.builder(
                    itemCount: filteredProducts.length,
                    itemBuilder: (context, index) {
                      final product = filteredProducts[index];
                      return ListTile(
                        title: Text(product['name']),
                        subtitle: Text('Harga: ${product['price']} | Stok: ${product['stock']}'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () => _editProduk(context, product),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _hapusProduk(context, product['id']),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _tambahProduk(context),
        child: const Icon(Icons.add),
      ),
    );
  }
}
