import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Produk extends StatefulWidget {
  const Produk({super.key});

  @override
  _ProdukState createState() => _ProdukState();
}

class _ProdukState extends State<Produk> {
  final SupabaseClient supabase = Supabase.instance.client;
  final TextEditingController namaController = TextEditingController();
  final TextEditingController hargaController = TextEditingController();
  final TextEditingController stokController = TextEditingController();
  final TextEditingController searchController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  List<Map<String, dynamic>> products = [];
  List<Map<String, dynamic>> filteredProducts = [];

  @override
  void initState() {
    super.initState();
    _fetchProducts();
  }

  Future<void> _fetchProducts() async {
    try {
      final data = await supabase.from('produk').select();
      setState(() {
        products = List<Map<String, dynamic>>.from(data);
        filteredProducts = products;
      });
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal mengambil data: $error')),
      );
    }
  }

  void _searchProducts() {
    String query = searchController.text.toLowerCase();
    setState(() {
      filteredProducts = products.where((product) {
        return product['nama_produk'].toLowerCase().contains(query);
      }).toList();
    });
  }

  Future<void> _addOrUpdateProduct({int? id}) async {
    if (!_formKey.currentState!.validate()) return;

    String namaProduk = namaController.text;
    double harga = double.parse(hargaController.text);
    int stok = int.parse(stokController.text);

    try {
      if (id == null) {
        await supabase.from('produk').insert({
          'nama_produk': namaProduk,
          'harga': harga,
          'stok': stok,
        });
      } else {
        await supabase.from('produk').update({
          'nama_produk': namaProduk,
          'harga': harga,
          'stok': stok,
        }).match({'id': id});
      }

      namaController.clear();
      hargaController.clear();
      stokController.clear();

      _fetchProducts();
      Navigator.pop(context);
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menyimpan data: $error')),
      );
    }
  }

  Future<void> _deleteProduct(int id) async {
    try {
      // Deleting the product from the database
      await supabase.from('produk').delete().match({'id': id});
      // Fetch updated list of products
      _fetchProducts();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Produk berhasil dihapus')),
      );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menghapus data: $error')),
      );
    }
  }

  void _showProductDialog({int? id, String? name, double? price, int? stock}) {
    if (id != null) {
      namaController.text = name ?? '';
      hargaController.text = price?.toString() ?? '';
      stokController.text = stock?.toString() ?? '';
    } else {
      namaController.clear();
      hargaController.clear();
      stokController.clear();
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(id == null ? 'Tambah Produk' : 'Edit Produk'),
        content: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: namaController,
                decoration: InputDecoration(labelText: 'Nama Produk'),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Nama produk kosong' : null,
              ),
              TextFormField(
                controller: hargaController,
                decoration: InputDecoration(labelText: 'Harga'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Harga kosong';
                  if (double.tryParse(value) == null) return 'Harga tidak valid';
                  return null;
                },
              ),
              TextFormField(
                controller: stokController,
                decoration: InputDecoration(labelText: 'Stok'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Stok kosong';
                  if (int.tryParse(value) == null) return 'Stok tidak valid';
                  return null;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('Batal')),
          ElevatedButton(
              onPressed: () => _addOrUpdateProduct(id: id),
              child: Text(id == null ? 'Tambah' : 'Update')),
        ],
      ),
    );
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
                    _searchProducts(); // Reset search
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
                        title: Text(product['nama_produk']),
                        subtitle: Text('Harga: ${product['harga']} | Stok: ${product['stok']}'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () => _showProductDialog(
                                id: product['id'],
                                name: product['nama_produk'],
                                price: (product['harga'] as num).toDouble(),
                                stock: product['stok'],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: Text('Konfirmasi Hapus'),
                                      content: Text(
                                          'Apakah Anda yakin ingin menghapus produk ini?'),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.pop(context),
                                          child: Text('Batal'),
                                        ),
                                        ElevatedButton(
                                          onPressed: () {
                                            _deleteProduct(product['id']);
                                            Navigator.pop(context); // Close the dialog
                                          },
                                          child: Text('Hapus'),
                                        ),
                                      ],
                                    );
                                  },
                                );
                              },
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
        onPressed: () => _showProductDialog(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
