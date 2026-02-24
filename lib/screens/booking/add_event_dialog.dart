
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/booking_event.dart';
import '../../providers/app_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddEventDialog extends StatefulWidget {
  final BookingEvent? event;

  const AddEventDialog({super.key, this.event});

  @override
  State<AddEventDialog> createState() => _AddEventDialogState();
}

class _AddEventDialogState extends State<AddEventDialog> {
  final _formKey = GlobalKey<FormState>();

  late String _title;
  late String _customerName;
  late DateTime _startDate;
  late DateTime _endDate;
  late double _amount;
  late double _paidAmount;
  late String? _place;
  late BookingStatus _status;

  @override
  void initState() {
    super.initState();
    _title = widget.event?.title ?? '';
    _customerName = widget.event?.customerName ?? '';
    _startDate = widget.event?.startDate ?? DateTime.now();
    _endDate = widget.event?.endDate ?? DateTime.now().add(const Duration(hours: 1));
    _amount = widget.event?.amount ?? 0.0;
    _paidAmount = widget.event?.paidAmount ?? 0.0;
    _place = widget.event?.place;
    _status = widget.event?.status ?? BookingStatus.pending;
  }

  Future<void> _selectDate(BuildContext context, {bool isStart = true}) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isStart ? _startDate : _endDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != (isStart ? _startDate : _endDate)) {
      setState(() {
        if (isStart) {
          _startDate = picked;
          if (_endDate.isBefore(_startDate)) {
            _endDate = _startDate.add(const Duration(hours: 1));
          }
        } else {
          _endDate = picked;
        }
      });
    }
  }

  Future<void> _saveEvent() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      final appProvider = Provider.of<AppProvider>(context, listen: false);
      final companyId = appProvider.selectedModuleId;

      if (companyId == null || companyId.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No company selected. Please select a module first.')),
        );
        return;
      }
      
      final eventToSave = BookingEvent(
        id: widget.event?.id ?? FirebaseFirestore.instance.collection('tmp').doc().id,
        title: _title,
        customerName: _customerName,
        startDate: _startDate,
        endDate: _endDate,
        amount: _amount,
        balance: _amount - _paidAmount,
        paidAmount: _paidAmount,
        currency: 'USD', // Default currency
        status: _status,
        place: _place,
        createdAt: widget.event?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
        clientId: widget.event?.clientId,
      );

      try {
        final docRef = FirebaseFirestore.instance
            .collection('companies')
            .doc(companyId)
            .collection('bookingEvents')
            .doc(eventToSave.id);

        await docRef.set(eventToSave.toFirestore(), SetOptions(merge: true));
        
        Navigator.of(context).pop();

      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save event: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.event == null ? 'Add New Event' : 'Edit Event'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextFormField(
                initialValue: _title,
                decoration: const InputDecoration(labelText: 'Event Title', border: OutlineInputBorder()),
                validator: (value) => value!.isEmpty ? 'Please enter a title' : null,
                onSaved: (value) => _title = value!,
              ),
              const SizedBox(height: 12),
              TextFormField(
                initialValue: _customerName,
                decoration: const InputDecoration(labelText: 'Customer Name', border: OutlineInputBorder()),
                validator: (value) => value!.isEmpty ? 'Please enter a customer name' : null,
                onSaved: (value) => _customerName = value!,
              ),
              const SizedBox(height: 12),
               TextFormField(
                initialValue: _amount.toString(),
                decoration: const InputDecoration(labelText: 'Amount', border: OutlineInputBorder()),
                keyboardType: TextInputType.number,
                validator: (value) => value!.isEmpty ? 'Please enter an amount' : null,
                onSaved: (value) => _amount = double.tryParse(value!) ?? 0.0,
              ),
              const SizedBox(height: 12),
              TextFormField(
                initialValue: _paidAmount.toString(),
                decoration: const InputDecoration(labelText: 'Paid Amount', border: OutlineInputBorder()),
                keyboardType: TextInputType.number,
                onSaved: (value) => _paidAmount = double.tryParse(value!) ?? 0.0,
              ),
              const SizedBox(height: 12),
              TextFormField(
                initialValue: _place,
                decoration: const InputDecoration(labelText: 'Place (Optional)', border: OutlineInputBorder()),
                onSaved: (value) => _place = value,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<BookingStatus>(
                initialValue: _status,
                decoration: const InputDecoration(labelText: 'Status', border: OutlineInputBorder()),
                items: BookingStatus.values.map((BookingStatus status) {
                  return DropdownMenuItem<BookingStatus>(
                    value: status,
                    child: Text(status.name),
                  );
                }).toList(),
                onChanged: (BookingStatus? newValue) {
                  setState(() {
                    _status = newValue!;
                  });
                },
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Start: ${DateFormat.yMd().format(_startDate)}'),
                  TextButton(
                    onPressed: () => _selectDate(context, isStart: true),
                    child: const Text('Change'),
                  )
                ],
              ),
               Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('End: ${DateFormat.yMd().format(_endDate)}'),
                  TextButton(
                    onPressed: () => _selectDate(context, isStart: false),
                    child: const Text('Change'),
                  )
                ],
              ),
            ],
          ),
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _saveEvent,
          child: const Text('Save'),
        ),
      ],
    );
  }
}
