// lib/services/contact_service.dart
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:upupa_dart/upupa_dart.dart';
import '../models/contact_model.dart';

class ContactService {
  final String _baseUrl = dotenv.env['API_URL'] ?? 'http://127.0.0.1:8090';
  final UpupaClient client;
  final http.Client _httpClient;

  ContactService({UpupaClient? client, http.Client? httpClient})
    : client =
          client ??
          UpupaClient(dotenv.env['API_URL'] ?? 'http://127.0.0.1:8090'),
      _httpClient = httpClient ?? http.Client();

  Map<String, String> _buildHeaders() {
    final headers = <String, String>{'Content-Type': 'application/json'};
    if (client.authStore.isValid && client.authStore.token != null) {
      headers['Authorization'] = 'Bearer ${client.authStore.token}';
    }
    return headers;
  }

  Future<List<ContactModel>> fetchContacts() async {
    try {
      final response = await client.records.getList('daftarche');
      return response.map((record) {
        return ContactModel.fromMap(record.id, record.data);
      }).toList();
    } catch (e) {
      throw 'خطا در دریافت مخاطبین: $e';
    }
  }

  Future<void> addContact(ContactModel contact) async {
    try {
      await client.records.create('daftarche', contact.toMap());
    } catch (e) {
      throw 'خطا در ثبت مخاطب: $e';
    }
  }

  Future<void> updateContact(ContactModel contact) async {
    try {
      final uri = Uri.parse(
        '$_baseUrl/api/v1/collections/daftarche/records/${contact.id}',
      );
      final payload = jsonEncode({'data': contact.toMap()});
      final headers = _buildHeaders();

      var response = await _httpClient.patch(
        uri,
        headers: headers,
        body: payload,
      );

      if (response.statusCode == 405) {
        response = await _httpClient.put(uri, headers: headers, body: payload);
      }

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw 'خطای سرور (${response.statusCode}): ${response.body}';
      }
    } catch (e) {
      throw 'خطا در به‌روزرسانی مخاطب: $e';
    }
  }

  Future<void> deleteContact(String recordId) async {
    try {
      await client.records.delete('daftarche', recordId);
    } catch (e) {
      throw 'خطا در حذف مخاطب: $e';
    }
  }

  // --- Smart Utilities: Duplicate Merging ---
  Future<int> mergeDuplicates() async {
    try {
      final contacts = await fetchContacts();
      final Map<String, ContactModel> uniqueMap = {};
      int mergedCount = 0;

      for (var contact in contacts) {
        final key = contact.phones.isNotEmpty
            ? contact.phones.first.trim()
            : contact.name.trim();

        if (uniqueMap.containsKey(key)) {
          final existing = uniqueMap[key]!;

          final mergedPhones = {...existing.phones, ...contact.phones}.toList();
          final mergedEmails = {...existing.emails, ...contact.emails}.toList();
          final mergedTags = {...existing.tags, ...contact.tags}.toList();
          final mergedInteractions = [
            ...existing.interactions,
            ...contact.interactions,
          ];

          final updatedExisting = existing.copyWith(
            phones: mergedPhones,
            emails: mergedEmails,
            tags: mergedTags,
            interactions: mergedInteractions,
            company: existing.company ?? contact.company,
            jobTitle: existing.jobTitle ?? contact.jobTitle,
            address: existing.address ?? contact.address,
            notes:
                (existing.notes ?? '') +
                (contact.notes != null ? '\n${contact.notes}' : ''),
            isFavorite: existing.isFavorite || contact.isFavorite,
          );

          await updateContact(updatedExisting);
          await deleteContact(contact.id);
          uniqueMap[key] = updatedExisting;
          mergedCount++;
        } else {
          uniqueMap[key] = contact;
        }
      }
      return mergedCount;
    } catch (e) {
      throw 'خطا در ادغام مخاطبین تکراری: $e';
    }
  }

  // --- Smart Utilities: Backup & Restore ---
  Future<String> exportBackup() async {
    try {
      final contacts = await fetchContacts();
      final maps = contacts.map((c) => c.toMap()).toList();
      return jsonEncode(maps);
    } catch (e) {
      throw 'خطا در تهیه پشتیبان: $e';
    }
  }

  Future<void> importBackup(String jsonString) async {
    try {
      final List<dynamic> listData = jsonDecode(jsonString);
      for (var item in listData) {
        if (item is Map<String, dynamic>) {
          item.remove('id');
          await client.records.create('daftarche', item);
        }
      }
    } catch (e) {
      throw 'خطا در بازگردانی پشتیبان: $e';
    }
  }

  void dispose() {
    _httpClient.close();
    client.dispose();
  }
}
