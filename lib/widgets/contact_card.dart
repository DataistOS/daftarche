// lib/widgets/contact_card.dart
import 'dart:io';
import 'package:flutter/material.dart';
import '../models/contact_model.dart';

class ContactCard extends StatelessWidget {
  final ContactModel contact;
  final VoidCallback onTap;
  final VoidCallback onFavoriteToggle;
  final VoidCallback onDelete;

  const ContactCard({
    super.key,
    required this.contact,
    required this.onTap,
    required this.onFavoriteToggle,
    required this.onDelete,
  });

  ImageProvider? _resolveAvatarImage() {
    final path = contact.avatarPath;
    if (path == null || path.isEmpty) return null;
    if (path.startsWith('http://') || path.startsWith('https://')) {
      return NetworkImage(path);
    }
    final file = File(path);
    if (file.existsSync()) {
      return FileImage(file);
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final borderColor = isDark ? Colors.grey.shade800 : Colors.grey.shade200;
    final subtitleColor = isDark ? Colors.grey.shade300 : Colors.grey.shade700;
    final avatarBgColor = isDark ? Colors.teal.shade900 : Colors.teal.shade100;
    final avatarTextColor = isDark
        ? Colors.teal.shade200
        : Colors.teal.shade800;

    final name = (contact.name.isNotEmpty) ? contact.name : 'بدون نام';
    final firstLetter = name.isNotEmpty ? name[0] : '?';
    final avatarImage = _resolveAvatarImage();

    final phone = (contact.phones.isNotEmpty && contact.phones.first.isNotEmpty)
        ? contact.phones.first
        : 'بدون شماره';

    final subtitleText = [
      phone,
      contact.company,
      contact.finglish,
    ].where((e) => e != null && e.isNotEmpty).join(' • ');

    return Card(
      elevation: 0,
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: borderColor),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: CircleAvatar(
          backgroundColor: avatarBgColor,
          backgroundImage: avatarImage,
          child: avatarImage == null
              ? Text(
                  firstLetter,
                  style: TextStyle(
                    color: avatarTextColor,
                    fontWeight: FontWeight.bold,
                  ),
                )
              : null,
        ),
        title: Text(
          name,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4.0),
          child: Text(
            subtitleText,
            style: TextStyle(color: subtitleColor, fontSize: 13),
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(
                contact.isFavorite ? Icons.star : Icons.star_border,
                color: contact.isFavorite ? Colors.amber : Colors.grey,
              ),
              onPressed: onFavoriteToggle,
              tooltip: 'نشان کردن به عنوان برگزیده',
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
              onPressed: onDelete,
              tooltip: 'حذف مخاطب',
            ),
          ],
        ),
        onTap: onTap,
      ),
    );
  }
}
