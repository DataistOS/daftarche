// lib/services/contact_service.dart
import 'package:upupa_dart/upupa_dart.dart';
import '../models/contact_model.dart';

class ContactService {
  final UpupaClient client = UpupaClient('http://127.0.0.1:8090');

  Future<List<ContactModel>> fetchContacts() async {
    try {
      final response = await client.records.getList('contacts');
      return response.map((record) {
        return ContactModel.fromMap(record.id, record.data);
      }).toList();
    } catch (e) {
      throw 'خطا در دریافت مخاطبین: $e';
    }
  }

  Future<void> addContact(ContactModel contact) async {
    try {
      await client.records.create('contacts', contact.toMap());
    } catch (e) {
      throw 'خطا در ثبت مخاطب: $e';
    }
  }

  Future<void> updateContact(ContactModel contact) async {
    try {
      await client.records.update('contacts', contact.id, contact.toMap());
    } catch (e) {
      throw 'خطا در به‌روزرسانی مخاطب: $e';
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
