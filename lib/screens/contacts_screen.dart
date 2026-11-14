// lib/screens/contacts_screen.dart
import 'package:flutter/material.dart';
import '../models/contact_model.dart';
import '../services/contact_service.dart';
import '../widgets/contact_form_sheet.dart';
import 'contact_detail_screen.dart';

class ContactsScreen extends StatefulWidget {
  const ContactsScreen({super.key});

  @override
  State<ContactsScreen> createState() => _ContactsScreenState();
}

class _ContactsScreenState extends State<ContactsScreen> {
  final ContactService _contactService = ContactService();
  List<ContactModel> _contacts = [];
  List<ContactModel> _filteredContacts = [];
  bool _isLoading = true;
  bool _showFavoritesOnly = false;

  String? _selectedGroupFilter;
  final List<String> _availableGroups = [
    'همه',
    'خانواده',
    'دوستان',
    'همکاران',
    'مشتریان VIP',
  ];

  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadContacts();
    _searchController.addListener(_filterContacts);
  }

  Future<void> _loadContacts() async {
    setState(() => _isLoading = true);
    try {
      final contacts = await _contactService.fetchContacts();
      setState(() {
        _contacts = contacts;
        _filterContacts();
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      _showSnackBar(e.toString());
    }
  }

  void _filterContacts() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredContacts = _contacts.where((contact) {
        if (_showFavoritesOnly && !contact.isFavorite) return false;

        if (_selectedGroupFilter != null && _selectedGroupFilter != 'همه') {
          if (contact.group != _selectedGroupFilter) return false;
        }

        final nameMatch = contact.name.toLowerCase().contains(query);
        final companyMatch =
            contact.company?.toLowerCase().contains(query) ?? false;
        final phoneMatch = contact.phones.any((p) => p.contains(query));

        return nameMatch || companyMatch || phoneMatch;
      }).toList();
    });
  }

  Future<void> _handleSaveContact(ContactModel contact) async {
    try {
      if (contact.id.isEmpty) {
        await _contactService.addContact(contact);
        _showSnackBar('مخاطب با موفقیت ذخیره شد.');
      } else {
        await _contactService.updateContact(contact);
        _showSnackBar('مخاطب به‌روزرسانی شد.');
      }
      _loadContacts();
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

  Future<void> _toggleFavorite(ContactModel contact) async {
    final updated = contact.copyWith(isFavorite: !contact.isFavorite);
    try {
      await _contactService.updateContact(updated);
      _loadContacts();
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
      builder: (context) => ContactFormSheet(onSave: _handleSaveContact),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _contactService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('دفترچه مخاطبین (Pro)'),
        actions: [
          IconButton(
            icon: Icon(
              _showFavoritesOnly ? Icons.star : Icons.star_border,
              color: _showFavoritesOnly ? Colors.amber : null,
            ),
            onPressed: () {
              setState(() {
                _showFavoritesOnly = !_showFavoritesOnly;
                _filterContacts();
              });
            },
            tooltip: 'فقط برگزیده‌ها',
          ),
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadContacts),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'جستجو بر اساس نام، شرکت یا شماره...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _filterContacts();
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey[100],
              ),
            ),
          ),
          SizedBox(
            height: 45,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: _availableGroups.map((group) {
                final isSelected =
                    (_selectedGroupFilter == group) ||
                    (group == 'همه' && _selectedGroupFilter == null);
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: ChoiceChip(
                    label: Text(group),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        _selectedGroupFilter = group == 'همه' ? null : group;
                        _filterContacts();
                      });
                    },
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredContacts.isEmpty
                ? const Center(child: Text('هیچ مخاطبی یافت نشد.'))
                : ListView.builder(
                    itemCount: _filteredContacts.length,
                    itemBuilder: (context, index) {
                      final contact = _filteredContacts[index];
                      final name = contact.name;
                      final phone = contact.phones.isNotEmpty
                          ? contact.phones.first
                          : 'بدون شماره';

                      return ListTile(
                        leading: CircleAvatar(
                          child: Text(name.isNotEmpty ? name[0] : '?'),
                        ),
                        title: Text(
                          name,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          [
                            phone,
                            contact.company,
                          ].where((e) => e != null && e.isNotEmpty).join(' • '),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(
                                contact.isFavorite
                                    ? Icons.star
                                    : Icons.star_border,
                                color: contact.isFavorite
                                    ? Colors.amber
                                    : Colors.grey,
                              ),
                              onPressed: () => _toggleFavorite(contact),
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.delete_outline,
                                color: Colors.red,
                              ),
                              onPressed: () => _handleDeleteContact(contact.id),
                            ),
                          ],
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ContactDetailScreen(
                                contact: contact,
                                onUpdate: _handleSaveContact,
                              ),
                            ),
                          ).then((_) => _loadContacts());
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openAddContactModal,
        child: const Icon(Icons.add),
      ),
    );
  }
}
