import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class CustomerScreen extends StatefulWidget {
  const CustomerScreen({super.key});

  @override
  State<CustomerScreen> createState() => _CustomerScreenState();
}

class _CustomerScreenState extends State<CustomerScreen> {
  final TextEditingController _searchController = TextEditingController();
  final List<Map<String, dynamic>> _customers = [
    {'id': 1, 'name': 'boy'},
    // Tambah data dummy lainnya jika perlu
  ];

  List<Map<String, dynamic>> _filteredCustomers = [];

  @override
  void initState() {
    super.initState();
    _filteredCustomers = List.from(_customers);
  }

  void _filterCustomers(String query) {
    setState(() {
      _filteredCustomers =
          _customers
              .where(
                (c) => c['name'].toLowerCase().contains(query.toLowerCase()),
              )
              .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    const themeColor = Color(0xFF0A192F);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: themeColor,
        title: Text('add_customer_to_ticket'.tr()),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: TextField(
              controller: _searchController,
              onChanged: _filterCustomers,
              decoration: InputDecoration(
                hintText: 'search'.tr(),
                prefixIcon: const Icon(Icons.search),
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(6),
                  borderSide: const BorderSide(color: Colors.blue),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: SizedBox(
              width: double.infinity,
              child: TextButton(
                style: TextButton.styleFrom(
                  backgroundColor: Colors.green.shade100,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                onPressed: () {
                  // Implementasi tambah pelanggan baru
                },
                child: Text(
                  'add_new_customer'.tr(),
                  style: const TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Pelanggan terakhir',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _filteredCustomers.length,
              itemBuilder: (context, index) {
                final customer = _filteredCustomers[index];
                return ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Colors.grey,
                    child: Icon(Icons.person, color: Colors.white),
                  ),
                  title: Text(customer['name']),
                  onTap: () {
                    Navigator.pop(context, customer);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
