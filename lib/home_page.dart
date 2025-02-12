import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ukk_2025/login.dart';
import 'package:ukk_2025/riwayat.dart';
import 'produk.dart';
import 'pelanggan.dart';
import 'transaksi.dart'; // Import the Transaksi page

class HomePage extends StatefulWidget {
  const HomePage(
      {super.key,
      required this.title,
      required this.username,
      required this.role});
  final String title;
  final String username;
  final String role;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  List<Map<String, dynamic>> transaksiItems = [];
  List<Map<String, dynamic>> customers = []; // Menyimpan data pelanggan
  String? username;
  String? role;

  final List<Widget> _pages = [];

  @override
  void initState() {
    super.initState();
    _fetchCustomers(); // Panggil fungsi untuk mengambil data pelanggan

    _pages.addAll([
  Produk(addToTransaksi: addToTransaksi),
  TransaksiPage(transaksiItems: transaksiItems, customers: customers),
  RiwayatPage(transaksiItems: transaksiItems),
  const Pelanggan(),
]);


    // Ambil data user login
    final user = Supabase.instance.client.auth.currentUser;
    if (user != null) {
      setState(() {
        username = user.email; // Asumsikan email digunakan sebagai username
        role =
            user.userMetadata?['role']; // Asumsikan role disimpan di metadata
      });
    }
  }

  // Fungsi untuk mengambil data pelanggan
  Future<void> _fetchCustomers() async {
    try {
      final response =
          await Supabase.instance.client.from('pelanggan').select();

      setState(() {
        customers = response.map<Map<String, dynamic>>((item) {
          return {
            'pelanggan_id': item['pelanggan_id'] ?? 0,
            'nama_pelanggan': item['nama_pelanggan'] ?? '',
            'alamat': item['alamat'] ?? '',
            'nomor_telepon': item['nomor_telepon'] ?? '',
          };
        }).toList();
      });
    } catch (e) {
      print('Error fetching customers: $e');
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  // Fungsi untuk menambah produk ke transaksi
void addToTransaksi(Map<String, dynamic> product) {
  setState(() {
    // Cek apakah produk sudah ada dalam transaksi
    int index = transaksiItems.indexWhere((item) => item['id'] == product['id']);
    if (index != -1) {
      // Jika sudah ada, tambah jumlahnya
      transaksiItems[index]['quantity'] += 1;
    } else {
      // Jika belum ada, tambahkan dengan quantity = 1
      transaksiItems.add({...product, 'quantity': 1});
    }
  });
}

// Perbaiki Logout dengan menggunakan pushReplacement
  Future<void> _logout() async {
    try {
      // Sign out from Supabase
      await Supabase.instance.client.auth.signOut();

      // Navigasi ke halaman login
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) =>
                LoginPage()), // Ganti dengan halaman login yang sesuai
      );
    } catch (e) {
      print('Error logging out: $e');
    }
  }

  // Show profile dialog with username, role, and logout option
  void _showProfileDialog() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Container(
          width: 250, // Set a fixed width for the dialog
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min, // Ensure the dialog is compact
            crossAxisAlignment: CrossAxisAlignment.center, // Center the content
            children: [
              CircleAvatar(
                radius: 30, // Smaller profile image
                backgroundColor: Colors.blue,
                child: Icon(Icons.person, size: 40, color: Colors.white),
              ),
              const SizedBox(height: 16),
              Text(
                'Username: ${widget.username}',
                style: TextStyle(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center, // Center username
              ),
              const SizedBox(height: 8),
              Text(
                'Role: ${widget.role}',
                style: TextStyle(color: Colors.grey),
                textAlign: TextAlign.center, // Center role
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _logout,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white, // Set text color to white
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
                child: Text('Logout'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffffffff),
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
        backgroundColor: const Color(0x00ffffff),
        title: const Text(
          "Administrasi",
          style: TextStyle(
            fontWeight: FontWeight.w400,
            fontSize: 14,
            color: Color(0xff000000),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person, color: Colors.black), // Profile icon
            onPressed: _showProfileDialog, // Show profile dialog when clicked
          ),
        ],
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Colors.blue[900],
        unselectedItemColor: Colors.grey,
        backgroundColor: Colors.blue,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: 'Produk',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.credit_card),
            label: 'Transaksi',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'Riwayat',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Pelanggan',
          ),
        ],
      ),
    );
  }
}
