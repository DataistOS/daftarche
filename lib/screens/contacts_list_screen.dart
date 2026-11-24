// lib/screens/contacts_list_screen.dart
import 'package:flutter/material.dart';
import '../models/contact_model.dart';
import '../services/contact_service.dart';
import '../widgets/contact_form_sheet.dart';
import '../widgets/contact_card.dart';
import 'contact_detail_screen.dart';
import '../main.dart';

class ContactsListScreen extends StatefulWidget {
  const ContactsListScreen({super.key});

  @override
  State<ContactsListScreen> createState() => _ContactsListScreenState();
}

class _ContactsListScreenState extends State<ContactsListScreen> {
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
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final contacts = await _contactService.fetchContacts();
      if (!mounted) return;
      setState(() {
        _contacts = contacts;
        _filterContacts();
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      _showSnackBar(e.toString());
    }
  }

  void _filterContacts() {
    final query = _searchController.text.trim().toLowerCase();
    setState(() {
      _filteredContacts = _contacts.where((contact) {
        if (_showFavoritesOnly && !contact.isFavorite) return false;

        if (_selectedGroupFilter != null && _selectedGroupFilter != 'همه') {
          if (contact.group != _selectedGroupFilter) return false;
        }

        if (query.isEmpty) return true;

        final nameMatch = contact.name.toLowerCase().contains(query);
        final finglishMatch =
            contact.finglish?.toLowerCase().contains(query) ?? false;
        final companyMatch =
            contact.company?.toLowerCase().contains(query) ?? false;
        final phoneMatch = contact.phones.any((p) => p.contains(query));

        return nameMatch || finglishMatch || companyMatch || phoneMatch;
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
      await _loadContacts();
    } catch (e) {
      _showSnackBar(e.toString());
    }
  }

  Future<void> _handleDeleteContact(String recordId) async {
    try {
      await _contactService.deleteContact(recordId);
      await _loadContacts();
      _showSnackBar('مخاطب حذف شد.');
    } catch (e) {
      _showSnackBar(e.toString());
    }
  }

  Future<void> _toggleFavorite(ContactModel contact) async {
    final updated = contact.copyWith(isFavorite: !contact.isFavorite);
    try {
      await _contactService.updateContact(updated);
      await _loadContacts();
    } catch (e) {
      _showSnackBar(e.toString());
    }
  }

  void _showSnackBar(String message) {
    if (!mounted) return;
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

  Map<String, int> _calculateStats() {
    int total = _contacts.length;
    int favorites = _contacts.where((c) => c.isFavorite).length;
    int totalInteractions = _contacts.fold(
      0,
      (sum, c) => sum + c.interactions.length,
    );
    return {
      'total': total,
      'favorites': favorites,
      'interactions': totalInteractions,
    };
  }

  @override
  void dispose() {
    _searchController.dispose();
    _contactService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final stats = _calculateStats();

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'دفترچه',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          centerTitle: false,
          actions: [
            IconButton(
              icon: Icon(
                themeNotifier.value == ThemeMode.dark
                    ? Icons.light_mode
                    : Icons.dark_mode,
              ),
              onPressed: () {
                setState(() {
                  themeNotifier.value = themeNotifier.value == ThemeMode.dark
                      ? ThemeMode.light
                      : ThemeMode.dark;
                });
              },
              tooltip: 'تغییر حالت تم',
            ),
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
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _loadContacts,
              tooltip: 'بارگذاری مجدد',
            ),
          ],
        ),
        body: Column(
          children: [
            if (!_isLoading && _contacts.isNotEmpty)
              Container(
                margin: const EdgeInsets.all(12.0),
                padding: const EdgeInsets.all(12.0),
                decoration: BoxDecoration(
                  color: Theme.of(
                    context,
                  ).colorScheme.primaryContainer.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Theme.of(
                      context,
                    ).colorScheme.primary.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatItem(context, 'کل مخاطبین', '${stats['total']}'),
                    _buildStatItem(
                      context,
                      'برگزیده‌ها',
                      '${stats['favorites']}',
                    ),
                    _buildStatItem(
                      context,
                      'تعاملات ثبت‌شده',
                      '${stats['interactions']}',
                    ),
                  ],
                ),
              ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'جستجو بر اساس نام، فینگلیش، شرکت یا شماره...',
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
                  fillColor: Theme.of(context).cardColor,
                ),
              ),
            ),
            const SizedBox(height: 8),

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
                        return ContactCard(
                          contact: contact,
                          onFavoriteToggle: () => _toggleFavorite(contact),
                          onDelete: () => _handleDeleteContact(contact.id),
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
      ),
    );
  }

  Widget _buildStatItem(BuildContext context, String label, String value) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
