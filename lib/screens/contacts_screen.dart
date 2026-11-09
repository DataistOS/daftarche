// lib/services/contact_service.dart
import 'package:upupa_dart/upupa_dart.dart';

class ContactService {
  final UpupaClient client = UpupaClient('http://127.0.0.1:8090');

  Future<List<Record>> fetchContacts() async {
    try {
      final response = await client.records.getList('contacts');
      return response;
    } catch (e) {
      throw 'خطا در دریافت مخاطبین: $e';
    }
  }

  Future<void> addContact(String name, String phone) async {
    try {
      await client.records.create('contacts', {
        'name': name,
        'phone': phone,
        'is_favorite': false,
      });
    } catch (e) {
      throw 'خطا در ثبت مخاطب: $e';
    }
  }

  Future<void> deleteContact(String recordId) async {
    try {
      await client.records.delete('contacts', recordId);
    } catch (e) {
      throw 'خطا در حذف مخاطب: $e';
    }
  }

  void dispose() {
    client.dispose();
  }
}
