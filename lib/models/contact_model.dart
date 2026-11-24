// lib/models/contact_model.dart
import 'dart:convert';

class InteractionModel {
  final String id;
  final DateTime date;
  final String type;
  final String description;

  InteractionModel({
    required this.id,
    required this.date,
    required this.type,
    required this.description,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'type': type,
      'description': description,
    };
  }

  factory InteractionModel.fromMap(Map<String, dynamic> map) {
    return InteractionModel(
      id: map['id']?.toString() ?? '',
      date: map['date'] != null
          ? (DateTime.tryParse(map['date'].toString()) ?? DateTime.now())
          : DateTime.now(),
      type: map['type']?.toString() ?? '',
      description: map['description']?.toString() ?? '',
    );
  }
}

class ContactModel {
  final String id;
  final String name;
  final String? finglish;
  final String? avatarPath;
  final List<String> phones;
  final List<String> emails;
  final String? company;
  final String? jobTitle;
  final String? address;
  final String? locationUrl;
  final DateTime? birthDate;
  final String? group;
  final List<String> tags;
  final String? notes;
  final bool isFavorite;
  final List<InteractionModel> interactions;

  ContactModel({
    required this.id,
    required this.name,
    this.finglish,
    this.avatarPath,
    required this.phones,
    this.emails = const [],
    this.company,
    this.jobTitle,
    this.address,
    this.locationUrl,
    this.birthDate,
    this.group,
    this.tags = const [],
    this.notes,
    this.isFavorite = false,
    this.interactions = const [],
  });

  Map<String, dynamic> toMap() {
    return {
      'Name': name,
      'Finglish': finglish ?? '',
      'Avatarpath': avatarPath ?? '',
      'Phones': phones.join(','),
      'Emails': emails.join(','),
      'Company': company ?? '',
      'Jobtitle': jobTitle ?? '',
      'Address': address ?? '',
      'Locationurl': locationUrl ?? '',
      'Birthdate': birthDate?.toIso8601String() ?? '',
      'Group': group ?? '',
      'Tags': tags.join(','),
      'Notes': notes ?? '',
      'Isfavorite': isFavorite,
      'Interactions': jsonEncode(interactions.map((e) => e.toMap()).toList()),
    };
  }

  factory ContactModel.fromMap(String id, Map<String, dynamic> map) {
    dynamic readField(String pascalKey, String camelKey) {
      return map.containsKey(pascalKey) ? map[pascalKey] : map[camelKey];
    }

    String? parseNullableString(dynamic val) {
      if (val == null) return null;
      final str = val.toString().trim();
      return str.isEmpty ? null : str;
    }

    List<String> parseStringToList(dynamic val) {
      if (val == null) return [];
      if (val is List) {
        return val
            .map((e) => e.toString().trim())
            .where((e) => e.isNotEmpty)
            .toList();
      }
      if (val is String && val.isNotEmpty) {
        return val
            .split(',')
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList();
      }
      return [];
    }

    bool parseBool(dynamic val) {
      if (val is bool) return val;
      if (val is String) return val.toLowerCase() == 'true' || val == '1';
      if (val is num) return val != 0;
      return false;
    }

    List<InteractionModel> parseInteractions(dynamic val) {
      if (val == null) return [];
      if (val is List) {
        return val
            .whereType()
            .map(
              (item) =>
                  InteractionModel.fromMap(Map<String, dynamic>.from(item)),
            )
            .toList();
      }
      if (val is String) {
        final trimmed = val.trim();
        if (trimmed.isEmpty || trimmed == '[]') return [];
        try {
          final decoded = jsonDecode(trimmed);
          if (decoded is List) {
            return decoded
                .whereType()
                .map(
                  (item) =>
                      InteractionModel.fromMap(Map<String, dynamic>.from(item)),
                )
                .toList();
          }
        } catch (_) {
          return [
            InteractionModel(
              id: '${id}_legacy_0',
              date: DateTime.now(),
              type: 'تعامل',
              description: trimmed,
            ),
          ];
        }
      }
      return [];
    }

    final rawBirthDate = readField('Birthdate', 'birthDate');

    return ContactModel(
      id: id,
      name: readField('Name', 'name')?.toString() ?? '',
      finglish: parseNullableString(readField('Finglish', 'finglish')),
      avatarPath: parseNullableString(readField('Avatarpath', 'avatarPath')),
      phones: parseStringToList(readField('Phones', 'phones')),
      emails: parseStringToList(readField('Emails', 'emails')),
      company: parseNullableString(readField('Company', 'company')),
      jobTitle: parseNullableString(readField('Jobtitle', 'jobTitle')),
      address: parseNullableString(readField('Address', 'address')),
      locationUrl: parseNullableString(readField('Locationurl', 'locationUrl')),
      birthDate: rawBirthDate != null && rawBirthDate.toString().isNotEmpty
          ? DateTime.tryParse(rawBirthDate.toString())
          : null,
      group: parseNullableString(readField('Group', 'group')),
      tags: parseStringToList(readField('Tags', 'tags')),
      notes: parseNullableString(readField('Notes', 'notes')),
      isFavorite: parseBool(readField('Isfavorite', 'isFavorite')),
      interactions: parseInteractions(
        readField('Interactions', 'interactions'),
      ),
    );
  }

  ContactModel copyWith({
    String? id,
    String? name,
    String? finglish,
    String? avatarPath,
    List<String>? phones,
    List<String>? emails,
    String? company,
    String? jobTitle,
    String? address,
    String? locationUrl,
    DateTime? birthDate,
    String? group,
    List<String>? tags,
    String? notes,
    bool? isFavorite,
    List<InteractionModel>? interactions,
  }) {
    return ContactModel(
      id: id ?? this.id,
      name: name ?? this.name,
      finglish: finglish ?? this.finglish,
      avatarPath: avatarPath ?? this.avatarPath,
      phones: phones ?? this.phones,
      emails: emails ?? this.emails,
      company: company ?? this.company,
      jobTitle: jobTitle ?? this.jobTitle,
      address: address ?? this.address,
      locationUrl: locationUrl ?? this.locationUrl,
      birthDate: birthDate ?? this.birthDate,
      group: group ?? this.group,
      tags: tags ?? this.tags,
      notes: notes ?? this.notes,
      isFavorite: isFavorite ?? this.isFavorite,
      interactions: interactions ?? this.interactions,
    );
  }
}
