// lib/main.dart
import 'package:flutter/material.dart';
import 'package:upupa_dart/upupa_dart.dart';

void main() {
  runApp(const DaftarcheApp());
}

class DaftarcheApp extends StatelessWidget {
  const DaftarcheApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'دفترچه مخاطبین (Daftarche)',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      home: const ContactsScreen(),
    );
  }
}

class ContactsScreen extends StatefulWidget {
  const ContactsScreen({super.key});

  @override
  State<ContactsScreen> createState() => _ContactsScreenState();
}

class _ContactsScreenState extends State<ContactsScreen> {
  late final UpupaClient _client;
  List<Record> _contacts = [];
  bool _isLoading = true;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _client = UpupaClient('http://127.0.0.1:8090');
    _fetchContacts();
  }

  Future<void> _fetchContacts() async {
    setState(() => _isLoading = true);
    try {
      final response = await _client.records.getList('contacts');
      setState(() {
        _contacts = response;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      _showSnackBar('خطا در دریافت مخاطبین: $e');
    }
  }

  Future<void> _addContact() async {
    final name = _nameController.text.trim();
    final phone = _phoneController.text.trim();

    if (name.isEmpty || phone.isEmpty) {
      _showSnackBar('لطفاً نام و شماره تلفن را وارد کنید.');
      return;
    }

    try {
      await _client.records.create(
        'contacts',
        body: {'name': name, 'phone': phone, 'is_favorite': false},
      );
      _nameController.clear();
      _phoneController.clear();
      if (mounted) Navigator.pop(context);
      _fetchContacts();
      _showSnackBar('مخاطب با موفقیت ذخیره شد.');
    } catch (e) {
      _showSnackBar('خطا در ثبت مخاطب: $e');
    }
  }

  Future<void> _deleteContact(String recordId) async {
    try {
      await _client.records.delete('contacts', recordId);
      _fetchContacts();
      _showSnackBar('مخاطب حذف شد.');
    } catch (e) {
      _showSnackBar('خطا در حذف مخاطب: $e');
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  void _openAddContactModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          top: 20,
          left: 20,
          right: 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'افزودن مخاطب جدید',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'نام و نام خانوادگی',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'شماره تلفن',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _addContact,
              child: const Text('ذخیره مخاطب'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _client.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('دفترچه مخاطبین (Upupa SDK)'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchContacts,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _contacts.isEmpty
          ? const Center(child: Text('هیچ مخاطبی یافت نشد.'))
          : ListView.builder(
              itemCount: _contacts.length,
              itemBuilder: (context, index) {
                final contact = _contacts[index];
                final name = contact.data['name'] ?? 'بدون نام';
                final phone = contact.data['phone'] ?? 'بدون شماره';

                return ListTile(
                  leading: CircleAvatar(
                    child: Text(name.isNotEmpty ? name[0] : '?'),
                  ),
                  title: Text(name),
                  subtitle: Text(phone),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _deleteContact(contact.id),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openAddContactModal,
        child: const Icon(Icons.add),
      ),
    );
  }
}
