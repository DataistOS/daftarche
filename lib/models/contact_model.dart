// lib/models/contact_model.dart

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
  final Map<String, String> socialLinks;
  final String? group;
  final List<String> tags;
  final String? notes;
  final bool isFavorite;

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
    this.socialLinks = const {},
    this.group,
    this.tags = const [],
    this.notes,
    this.isFavorite = false,
  }) : assert(phones.isNotEmpty, 'At least one phone number is required.');

  factory ContactModel.fromMap(String id, Map<String, dynamic> data) {
    return ContactModel(
      id: id,
      name: data['name'] ?? 'بدون نام',
      phones: List<String>.from(
        data['phones'] ?? (data['phone'] != null ? [data['phone']] : []),
      ),
      emails: List<String>.from(data['emails'] ?? []),
      company: data['company'],
      jobTitle: data['job_title'],
      address: data['address'],
      locationUrl: data['location_url'],
      birthDate: data['birth_date'] != null
          ? DateTime.tryParse(data['birth_date'])
          : null,
      socialLinks: Map<String, String>.from(data['social_links'] ?? {}),
      group: data['group'],
      tags: List<String>.from(data['tags'] ?? []),
      notes: data['notes'],
      isFavorite: data['is_favorite'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'phones': phones,
      'emails': emails,
      'company': company,
      'job_title': jobTitle,
      'address': address,
      'location_url': locationUrl,
      'birth_date': birthDate?.toIso8601String(),
      'social_links': socialLinks,
      'group': group,
      'tags': tags,
      'notes': notes,
      'is_favorite': isFavorite,
    };
  }

  ContactModel copyWith({
    String? name,
    List<String>? phones,
    List<String>? emails,
    String? company,
    String? jobTitle,
    String? address,
    String? locationUrl,
    DateTime? birthDate,
    Map<String, String>? socialLinks,
    String? group,
    List<String>? tags,
    String? notes,
    bool? isFavorite,
  }) {
    return ContactModel(
      id: id,
      name: name ?? this.name,
      phones: phones ?? this.phones,
      emails: emails ?? this.emails,
      company: company ?? this.company,
      jobTitle: jobTitle ?? this.jobTitle,
      address: address ?? this.address,
      locationUrl: locationUrl ?? this.locationUrl,
      birthDate: birthDate ?? this.birthDate,
      socialLinks: socialLinks ?? this.socialLinks,
      group: group ?? this.group,
      tags: tags ?? this.tags,
      notes: notes ?? this.notes,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }
}
