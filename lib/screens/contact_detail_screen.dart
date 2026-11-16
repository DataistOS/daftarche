// lib/screens/contact_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../models/contact_model.dart';
import '../widgets/contact_form_sheet.dart';

class ContactDetailScreen extends StatelessWidget {
  final ContactModel contact;
  final Function(ContactModel) onUpdate;

  const ContactDetailScreen({
    super.key,
    required this.contact,
    required this.onUpdate,
  });

  String _generateVCardString() {
    final buffer = StringBuffer();
    buffer.writeln('BEGIN:VCARD');
    buffer.writeln('VERSION:3.0');
    buffer.writeln('FN:${contact.name}');
    if (contact.phones.isNotEmpty) {
      buffer.writeln('TEL:${contact.phones.first}');
    }
    if (contact.emails.isNotEmpty) {
      buffer.writeln('EMAIL:${contact.emails.first}');
    }
    final company = contact.company;
    if (company != null && company.isNotEmpty) {
      buffer.writeln('ORG:$company');
    }
    final jobTitle = contact.jobTitle;
    if (jobTitle != null && jobTitle.isNotEmpty) {
      buffer.writeln('TITLE:$jobTitle');
    }
    buffer.writeln('END:VCARD');
    return buffer.toString();
  }

  void _openEditModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => ContactFormSheet(
        initialContact: contact,
        onSave: (updatedContact) {
          onUpdate(updatedContact);
          Navigator.pop(context);
        },
      ),
    );
  }

  void _showQRCodeModal(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('کارت ویزیت: ${contact.name}', textAlign: TextAlign.center),
        content: SizedBox(
          width: 250,
          height: 250,
          child: Center(
            child: QrImageView(
              data: _generateVCardString(),
              version: QrVersions.auto,
              size: 220.0,
              gapless: false,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('بستن'),
          ),
        ],
      ),
    );
  }

  void _showAddInteractionDialog(BuildContext context) {
    final typeController = TextEditingController(text: 'تماس');
    final descController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('ثبت تعامل جدید'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: typeController,
              decoration: const InputDecoration(
                labelText: 'نوع تعامل (مثلاً: تماس، جلسه، دیدار)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: descController,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'توضیحات و جزئیات',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('لغو'),
          ),
          ElevatedButton(
            onPressed: () {
              if (descController.text.isNotEmpty) {
                final newInteraction = InteractionModel(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  date: DateTime.now(),
                  type: typeController.text.trim(),
                  description: descController.text.trim(),
                );
                final updatedInteractions = [
                  ...contact.interactions,
                  newInteraction,
                ];
                final updatedContact = contact.copyWith(
                  interactions: updatedInteractions,
                );
                onUpdate(updatedContact);
                Navigator.pop(context);
              }
            },
            child: const Text('ثبت'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final jobTitle = contact.jobTitle;
    final company = contact.company;
    final group = contact.group;
    final address = contact.address;
    final locationUrl = contact.locationUrl;
    final notes = contact.notes;

    return Scaffold(
      appBar: AppBar(
        title: Text(contact.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.qr_code_2),
            onPressed: () => _showQRCodeModal(context),
            tooltip: 'کارت ویزیت دیجیتال',
          ),
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => _openEditModal(context),
            tooltip: 'ویرایش مخاطب',
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          Center(
            child: Column(
              children: [
                CircleAvatar(
                  radius: 40,
                  child: Text(
                    contact.name.isNotEmpty ? contact.name[0] : '?',
                    style: const TextStyle(fontSize: 32),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  contact.name,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (jobTitle != null || company != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    [
                      jobTitle,
                      company,
                    ].where((e) => e != null && e.isNotEmpty).join(' در '),
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                ],
                if (group != null && group.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Chip(
                    label: Text(group),
                    backgroundColor: Colors.teal.shade50,
                    labelStyle: TextStyle(color: Colors.teal.shade800),
                  ),
                ],
              ],
            ),
          ),
          const Divider(height: 32),

          const Text(
            'شماره‌های تماس',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.teal),
          ),
          const SizedBox(height: 8),
          ...contact.phones.map(
            (phone) => Card(
              elevation: 0,
              color: Colors.grey[100],
              child: ListTile(
                leading: const Icon(Icons.phone, color: Colors.teal),
                title: Text(phone, style: const TextStyle(fontSize: 16)),
              ),
            ),
          ),
          const SizedBox(height: 16),

          if (contact.emails.isNotEmpty) ...[
            const Text(
              'ایمیل‌ها',
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.teal),
            ),
            const SizedBox(height: 8),
            ...contact.emails.map(
              (email) => ListTile(
                leading: const Icon(Icons.email, color: Colors.teal),
                title: Text(email),
              ),
            ),
            const SizedBox(height: 16),
          ],

          if (address != null && address.isNotEmpty) ...[
            const Text(
              'آدرس پستی',
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.teal),
            ),
            const SizedBox(height: 8),
            Card(
              elevation: 0,
              color: Colors.grey[100],
              child: ListTile(
                leading: const Icon(Icons.location_on, color: Colors.teal),
                title: Text(address),
                subtitle: locationUrl != null && locationUrl.isNotEmpty
                    ? Text(
                        locationUrl,
                        style: TextStyle(color: Colors.blue[700]),
                      )
                    : null,
              ),
            ),
            const SizedBox(height: 16),
          ],

          if (contact.birthDate != null) ...[
            const Text(
              'تاریخ تولد',
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.teal),
            ),
            const SizedBox(height: 8),
            Card(
              elevation: 0,
              color: Colors.grey[100],
              child: ListTile(
                leading: const Icon(Icons.cake, color: Colors.teal),
                title: Text(
                  contact.birthDate!.toLocal().toString().split(' ')[0],
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],

          if (contact.tags.isNotEmpty) ...[
            const Text(
              'برچسب‌ها',
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.teal),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8.0,
              children: contact.tags
                  .map(
                    (tag) => Chip(
                      label: Text(tag),
                      backgroundColor: Colors.blue.shade50,
                      labelStyle: TextStyle(color: Colors.blue.shade800),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 16),
          ],

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'تاریخچه تعاملات و یادداشت‌ها',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.teal,
                ),
              ),
              TextButton.icon(
                onPressed: () => _showAddInteractionDialog(context),
                icon: const Icon(Icons.add, size: 18),
                label: const Text('ثبت تعامل'),
              ),
            ],
          ),
          const SizedBox(height: 4),
          if (contact.interactions.isEmpty)
            const Text(
              'هنوز تعاملی ثبت نشده است.',
              style: TextStyle(color: Colors.grey, fontSize: 13),
            )
          else
            ...contact.interactions.map(
              (interaction) => Card(
                elevation: 0,
                color: Colors.teal.shade50.withValues(alpha: 0.5),
                child: ListTile(
                  leading: const Icon(Icons.history, color: Colors.teal),
                  title: Text(
                    interaction.type,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(interaction.description),
                  trailing: Text(
                    interaction.date.toLocal().toString().split(' ')[0],
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ),
              ),
            ),
          const SizedBox(height: 16),

          if (notes != null && notes.isNotEmpty) ...[
            const Text(
              'یادداشت کلی',
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.teal),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.amber.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.amber.shade200),
              ),
              child: Text(notes),
            ),
          ],
        ],
      ),
    );
  }
}
