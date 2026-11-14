// lib/widgets/contact_form_sheet.dart
import 'package:flutter/material.dart';
import '../models/contact_model.dart';

class ContactFormSheet extends StatefulWidget {
  final ContactModel? initialContact;
  final Function(ContactModel) onSave;

  const ContactFormSheet({
    super.key,
    this.initialContact,
    required this.onSave,
  });

  @override
  State<ContactFormSheet> createState() => _ContactFormSheetState();
}

class _ContactFormSheetState extends State<ContactFormSheet> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _companyController;
  late TextEditingController _jobTitleController;
  late TextEditingController _emailController;
  late TextEditingController _tagsController;
  late TextEditingController _notesController;

  String? _selectedGroup;
  final List<String> _predefinedGroups = [
    'خانواده',
    'دوستان',
    'همکاران',
    'مشتریان VIP',
  ];

  @override
  void initState() {
    super.initState();
    final c = widget.initialContact;
    _nameController = TextEditingController(text: c?.name ?? '');
    _phoneController = TextEditingController(
      text: c?.phones.isNotEmpty == true ? c!.phones.first : '',
    );
    _companyController = TextEditingController(text: c?.company ?? '');
    _jobTitleController = TextEditingController(text: c?.jobTitle ?? '');
    _emailController = TextEditingController(
      text: c?.emails.isNotEmpty == true ? c!.emails.first : '',
    );
    _tagsController = TextEditingController(text: c?.tags.join(', ') ?? '');
    _notesController = TextEditingController(text: c?.notes ?? '');
    _selectedGroup = c?.group;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _companyController.dispose();
    _jobTitleController.dispose();
    _emailController.dispose();
    _tagsController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final tagsList = _tagsController.text
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();

      final updatedContact = ContactModel(
        id: widget.initialContact?.id ?? '',
        name: _nameController.text.trim(),
        phones: [_phoneController.text.trim()],
        emails: _emailController.text.isNotEmpty
            ? [_emailController.text.trim()]
            : [],
        company: _companyController.text.isNotEmpty
            ? _companyController.text.trim()
            : null,
        jobTitle: _jobTitleController.text.isNotEmpty
            ? _jobTitleController.text.trim()
            : null,
        group: _selectedGroup,
        tags: tagsList,
        notes: _notesController.text.isNotEmpty
            ? _notesController.text.trim()
            : null,
        // ذخیره یادداشت
        isFavorite: widget.initialContact?.isFavorite ?? false,
      );

      widget.onSave(updatedContact);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        top: 20,
        left: 20,
        right: 20,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                widget.initialContact == null
                    ? 'افزودن مخاطب جدید'
                    : 'ویرایش مخاطب',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'نام و نام خانوادگی *',
                  border: OutlineInputBorder(),
                ),
                validator: (val) => val == null || val.trim().isEmpty
                    ? 'لطفاً نام را وارد کنید'
                    : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'شماره تلفن همراه *',
                  border: OutlineInputBorder(),
                ),
                validator: (val) => val == null || val.trim().isEmpty
                    ? 'لطفاً شماره تلفن را وارد کنید'
                    : null,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _companyController,
                      decoration: const InputDecoration(
                        labelText: 'شرکت / سازمان',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _jobTitleController,
                      decoration: const InputDecoration(
                        labelText: 'سمت شغلی',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'ایمیل',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _selectedGroup,
                decoration: const InputDecoration(
                  labelText: 'گروه مخاطب',
                  border: OutlineInputBorder(),
                ),
                items: _predefinedGroups.map((group) {
                  return DropdownMenuItem(value: group, child: Text(group));
                }).toList(),
                onChanged: (val) {
                  setState(() {
                    _selectedGroup = val;
                  });
                },
                hint: const Text('انتخاب گروه'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _tagsController,
                decoration: const InputDecoration(
                  labelText: 'برچسب‌ها (با کاما جدا کنید مثل: VIP, همکار)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _notesController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'یادداشت‌ها و نکات شخصی',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submit,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: const Text(
                  'ذخیره مخاطب',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
