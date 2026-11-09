// lib/screens/contacts_screen.dart
import 'package:flutter/material.dart';
import 'package:upupa_dart/upupa_dart.dart';
import '../screens/contacts_screen.dart';

class ContactsScreen extends StatefulWidget {
  const ContactsScreen({super.key});

  @override
  State<ContactsScreen> createState() => _ContactsScreenState();
}

class _ContactsScreenState extends State<ContactsScreen> {
  final ContactService _contactService = ContactService();
  List<Record> _contacts = [];
  bool _isLoading = true;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadContacts();
  }

  Future<void> _loadContacts() async {
    setState(() => _isLoading = true);
    try {
      final contacts = await _contactService.fetchContacts();
      setState(() {
        _contacts = contacts;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      _showSnackBar(e.toString());
    }
  }

  Future<void> _handleAddNewContact() async {
    final name = _nameController.text.trim();
    final phone = _phoneController.text.trim();

    if (name.isEmpty || phone.isEmpty) {
      _showSnackBar('لطفاً نام و شماره تلفن را وارد کنید.');
      return;
    }

    try {
      await _contactService.addContact(name, phone);
      _nameController.clear();
      _phoneController.clear();
      if (mounted) Navigator.pop(context);
      _loadContacts();
      _showSnackBar('مخاطب با موفقیت ذخیره شد.');
    } catch (e) {
      _showSnackBar(e.toString());
    }
  }

  Future<void> _handleDeleteContact(String recordId) async {
    try {
      await _contactService.deleteContact(recordId);
      _loadContacts();
      _showSnackBar('مخاطب حذف شد.');
    } catch (e) {
      _showSnackBar(e.toString());
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
              onPressed: _handleAddNewContact,
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
    _contactService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('دفترچه مخاطبین (Modular)'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadContacts),
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
                    onPressed: () => _handleDeleteContact(contact.id),
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
