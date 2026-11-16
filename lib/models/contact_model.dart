// lib/models/contact_model.dart
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
      id: map['id'] ?? '',
      date: map['date'] != null ? DateTime.parse(map['date']) : DateTime.now(),
      type: map['type'] ?? '',
      description: map['description'] ?? '',
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
      'name': name,
      'phones': phones.join(','),
      'emails': emails.join(','),
      'company': company,
      'jobTitle': jobTitle,
      'address': address,
      'locationUrl': locationUrl,
      'birthDate': birthDate?.toIso8601String(),
      'group': group,
      'tags': tags.join(','),
      'notes': notes,
      'isFavorite': isFavorite,
    };
  }

  factory ContactModel.fromMap(String id, Map<String, dynamic> map) {
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

    return ContactModel(
      id: id,
      name: map['name'] ?? '',
      phones: parseStringToList(map['phones']),
      emails: parseStringToList(map['emails']),
      company: map['company'],
      jobTitle: map['jobTitle'],
      address: map['address'],
      locationUrl: map['locationUrl'],
      birthDate: map['birthDate'] != null
          ? DateTime.tryParse(map['birthDate'])
          : null,
      group: map['group'],
      tags: parseStringToList(map['tags']),
      notes: map['notes'],
      isFavorite: map['isFavorite'] ?? false,
      interactions: [],
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
