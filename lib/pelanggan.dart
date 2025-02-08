import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Pelanggan extends StatefulWidget {
  const Pelanggan({super.key});

  @override
  _PelangganState createState() => _PelangganState();
}

class _PelangganState extends State<Pelanggan> {
  List<Map<String, dynamic>> pelangganList = [];
  List<Map<String, dynamic>> filteredCustomers = [];
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchPelanggan(); // Memuat data pelanggan saat halaman diinisialisasi
  }

  // Fungsi untuk memuat data pelanggan dari Supabase
  Future<void> _fetchPelanggan() async {
    try {
      final response = await Supabase.instance.client
          .from('pelanggan')
          .select();

      setState(() {
        pelangganList = response.map<Map<String, dynamic>>((item) {
          return {
            'pelanggan_id': item['pelanggan_id'] ?? 0,
            'nama_pelanggan': item['nama_pelanggan'] ?? '',
            'alamat': item['alamat'] ?? '',
            'nomor_telepon': item['nomor_telepon'] ?? '',
          };
        }).toList();
        filteredCustomers = List.from(pelangganList);
      });
    } catch (e) {
      print('Error fetching pelanggan: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching pelanggan: $e')),
      );
    }
  }

  // Fungsi untuk menangani pencarian pelanggan
  void _searchCustomers() {
    final query = searchController.text.toLowerCase();
    setState(() {
      filteredCustomers = pelangganList
          .where((customer) => customer['nama_pelanggan']
              .toLowerCase()
              .contains(query)) // Pencarian berdasarkan nama pelanggan
          .toList();
    });
  }

  // Fungsi untuk menambahkan pelanggan
  Future<void> _tambahPelanggan(BuildContext context) async {
    TextEditingController nameController = TextEditingController();
    TextEditingController addressController = TextEditingController();
    TextEditingController phoneController = TextEditingController();
    final _formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Tambah Pelanggan', style: TextStyle(fontWeight: FontWeight.bold)),
          content: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: 'Nama Pelanggan',
                    hintText: 'Masukkan nama pelanggan',
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
                  controller: addressController,
                  decoration: InputDecoration(
                    labelText: 'Alamat Pelanggan',
                    hintText: 'Masukkan alamat pelanggan',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Alamat kosong';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 10),
                TextFormField(
                  controller: phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    labelText: 'Nomor Telepon',
                    hintText: 'Masukkan nomor telepon',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Nomor telepon kosong';
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
              child: Text('Batal', style: TextStyle(color: Colors.red)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue[900]),
              onPressed: () async {
                if (_formKey.currentState?.validate() ?? false) {
                  final name = nameController.text;
                  final address = addressController.text;
                  final phone = phoneController.text;

                  try {
                    final response = await Supabase.instance.client
                        .from('pelanggan')
                        .insert([
                          {
                            'nama_pelanggan': name,
                            'alamat': address,
                            'nomor_telepon': phone,
                          },
                        ])
                        .select();

                    if (response != null && response is List && response.isNotEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Pelanggan baru ditambahkan ke database!')),
                      );
                      _fetchPelanggan(); // Perbarui tampilan
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Pelanggan gagal ditambahkan.')),
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

  // Fungsi untuk mengedit pelanggan
  Future<void> _editPelanggan(BuildContext context, Map<String, dynamic> pelanggan) async {
    TextEditingController nameController = TextEditingController(text: pelanggan['nama_pelanggan']);
    TextEditingController addressController = TextEditingController(text: pelanggan['alamat']);
    TextEditingController phoneController = TextEditingController(text: pelanggan['nomor_telepon']);
    final _formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit Pelanggan', style: TextStyle(fontWeight: FontWeight.bold)),
          content: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: 'Nama Pelanggan',
                    hintText: 'Masukkan nama pelanggan',
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
                  controller: addressController,
                  decoration: InputDecoration(
                    labelText: 'Alamat Pelanggan',
                    hintText: 'Masukkan alamat pelanggan',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Alamat kosong';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 10),
                TextFormField(
                  controller: phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    labelText: 'Nomor Telepon',
                    hintText: 'Masukkan nomor telepon',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Nomor telepon kosong';
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
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue[900]),
              onPressed: () async {
                if (_formKey.currentState?.validate() ?? false) {
                  final updatedName = nameController.text.isNotEmpty ? nameController.text : pelanggan['nama_pelanggan'];
                  final updatedAddress = addressController.text.isNotEmpty ? addressController.text : pelanggan['alamat'];
                  final updatedPhone = phoneController.text.isNotEmpty ? phoneController.text : pelanggan['nomor_telepon'];

                  try {
                    final response = await Supabase.instance.client
                        .from('pelanggan')
                        .update({
                          'nama_pelanggan': updatedName,
                          'alamat': updatedAddress,
                          'nomor_telepon': updatedPhone,
                        })
                        .eq('pelanggan_id', pelanggan['pelanggan_id'])
                        .select();

                    if (response != null && response is List && response.isNotEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Pelanggan berhasil diperbarui!')),
                      );
                      _fetchPelanggan(); // Perbarui tampilan
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Gagal memperbarui pelanggan.')),
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

  // Fungsi untuk menghapus pelanggan
  Future<void> _hapusPelanggan(BuildContext context, int pelanggan_id) async {
    try {
      final response = await Supabase.instance.client
          .from('pelanggan')
          .delete()
          .eq('pelanggan_id', pelanggan_id)
          .select();

      if (response != null && response is List && response.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Pelanggan berhasil dihapus!')),
        );
        _fetchPelanggan(); // Perbarui tampilan
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
      appBar: AppBar(
        title: const Text('Pelanggan'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                labelText: 'Cari Pelanggan...',
                suffixIcon: IconButton(
                  icon: Icon(Icons.clear),
                  onPressed: () {
                    searchController.clear();
                    _searchCustomers();
                  },
                ),
              ),
              onChanged: (_) => _searchCustomers(),
            ),
          ),
          Expanded(
            child: filteredCustomers.isEmpty
                ? const Center(child: Text('Tidak ada pelanggan ditemukan.'))
                : ListView.builder(
                    itemCount: filteredCustomers.length,
                    itemBuilder: (context, index) {
                      final customer = filteredCustomers[index];
                      return ListTile(
                        title: Text(customer['nama_pelanggan']),
                        subtitle: Text('Alamat: ${customer['alamat']} | Telepon: ${customer['nomor_telepon']}'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () => _editPelanggan(context, customer),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _hapusPelanggan(context, customer['pelanggan_id']),
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
        onPressed: () => _tambahPelanggan(context),
        child: const Icon(Icons.add),
      ),
    );
  }
}
