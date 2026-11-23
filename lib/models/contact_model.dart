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

    List<String> parseStringToList(dynamic val) {
      if (val == null) return [];
      if (val is List) return val.map((e) => e.toString()).toList();
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
      try {
        final decoded = val is String ? jsonDecode(val) : val;
        if (decoded is List) {
          return decoded
              .whereType()
              .map(
                (item) =>
                    InteractionModel.fromMap(Map<String, dynamic>.from(item)),
              )
              .toList();
        }
      } catch (_) {}
      return [];
    }

    final rawBirthDate = readField('Birthdate', 'birthDate');

    return ContactModel(
      id: id,
      name: readField('Name', 'name')?.toString() ?? '',
      phones: parseStringToList(readField('Phones', 'phones')),
      emails: parseStringToList(readField('Emails', 'emails')),
      company: readField('Company', 'company')?.toString(),
      jobTitle: readField('Jobtitle', 'jobTitle')?.toString(),
      address: readField('Address', 'address')?.toString(),
      locationUrl: readField('Locationurl', 'locationUrl')?.toString(),
      birthDate: rawBirthDate != null && rawBirthDate.toString().isNotEmpty
          ? DateTime.tryParse(rawBirthDate.toString())
          : null,
      group: readField('Group', 'group')?.toString(),
      tags: parseStringToList(readField('Tags', 'tags')),
      notes: readField('Notes', 'notes')?.toString(),
      isFavorite: parseBool(readField('Isfavorite', 'isFavorite')),
      interactions: parseInteractions(
        readField('Interactions', 'interactions'),
      ),
    );
  }

  ContactModel copyWith({
    String? id,
    String? name,
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
