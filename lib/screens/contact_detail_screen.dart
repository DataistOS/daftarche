// lib/screens/contact_detail_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
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
          if (Navigator.canPop(context)) {
            Navigator.pop(context);
          }
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

  ImageProvider? _resolveAvatarImage() {
    final path = contact.avatarPath?.trim();
    if (path == null || path.isEmpty) return null;

    if (path.startsWith('http://') || path.startsWith('https://')) {
      return NetworkImage(path);
    }

    final file = File(path);
    if (file.existsSync()) {
      return FileImage(file);
    }

    final baseUrl = dotenv.env['UPUPA_BASE_URL'] ?? dotenv.env['API_BASE_URL'];
    if (baseUrl != null && baseUrl.trim().isNotEmpty) {
      final normalizedBase = baseUrl.trim().replaceAll(RegExp(r'/+$'), '');
      final normalizedPath = path.replaceAll(RegExp(r'^/+'), '');
      return NetworkImage('$normalizedBase/$normalizedPath');
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBgColor = isDark ? const Color(0xFF1E2926) : Colors.grey.shade100;
    final cardTextColor = isDark ? Colors.white : Colors.black87;
    final subtleTextColor = isDark
        ? Colors.grey.shade300
        : Colors.grey.shade700;

    final groupBgColor = isDark
        ? Colors.teal.shade900.withValues(alpha: 0.6)
        : Colors.teal.shade50;
    final groupTextColor = isDark ? Colors.teal.shade200 : Colors.teal.shade900;

    final tagBgColor = isDark
        ? Colors.blue.shade900.withValues(alpha: 0.5)
        : Colors.blue.shade50;
    final tagTextColor = isDark ? Colors.blue.shade200 : Colors.blue.shade900;

    final interactionBgColor = isDark
        ? Colors.teal.shade900.withValues(alpha: 0.35)
        : Colors.teal.shade50.withValues(alpha: 0.5);

    final noteBgColor = isDark
        ? Colors.amber.shade900.withValues(alpha: 0.3)
        : Colors.amber.shade50;
    final noteBorderColor = isDark
        ? Colors.amber.shade700.withValues(alpha: 0.5)
        : Colors.amber.shade200;
    final noteTextColor = isDark ? Colors.amber.shade100 : Colors.black87;

    final finglish = contact.finglish;
    final avatarPath = contact.avatarPath;
    final avatarImage = _resolveAvatarImage();
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
                  backgroundImage: avatarImage,
                  child: avatarImage == null
                      ? Text(
                          contact.name.isNotEmpty ? contact.name[0] : '?',
                          style: const TextStyle(fontSize: 32),
                        )
                      : null,
                ),
                const SizedBox(height: 12),
                Text(
                  contact.name,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (finglish != null && finglish.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    finglish,
                    style: TextStyle(fontSize: 13, color: subtleTextColor),
                  ),
                ],
                if (jobTitle != null || company != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    [
                      jobTitle,
                      company,
                    ].where((e) => e != null && e.isNotEmpty).join(' در '),
                    style: TextStyle(fontSize: 14, color: subtleTextColor),
                  ),
                ],
                if (group != null && group.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Chip(
                    label: Text(group),
                    backgroundColor: groupBgColor,
                    labelStyle: TextStyle(color: groupTextColor),
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
              color: cardBgColor,
              child: ListTile(
                leading: const Icon(Icons.phone, color: Colors.teal),
                title: Text(
                  phone,
                  style: TextStyle(fontSize: 16, color: cardTextColor),
                ),
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
                title: Text(email, style: TextStyle(color: cardTextColor)),
              ),
            ),
            const SizedBox(height: 16),
          ],

          if ((address != null && address.isNotEmpty) ||
              (locationUrl != null && locationUrl.isNotEmpty)) ...[
            const Text(
              'آدرس پستی و نقشه',
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.teal),
            ),
            const SizedBox(height: 8),
            Card(
              elevation: 0,
              color: cardBgColor,
              child: ListTile(
                leading: const Icon(Icons.location_on, color: Colors.teal),
                title: Text(
                  (address != null && address.isNotEmpty)
                      ? address
                      : 'لینک موقعیت مکانی',
                  style: TextStyle(color: cardTextColor),
                ),
                subtitle: (locationUrl != null && locationUrl.isNotEmpty)
                    ? SelectableText(
                        locationUrl,
                        style: TextStyle(
                          color: isDark
                              ? Colors.lightBlue.shade300
                              : Colors.blue.shade700,
                        ),
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
              color: cardBgColor,
              child: ListTile(
                leading: const Icon(Icons.cake, color: Colors.teal),
                title: Text(
                  contact.birthDate!.toLocal().toString().split(' ')[0],
                  style: TextStyle(color: cardTextColor),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],

          if (avatarPath != null && avatarPath.isNotEmpty) ...[
            const Text(
              'مسیر آواتار',
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.teal),
            ),
            const SizedBox(height: 8),
            Card(
              elevation: 0,
              color: cardBgColor,
              child: ListTile(
                leading: const Icon(Icons.image, color: Colors.teal),
                title: SelectableText(
                  avatarPath,
                  style: TextStyle(fontSize: 13, color: subtleTextColor),
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
                      backgroundColor: tagBgColor,
                      labelStyle: TextStyle(color: tagTextColor),
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
            Text(
              'هنوز تعاملی ثبت نشده است.',
              style: TextStyle(color: subtleTextColor, fontSize: 13),
            )
          else
            ...contact.interactions.map(
              (interaction) => Card(
                elevation: 0,
                color: interactionBgColor,
                child: ListTile(
                  leading: const Icon(Icons.history, color: Colors.teal),
                  title: Text(
                    interaction.type,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: cardTextColor,
                    ),
                  ),
                  subtitle: Text(
                    interaction.description,
                    style: TextStyle(color: subtleTextColor),
                  ),
                  trailing: Text(
                    interaction.date.toLocal().toString().split(' ')[0],
                    style: TextStyle(fontSize: 12, color: subtleTextColor),
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
                color: noteBgColor,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: noteBorderColor),
              ),
              child: Text(notes, style: TextStyle(color: noteTextColor)),
            ),
          ],
        ],
      ),
    );
  }
}
