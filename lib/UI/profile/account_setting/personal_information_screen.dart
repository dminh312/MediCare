import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:flutter_animate/flutter_animate.dart';

class PersonalInformationScreen extends StatefulWidget {
  const PersonalInformationScreen({super.key});

  @override
  State<PersonalInformationScreen> createState() => _PersonalInformationScreenState();
}

class _PersonalInformationScreenState extends State<PersonalInformationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _dobController = TextEditingController();
  final _weightController = TextEditingController();
  final _heightController = TextEditingController();

  String? _selectedGender;
  final List<String> _genders = ['Female', 'Male', 'Other', 'Prefer not to say'];

  User? _user;
  bool _isLoading = true;
  bool _isSaving = false;
  String? _photoUrl;

  @override
  void initState() {
    super.initState();
    _user = FirebaseAuth.instance.currentUser;
    _photoUrl = _user?.photoURL;
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    if (_user == null) {
      setState(() => _isLoading = false);
      return;
    }
    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(_user!.uid).get();
      if (userDoc.exists) {
        Map<String, dynamic> data = userDoc.data() as Map<String, dynamic>;
        _nameController.text = data['displayName'] ?? '';
        _phoneController.text = data['phoneNumber'] ?? '';
        if (data['dob'] != null) {
          _dobController.text = DateFormat('MM/dd/yyyy').format((data['dob'] as Timestamp).toDate());
        }
        _weightController.text = data['weight']?.toString() ?? '';
        _heightController.text = data['height']?.toString() ?? '';
        _selectedGender = data['gender'] ?? 'Prefer not to say';
      } else {
        // If no user doc, still populate with auth data
        _nameController.text = _user?.displayName ?? '';
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load user data: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
  
  Future<void> _changeProfilePicture() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery, imageQuality: 70);

    if (image != null && _user != null) {
      setState(() => _isSaving = true);

      try {
        File file = File(image.path);
        String fileName = 'profile_${_user!.uid}.jpg';
        Reference storageRef = FirebaseStorage.instance.ref().child('profile_pictures/$fileName');

        UploadTask uploadTask = storageRef.putFile(file);
        TaskSnapshot taskSnapshot = await uploadTask;
        String downloadUrl = await taskSnapshot.ref.getDownloadURL();

        await _user!.updatePhotoURL(downloadUrl);
        await FirebaseFirestore.instance.collection('users').doc(_user!.uid).update({
          'photoURL': downloadUrl,
          'updatedAt': Timestamp.now(),
        });

        setState(() => _photoUrl = downloadUrl);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profile picture updated!')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to upload image: $e')));
        }
      } finally {
        if (mounted) {
           setState(() => _isSaving = false);
        }
      }
    }
  }

  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) return;
    if (_user == null) return;

    setState(() => _isSaving = true);

    try {
      Map<String, dynamic> dataToUpdate = {
        'displayName': _nameController.text,
        'phoneNumber': _phoneController.text,
        'gender': _selectedGender,
        'weight': double.tryParse(_weightController.text),
        'height': double.tryParse(_heightController.text),
        'updatedAt': Timestamp.now(),
      };

      if (_dobController.text.isNotEmpty) {
        dataToUpdate['dob'] = Timestamp.fromDate(DateFormat('MM/dd/yyyy').parse(_dobController.text));
      }

      await _user!.updateDisplayName(_nameController.text);
      await FirebaseFirestore.instance.collection('users').doc(_user!.uid).update(dataToUpdate);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Information saved successfully!')),
        );
        Navigator.of(context).pop();
      }

    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save changes: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _dobController.dispose();
    _weightController.dispose();
    _heightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFFff5252);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = isDarkMode ? const Color(0xFF1E293B) : Colors.white;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text('Personal Information', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDarkMode ? Colors.white : Colors.black, fontFamily: 'Plus Jakarta Sans')),
        leading: IconButton(
          icon: Icon(Icons.chevron_left, size: 28, color: isDarkMode ? Colors.white : Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDarkMode 
                ? [const Color(0xFF020617), const Color(0xFF0F172A)] 
                : [const Color(0xFFF8FAFC), const Color(0xFFE2E8F0)],
          ),
        ),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 32.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      _buildProfilePicture(isDarkMode, surfaceColor, primaryColor)
                          .animate().fade(duration: 400.ms).scaleXY(begin: 0.9, curve: Curves.easeOutBack),
                      const SizedBox(height: 40),
                      _buildTextField(label: 'Full Name', controller: _nameController, hintText: 'Enter your full name', primaryColor: primaryColor, surfaceColor: surfaceColor, isDarkMode: isDarkMode)
                          .animate().fade(duration: 400.ms, delay: 100.ms).slideY(begin: 0.1, curve: Curves.easeOut),
                      const SizedBox(height: 24),
                      _buildTextField(label: 'Phone Number', controller: _phoneController, hintText: 'Enter your phone number', keyboardType: TextInputType.phone, primaryColor: primaryColor, surfaceColor: surfaceColor, isDarkMode: isDarkMode)
                          .animate().fade(duration: 400.ms, delay: 150.ms).slideY(begin: 0.1, curve: Curves.easeOut),
                      const SizedBox(height: 24),
                      _buildDateField(label: 'Date of Birth', controller: _dobController, primaryColor: primaryColor, surfaceColor: surfaceColor, isDarkMode: isDarkMode)
                          .animate().fade(duration: 400.ms, delay: 200.ms).slideY(begin: 0.1, curve: Curves.easeOut),
                      const SizedBox(height: 24),
                      _buildGenderDropdown(label: 'Gender', primaryColor: primaryColor, surfaceColor: surfaceColor, isDarkMode: isDarkMode)
                          .animate().fade(duration: 400.ms, delay: 250.ms).slideY(begin: 0.1, curve: Curves.easeOut),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Expanded(child: _buildTextField(label: 'Weight (kg)', controller: _weightController, hintText: 'e.g. 60.5', keyboardType: const TextInputType.numberWithOptions(decimal: true), primaryColor: primaryColor, surfaceColor: surfaceColor, isDarkMode: isDarkMode)),
                          const SizedBox(width: 16),
                          Expanded(child: _buildTextField(label: 'Height (m)', controller: _heightController, hintText: 'e.g. 1.7', keyboardType: const TextInputType.numberWithOptions(decimal: true), primaryColor: primaryColor, surfaceColor: surfaceColor, isDarkMode: isDarkMode)),
                        ],
                      ).animate().fade(duration: 400.ms, delay: 300.ms).slideY(begin: 0.1, curve: Curves.easeOut),
                      const SizedBox(height: 48),
                      _buildSaveChangesButton(primaryColor)
                          .animate().fade(duration: 400.ms, delay: 350.ms).slideY(begin: 0.1, curve: Curves.easeOut),
                      const SizedBox(height: 24),
                      Text(
                        'Your information is encrypted and securely stored.',
                        style: TextStyle(fontSize: 12, color: Colors.grey[500], fontFamily: 'Plus Jakarta Sans'),
                      ).animate().fade(duration: 400.ms, delay: 400.ms),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildProfilePicture(bool isDarkMode, Color surfaceColor, Color primaryColor) {
    ImageProvider<Object> backgroundImage = (_photoUrl != null)
        ? NetworkImage(_photoUrl!)
        : const AssetImage('assets/def.png') as ImageProvider;

    return GestureDetector(
      onTap: _changeProfilePicture,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: isDarkMode ? Colors.red[900]!.withOpacity(0.3) : Colors.white, width: 2),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
            ),
            child: CircleAvatar(
              radius: 48,
              backgroundImage: backgroundImage,
            ),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: primaryColor,
                border: Border.all(color: surfaceColor, width: 2),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 5)],
              ),
              child: const Padding(
                padding: EdgeInsets.all(6.0),
                child: Icon(Icons.photo_camera, color: Colors.white, size: 16),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildTextField({required String label, required TextEditingController controller, required String hintText, TextInputType keyboardType = TextInputType.text, required Color primaryColor, required Color surfaceColor, required bool isDarkMode}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: isDarkMode ? Colors.white : Colors.black87, fontFamily: 'Plus Jakarta Sans')),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            boxShadow: [
              if (!isDarkMode)
                BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 16, offset: const Offset(0, 4))
              else
                BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 16, offset: const Offset(0, 4)),
            ],
            borderRadius: BorderRadius.circular(16),
          ),
          child: TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            style: TextStyle(fontSize: 15, color: isDarkMode ? Colors.white : Colors.black, fontFamily: 'Plus Jakarta Sans'),
            validator: (value) => (value == null || value.isEmpty) ? 'This field cannot be empty' : null,
            decoration: InputDecoration(
              filled: true,
              fillColor: surfaceColor,
              hintText: hintText,
              hintStyle: TextStyle(color: isDarkMode ? Colors.grey[600] : Colors.grey[400], fontFamily: 'Plus Jakarta Sans'),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: primaryColor, width: 2)),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: isDarkMode ? Colors.white10 : Colors.transparent, width: 1)),
            ),
          ),
        ),
      ],
    );
  }
  
  Widget _buildDateField({required String label, required TextEditingController controller, required Color primaryColor, required Color surfaceColor, required bool isDarkMode}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: isDarkMode ? Colors.white : Colors.black87, fontFamily: 'Plus Jakarta Sans')),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            boxShadow: [
              if (!isDarkMode)
                BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 16, offset: const Offset(0, 4))
              else
                BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 16, offset: const Offset(0, 4)),
            ],
            borderRadius: BorderRadius.circular(16),
          ),
          child: TextFormField(
            controller: controller,
            readOnly: true,
            onTap: () async {
              DateTime initial = _dobController.text.isNotEmpty ? DateFormat('MM/dd/yyyy').parse(_dobController.text) : DateTime.now();
              DateTime? pickedDate = await showDatePicker(
                context: context,
                initialDate: initial,
                firstDate: DateTime(1900),
                lastDate: DateTime.now(),
              );
              if (pickedDate != null) {
                controller.text = DateFormat('MM/dd/yyyy').format(pickedDate);
              }
            },
            style: TextStyle(fontSize: 15, color: isDarkMode ? Colors.white : Colors.black, fontFamily: 'Plus Jakarta Sans'),
            decoration: InputDecoration(
              filled: true,
              fillColor: surfaceColor,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: primaryColor, width: 2)),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: isDarkMode ? Colors.white10 : Colors.transparent, width: 1)),
              suffixIcon: Icon(Icons.calendar_today, color: isDarkMode ? Colors.grey[500] : Colors.grey[400]),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGenderDropdown({required String label, required Color primaryColor, required Color surfaceColor, required bool isDarkMode}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: isDarkMode ? Colors.white : Colors.black87, fontFamily: 'Plus Jakarta Sans')),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            boxShadow: [
              if (!isDarkMode)
                BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 16, offset: const Offset(0, 4))
              else
                BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 16, offset: const Offset(0, 4)),
            ],
            borderRadius: BorderRadius.circular(16),
          ),
          child: DropdownButtonFormField<String>(
            value: _selectedGender,
            icon: Icon(Icons.arrow_drop_down, color: isDarkMode ? Colors.grey[400] : Colors.grey[600]),
            dropdownColor: surfaceColor,
            items: _genders.map((String gender) {
              return DropdownMenuItem<String>(
                value: gender,
                child: Text(gender, style: TextStyle(fontSize: 15, color: isDarkMode ? Colors.white : Colors.black, fontFamily: 'Plus Jakarta Sans')),
              );
            }).toList(),
            onChanged: (newValue) {
              setState(() {
                _selectedGender = newValue;
              });
            },
            decoration: InputDecoration(
              filled: true,
              fillColor: surfaceColor,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: primaryColor, width: 2)),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: isDarkMode ? Colors.white10 : Colors.transparent, width: 1)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSaveChangesButton(Color primaryColor) {
    return ElevatedButton.icon(
      onPressed: _isSaving ? null : _saveChanges,
      icon: _isSaving ? Container(width: 20, height: 20, padding: const EdgeInsets.all(2.0), child: const CircularProgressIndicator(color: Colors.white, strokeWidth: 3)) : const Icon(Icons.check_circle, color: Colors.white, size: 20),
      label: const Text('Save Changes', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        minimumSize: const Size(double.infinity, 56),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 4,
        shadowColor: primaryColor.withOpacity(0.3),
      ),
    );
  }
}
