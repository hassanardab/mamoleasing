import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/booking_event.dart';
import '../../providers/app_provider.dart';
import '../../providers/booking_provider.dart';

class AddEventDialog extends StatefulWidget {
  final BookingEvent? event;

  const AddEventDialog({super.key, this.event});

  @override
  State<AddEventDialog> createState() => _AddEventDialogState();
}

class _AddEventDialogState extends State<AddEventDialog> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _titleController;
  late TextEditingController _customerNameController;
  late TextEditingController _customerEmailController;
  late TextEditingController _customerPhoneController;
  late TextEditingController _amountController;
  late TextEditingController _paidAmountController;
  late TextEditingController _placeController;
  late DateTime _startDate;
  late DateTime _endDate;
  late BookingStatus _status;

  @override
  void initState() {
    super.initState();
    final event = widget.event;
    _titleController = TextEditingController(text: event?.title);
    _customerNameController = TextEditingController(text: event?.customerName);
    _customerEmailController =
        TextEditingController(text: event?.customerEmail);
    _customerPhoneController =
        TextEditingController(text: event?.customerPhone);
    _amountController = TextEditingController(text: event?.amount.toString());
    _paidAmountController =
        TextEditingController(text: event?.paidAmount?.toString() ?? '0');
    _placeController = TextEditingController(text: event?.place);
    _startDate = event?.startDate ?? DateTime.now();
    _endDate = event?.endDate ?? DateTime.now().add(const Duration(hours: 1));
    _status = event?.status ?? BookingStatus.pending;
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle(context, 'Event Details'),
              _buildTextField(_titleController, 'Event Title',
                  validator: (v) => v!.isEmpty ? 'Required' : null),
              const SizedBox(height: 16),
              _buildSectionTitle(context, 'Customer Information'),
              _buildTextField(_customerNameController, 'Customer Name',
                  validator: (v) => v!.isEmpty ? 'Required' : null),
              _buildTextField(_customerEmailController, 'Customer Email'),
              _buildTextField(_customerPhoneController, 'Customer Phone'),
              const SizedBox(height: 16),
              _buildSectionTitle(context, 'Financials'),
              _buildTextField(_amountController, 'Amount',
                  keyboardType: TextInputType.number,
                  validator: (v) => v!.isEmpty ? 'Required' : null),
              _buildTextField(_paidAmountController, 'Paid Amount',
                  keyboardType: TextInputType.number),
              const SizedBox(height: 16),
              _buildSectionTitle(context, 'Location & Status'),
              _buildTextField(_placeController, 'Place (Optional)'),
              _buildStatusDropdown(),
              const SizedBox(height: 16),
              _buildDateTimePicker(context, 'Start', _startDate,
                  (date) => setState(() => _startDate = date)),
              _buildDateTimePicker(context, 'End', _endDate,
                  (date) => setState(() => _endDate = date)),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel')),
        ElevatedButton(
          onPressed: _saveEvent,
          style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
              foregroundColor: Colors.white),
          child: const Text('Save'),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Text(title,
          style: Theme.of(context)
              .textTheme
              .titleMedium
              ?.copyWith(fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label,
      {TextInputType? keyboardType, String? Function(String?)? validator}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
            labelText: label, border: const OutlineInputBorder()),
        keyboardType: keyboardType,
        validator: validator,
      ),
    );
  }

  Widget _buildStatusDropdown() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: DropdownButtonFormField<BookingStatus>(
        initialValue: _status,
        decoration: const InputDecoration(
            labelText: 'Status', border: OutlineInputBorder()),
        items: BookingStatus.values.map((status) {
          return DropdownMenuItem<BookingStatus>(
              value: status, child: Text(status.name));
        }).toList(),
        onChanged: (BookingStatus? newValue) {
          if (newValue != null) setState(() => _status = newValue);
        },
      ),
    );
  }

  Widget _buildDateTimePicker(BuildContext context, String label,
      DateTime initialDate, Function(DateTime) onDateChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          Expanded(
              child: Text(
                  '$label: ${DateFormat.yMd().add_jm().format(initialDate)}')),
          TextButton(
            onPressed: () async {
              final date = await showDatePicker(
                  context: context,
                  initialDate: initialDate,
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2101));
              if (date == null) return;
              final time = await showTimePicker(
                  context: context,
                  initialTime: TimeOfDay.fromDateTime(initialDate));
              if (time == null) return;
              onDateChanged(DateTime(
                  date.year, date.month, date.day, time.hour, time.minute));
            },
            child: const Text('Change'),
          ),
        ],
      ),
    );
  }

  Future<void> _saveEvent() async {
    if (!_formKey.currentState!.validate()) return;

    final appProvider = Provider.of<AppProvider>(context, listen: false);
    final bookingProvider =
        Provider.of<BookingProvider>(context, listen: false);
    final companyId = appProvider.selectedModuleId;

    if (companyId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Error: Company not selected.'),
          backgroundColor: Colors.red));
      return;
    }

    final amount = double.tryParse(_amountController.text) ?? 0;
    final paidAmount = double.tryParse(_paidAmountController.text) ?? 0;

    final eventToSave = BookingEvent(
        id: widget.event?.id,
        title: _titleController.text,
        customerName: _customerNameController.text,
        customerEmail: _customerEmailController.text,
        customerPhone: _customerPhoneController.text,
        startDate: _startDate,
        endDate: _endDate,
        amount: amount,
        paidAmount: paidAmount,
        balance: amount - paidAmount,
        status: _status,
        place: _placeController.text,
        clientId: widget.event?.clientId,
        currency: 'USD',
        createdAt: widget.event?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now());

    try {
      if (widget.event == null) {
        await bookingProvider.addEvent(companyId, eventToSave);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Event added successfully.'),
            backgroundColor: Colors.green));
      } else {
        await bookingProvider.updateEvent(companyId, eventToSave);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Event updated successfully.'),
            backgroundColor: Colors.green));
      }
      Navigator.of(context).pop();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Failed to save event: $e'),
          backgroundColor: Colors.red));
    }
  }
}
