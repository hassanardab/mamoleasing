import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_provider.dart';

class CompanyFormDialog extends StatefulWidget {
  final Company? company;

  const CompanyFormDialog({super.key, this.company});

  @override
  _CompanyFormDialogState createState() => _CompanyFormDialogState();
}

class _CompanyFormDialogState extends State<CompanyFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late String _name;
  late String? _logoUrl;

  @override
  void initState() {
    super.initState();
    _name = widget.company?.name ?? '';
    _logoUrl = widget.company?.logoUrl;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.company == null ? 'Add Company' : 'Edit Company'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              initialValue: _name,
              decoration: const InputDecoration(labelText: 'Company Name'),
              validator: (value) =>
                  value!.isEmpty ? 'Please enter a name' : null,
              onSaved: (value) => _name = value!,
            ),
            TextFormField(
              initialValue: _logoUrl,
              decoration: const InputDecoration(labelText: 'Logo URL'),
              onSaved: (value) => _logoUrl = value,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _saveCompany,
          child: const Text('Save'),
        ),
      ],
    );
  }

  void _saveCompany() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      final appProvider = Provider.of<AppProvider>(context, listen: false);
      if (widget.company == null) {
        appProvider.addCompany(name: _name, logoUrl: _logoUrl);
      } else {
        appProvider.updateCompany(widget.company!.id,
            name: _name, logoUrl: _logoUrl);
      }
      Navigator.of(context).pop();
    }
  }
}
