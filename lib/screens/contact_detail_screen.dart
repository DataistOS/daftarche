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
    if (contact.company != null && contact.company!.isNotEmpty) {
      buffer.writeln('ORG:${contact.company}');
    }
    if (contact.jobTitle != null && contact.jobTitle!.isNotEmpty) {
      buffer.writeln('TITLE:${contact.jobTitle}');
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

  @override
  Widget build(BuildContext context) {
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
                if (contact.jobTitle != null || contact.company != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    [
                      contact.jobTitle,
                      contact.company,
                    ].where((e) => e != null && e!.isNotEmpty).join(' در '),
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                ],
                if (contact.group != null && contact.group!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Chip(
                    label: Text(contact.group!),
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
                trailing: IconButton(
                  icon: const Icon(Icons.message, color: Colors.blue),
                  onPressed: () {},
                  tooltip: 'ارسال پیام',
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // بخش ایمیل‌ها
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

          if (contact.notes != null && contact.notes!.isNotEmpty) ...[
            const Text(
              'یادداشت‌ها و نکات',
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
              child: Text(contact.notes!),
            ),
          ],
        ],
      ),
    );
  }
}
