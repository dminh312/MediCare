import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:medicare/logic/models/medication_model.dart';

class AddMedsScreen extends StatefulWidget {
  final MedicationModel? medication;

  const AddMedsScreen({super.key, this.medication});

  @override
  State<AddMedsScreen> createState() => _AddMedsScreenState();
}

class _AddMedsScreenState extends State<AddMedsScreen> {
  final _formKey = GlobalKey<FormState>();
  late bool _isEditMode;

  String? _medName;
  String? _dosage;
  String? _dosageEntireTreatment;
  late String _form;
  late String _frequency;
  late TimeOfDay _time;
  late String _timing;
  late bool _setReminder;
  String? _notes;

  final List<String> _formOptions = ['Pill', 'Injection', 'Syrup', 'Tablet', 'Capsule'];
  final List<String> _frequencyOptions = ['Daily', 'Twice a day', 'Weekly', 'As needed'];
  final List<String> _timingOptions = [
    'Before Breakfast',
    'After Breakfast',
    'Before Lunch',
    'After Lunch',
    'Before Dinner',
    'After Dinner',
    'Before Bed',
  ];

  @override
  void initState() {
    super.initState();
    _isEditMode = widget.medication != null;

    if (_isEditMode) {
      final med = widget.medication!;
      _medName = med.name;
      _dosage = med.dosage;
      _dosageEntireTreatment = med.dosageEntireTreatment;
      _form = med.form.name[0].toUpperCase() + med.form.name.substring(1);
      _frequency = med.frequency;
      _time = med.time;
      _timing = med.timing;
      _setReminder = med.reminderEnabled;
      _notes = med.notes;
    } else {
      _form = 'Pill';
      _frequency = 'Daily';
      _time = const TimeOfDay(hour: 8, minute: 0);
      _timing = 'Before Breakfast';
      _setReminder = true;
    }
  }

  IconData get dosageIcon {
    try {
      switch (MedicationForm.values.byName(_form.toLowerCase())) {
        case MedicationForm.syrup:
          return Icons.medication_liquid_outlined;
        case MedicationForm.injection:
          return Icons.opacity; // A water drop icon
        case MedicationForm.pill:
        case MedicationForm.tablet:
        case MedicationForm.capsule:
        default:
          return Icons.scale; // A scale icon for weight
      }
    } catch (e) {
      return Icons.scale; // Default icon
    }
  }

  Future<void> _saveMedication() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('You must be logged in to add medication.')),
          );
        }
        return;
      }

      final medicationData = MedicationModel(
        id: _isEditMode ? widget.medication!.id : '', // Firestore will generate on add
        userId: user.uid,
        name: _medName!,
        dosage: _dosage!,
        dosageEntireTreatment: _dosageEntireTreatment,
        form: MedicationForm.values.byName(_form.toLowerCase()),
        frequency: _frequency,
        time: _time,
        timing: _timing,
        reminderEnabled: _setReminder,
        notes: _notes,
        createdAt: _isEditMode ? widget.medication!.createdAt : Timestamp.now(),
      );

      try {
        if (_isEditMode) {
          await FirebaseFirestore.instance.collection('medications').doc(widget.medication!.id).update(medicationData.toFirestore());
        } else {
          await FirebaseFirestore.instance.collection('medications').add(medicationData.toFirestore());
        }
        if (mounted) {
          Navigator.of(context).pop();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to save medication: \$e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    const primaryColor = Color(0xffff5252);
    const primaryLightColor = Color(0xffffebee);
    final backgroundColor = isDarkMode ? const Color(0xff1a1111) : const Color(0xfffffbfb);
    final surfaceColor = isDarkMode ? const Color(0xff2d1f1f) : Colors.white;
    final textColor = isDarkMode ? Colors.grey[100] : const Color(0xff111714);
    final mutedTextColor = isDarkMode ? Colors.grey[400] : Colors.grey[500];
    final ringColor = isDarkMode ? Colors.red[900]!.withAlpha(51) : Colors.red[100]!;


    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor.withAlpha(242),
        elevation: 0,
        leading: TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel', style: TextStyle(color: primaryColor, fontWeight: FontWeight.w500)),
        ),
        leadingWidth: 80,
        title: Text(_isEditMode ? 'Edit Medication' : 'Add Medication', style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 18)),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: _saveMedication,
            child: const Text('Save', style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold)),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(
            color: isDarkMode ? Colors.red[900]!.withAlpha(51) : Colors.red[100],
            height: 1.0,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: isDarkMode ? primaryColor.withAlpha(51) : primaryLightColor,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: const Icon(Icons.medication, color: primaryColor, size: 40),
                  ),
                  const SizedBox(height: 8),
                  Text('Medication Details', style: TextStyle(color: mutedTextColor, fontSize: 14)),
                  const SizedBox(height: 32),
                  _buildSection(
                    label: 'Medication Name',
                    child: _buildTextFormField(
                      initialValue: _medName,
                      hintText: 'e.g. Vitamin C',
                      onSaved: (value) => _medName = value,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a medication name.';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildSection(
                    label: 'Dosage (per use)',
                    child: _buildTextFormField(
                      initialValue: _dosage,
                      hintText: 'e.g. 500mg',
                      onSaved: (value) => _dosage = value,
                      suffixIcon: Icon(dosageIcon, color: mutedTextColor),
                       validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a dosage.';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildSection(
                    label: 'Dosage (for entire treatment)',
                    child: _buildTextFormField(
                      initialValue: _dosageEntireTreatment,
                      hintText: 'e.g. 30 pills',
                      onSaved: (value) => _dosageEntireTreatment = value,
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildSection(
                    label: 'Form',
                    child: _buildDropdownFormField(
                      value: _form,
                      items: _formOptions,
                      onChanged: (value) => setState(() => _form = value!),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: _buildSection(
                          label: 'Frequency',
                          child: _buildDropdownFormField(
                            value: _frequency,
                            items: _frequencyOptions,
                            onChanged: (value) => setState(() => _frequency = value!),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildSection(
                          label: 'Time of Day',
                          child: _buildTimePickerField(context),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _buildSection(
                    label: 'Timing',
                    child: _buildDropdownFormField(
                      value: _timing,
                      items: _timingOptions,
                      onChanged: (value) => setState(() => _timing = value!),
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildReminderSwitch(surfaceColor, ringColor, mutedTextColor, primaryColor),
                  const SizedBox(height: 20),
                  _buildSection(
                    label: 'Instructions (Optional)',
                    child: _buildTextFormField(
                      initialValue: _notes,
                      hintText: 'e.g. Take with food',
                      maxLines: 3,
                      onSaved: (value) => _notes = value,
                    ),
                  ),
                  const SizedBox(height: 32),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32.0),
                    child: Text(
                      'Your medications are securely stored and encrypted for your privacy.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey[400], fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSection({required String label, required Widget child}) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final mutedTextColor = isDarkMode ? Colors.grey[400] : Colors.grey[500];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4.0),
          child: Text(
            label.toUpperCase(),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: mutedTextColor,
              letterSpacing: 0.5,
            ),
          ),
        ),
        const SizedBox(height: 8),
        child,
      ],
    );
  }

  Widget _buildTextFormField({
    required String hintText,
    String? initialValue,
    int? maxLines = 1,
    void Function(String?)? onSaved,
    Widget? suffixIcon,
    String? Function(String?)? validator,
  }) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final surfaceColor = isDarkMode ? const Color(0xff2d1f1f) : Colors.white;
    const primaryColor = Color(0xffff5252);
    final ringColor = isDarkMode ? Colors.red[900]!.withAlpha(51) : Colors.red[100]!;
    final placeholderColor = isDarkMode ? Colors.grey[600] : Colors.grey[300];

    return TextFormField(
      initialValue: initialValue,
      maxLines: maxLines,
      onSaved: onSaved,
      validator: validator,
      style: const TextStyle(fontSize: 16),
      decoration: InputDecoration(
        filled: true,
        fillColor: surfaceColor,
        hintText: hintText,
        hintStyle: TextStyle(color: placeholderColor),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: ringColor, width: 1.0),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: ringColor, width: 1.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: primaryColor, width: 2.0),
        ),
        suffixIcon: suffixIcon,
      ),
    );
  }

  Widget _buildDropdownFormField({
    required String value,
    required List<String> items,
    required void Function(String?)? onChanged,
  }) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final surfaceColor = isDarkMode ? const Color(0xff2d1f1f) : Colors.white;
    const primaryColor = Color(0xffff5252);
    final ringColor = isDarkMode ? Colors.red[900]!.withAlpha(51) : Colors.red[100]!;
    final mutedTextColor = isDarkMode ? Colors.grey[400] : Colors.grey[500];

    return DropdownButtonFormField<String>(
      value: value,
      items: items.map((String item) {
        return DropdownMenuItem<String>(
          value: item,
          child: Text(item, style: const TextStyle(fontSize: 16)),
        );
      }).toList(),
      onChanged: onChanged,
      decoration: InputDecoration(
        filled: true,
        fillColor: surfaceColor,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
         border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: ringColor, width: 1.0),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: ringColor, width: 1.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: primaryColor, width: 2.0),
        ),
      ),
      icon: Icon(Icons.expand_more, color: mutedTextColor),
      dropdownColor: surfaceColor,
    );
  }
  
  Widget _buildTimePickerField(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final surfaceColor = isDarkMode ? const Color(0xff2d1f1f) : Colors.white;
    final ringColor = isDarkMode ? Colors.red[900]!.withAlpha(51) : Colors.red[100]!;
    
    return GestureDetector(
      onTap: () async {
        final TimeOfDay? picked = await showTimePicker(
          context: context,
          initialTime: _time,
        );
        if (picked != null && picked != _time) {
          setState(() {
            _time = picked;
          });
        }
      },
      child: Container(
        height: 58,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: surfaceColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: ringColor, width: 1.0),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _time.format(context),
              style: const TextStyle(fontSize: 16),
            ),
             Icon(Icons.access_time, color: Colors.grey[400])
          ],
        ),
      ),
    );
  }

  Widget _buildReminderSwitch(Color surfaceColor, Color ringColor, Color? mutedTextColor, Color primaryColor) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: ringColor, width: 1.0),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.orange[50],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.notifications_active, color: Colors.orange[500]),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Set Reminder', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  Text(
                    'Get notified when it\'s time',
                    style: TextStyle(fontSize: 10, color: mutedTextColor),
                  ),
                ],
              ),
            ],
          ),
          Switch(
            value: _setReminder,
            onChanged: (value) {
              setState(() {
                _setReminder = value;
              });
            },
            activeThumbColor: primaryColor,
            activeTrackColor: primaryColor.withAlpha(100),
          ),
        ],
      ),
    );
  }
}
