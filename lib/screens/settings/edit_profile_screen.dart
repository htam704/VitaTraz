import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

import 'package:fl_vitatraz_app/theme/app_colors.dart';
import 'package:fl_vitatraz_app/components/components.dart';

class EditProfileScreen extends StatefulWidget {
  static const String routeName = '/editProfile';

  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  // Current authenticated Firebase user
  User? _currentUser;
  // Reference to the Firestore document for this nurse
  DocumentReference<Map<String, dynamic>>? _nurseDocRef;

  // Controllers for text fields
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();

  String? _avatarUrl;            // URL of the nurse's avatar image
  File? _newAvatarFile;          // Local file picked but not yet uploaded
  bool _isLoading = true;        // Flag to show loading indicator while fetching data
  bool _isSaving = false;        // Flag to disable save button during save operation

  @override
  void initState() {
    super.initState();
    // Get current Firebase user
    _currentUser = FirebaseAuth.instance.currentUser;
    // If user is authenticated and has an email, set up Firestore doc reference
    if (_currentUser != null && _currentUser!.email != null) {
      _nurseDocRef = FirebaseFirestore.instance
          .collection('enfermeros')
          .doc(_currentUser!.email!);
      _loadNurseData(); // Load existing nurse data from Firestore
    }
  }

  // --------------------------------
  // Load nurse data from Firestore and populate controllers
  Future<void> _loadNurseData() async {
    if (_nurseDocRef == null) {
      if (!mounted) return;
      setState(() => _isLoading = false); // No doc reference, stop loading
      return;
    }

    try {
      final doc = await _nurseDocRef!.get(); // Fetch document snapshot
      if (doc.exists) {
        final data = doc.data()!;
        // Populate name and phone controllers with data from Firestore
        _nameController.text = data['nombre'] as String? ?? '';
        _phoneController.text = data['numeroTelefono']?.toString() ?? '';
        _avatarUrl = data['avatarUrl'] as String?; // Load avatar URL if available
      }
    } catch (_) {
      // Ignore errors silently (could log if needed)
    } finally {
      if (!mounted) return;
      setState(() => _isLoading = false); // Stop loading indicator
    }
  }

  // --------------------------------
  // Pick an image from gallery but do NOT upload yet
  Future<void> _pickImageLocally() async {
    final picker = ImagePicker();
    // Open gallery to pick an image
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile == null) {
      // If user didn't select an image, show SnackBar and return
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se seleccionó ninguna imagen.')),
      );
      return;
    }

    if (!mounted) return;
    setState(() {
      _newAvatarFile = File(pickedFile.path);
    });
  }

  // --------------------------------
  // Save name, phone number and avatar changes to Firestore & Storage
  Future<void> _saveChanges() async {
    if (_nurseDocRef == null) return;

    final newName = _nameController.text.trim();
    final newPhone = _phoneController.text.trim();

    // Validate that name and phone are not empty
    if (newName.isEmpty || newPhone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nombre y teléfono no pueden quedar vacíos.')),
      );
      return;
    }

    if (!mounted) return;
    setState(() => _isSaving = true); // Disable button and show progress
    try {
      // First: if there's a new avatar file, upload it
      String? downloadUrl = _avatarUrl;
      if (_newAvatarFile != null) {
        final email = _currentUser!.email!;
        final storageRef = FirebaseStorage.instance
            .ref()
            .child('vitatraz/enfermeros/$email.jpg');
        // Delete previous avatar if it exists (ignore errors)
        await storageRef.delete().catchError((_) {});
        // Upload new image
        await storageRef.putFile(_newAvatarFile!);
        downloadUrl = await storageRef.getDownloadURL();
      }

      // Prepare updates map
      final updates = <String, dynamic>{
        'nombre': newName,
        'numeroTelefono': newPhone,
      };
      if (downloadUrl != null) {
        updates['avatarUrl'] = downloadUrl;
      }

      // Apply updates in Firestore
      await _nurseDocRef!.update(updates);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Perfil actualizado correctamente.')),
      );
      Navigator.pop(context); // Go back after successful save
    } catch (e) {
      // Show error if update fails
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al guardar: $e')),
      );
    } finally {
      if (!mounted) return;
      setState(() {
        _isSaving = false;     // Re-enable button
        _newAvatarFile = null; // Clear local file after save
      });
    }
  }

  @override
  void dispose() {
    // Dispose controllers to free resources
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // If no authenticated user or no Firestore reference, show error screen
    if (_currentUser == null || _nurseDocRef == null) {
      return Scaffold(
        backgroundColor: AppColors.primaryBackground,
        body: Center(
          child: Text(
            'Usuario no autenticado.',
            style: GoogleFonts.manrope(
              fontSize: 16,
              color: AppColors.primaryText,
            ),
          ),
        ),
      );
    }

    return WillPopScope(
      onWillPop: () async {
        if (_isSaving) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Espera a que termine de guardar…')),
          );
          return false; // Prevent back while saving
        }
        return true;   // Allow back
      },
      child: Scaffold(
        backgroundColor: AppColors.primaryBackground,
        bottomNavigationBar: const AppBottomNavBar(currentIndex: 1), // Highlight profile tab
        appBar: AppBar(
          backgroundColor: AppColors.primary,
          elevation: 0,
          title: Text(
            'Editar Perfil',
            style: GoogleFonts.manrope(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.secondaryBackground,
            ),
          ),
          leading: BackButton(color: AppColors.secondaryBackground), // Back arrow
        ),
        body: _isLoading
            // Show loading indicator while fetching data
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // --------------------------------
                    // Container for avatar and input fields
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            offset: const Offset(0, 4),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                      child: Column(
                        children: [
                          // Avatar: tap to pick new image locally
                          GestureDetector(
                            onTap: _pickImageLocally,
                            child: CircleAvatar(
                              radius: 48,
                              backgroundColor: AppColors.secondaryBackground,
                              backgroundImage: _newAvatarFile != null
                                  ? FileImage(_newAvatarFile!) as ImageProvider
                                  : (_avatarUrl != null
                                      ? NetworkImage(_avatarUrl!)
                                      : null),
                              child: _newAvatarFile == null && _avatarUrl == null
                                  ? Text(
                                      // Show first letter of name if no avatar
                                      _nameController.text.isNotEmpty
                                          ? _nameController.text[0]
                                          : '',
                                      style: GoogleFonts.manrope(
                                        fontSize: 40,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    )
                                  : null,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Pulsa en el avatar para cambiar tu foto de perfil.',
                            style: GoogleFonts.manrope(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: AppColors.secondaryBackground.withOpacity(0.9),
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          // --------------------------------
                          // Label for Name field
                          Text(
                            'Nombre',
                            style: GoogleFonts.manrope(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: AppColors.secondaryBackground.withOpacity(0.9),
                            ),
                            textAlign: TextAlign.start,
                          ),
                          const SizedBox(height: 4),
                          // TextField for name input
                          TextField(
                            controller: _nameController,
                            decoration: InputDecoration(
                              hintText: 'Introduce tu nombre',
                              hintStyle: GoogleFonts.manrope(
                                color: AppColors.secondaryText,
                              ),
                              filled: true,
                              fillColor: AppColors.secondaryBackground,
                              contentPadding: const EdgeInsets.symmetric(
                                  vertical: 12, horizontal: 16),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                            ),
                            style: GoogleFonts.manrope(
                              color: AppColors.primaryText,
                            ),
                          ),
                          const SizedBox(height: 16),
                          // --------------------------------
                          // Label for Phone Number field
                          Text(
                            'Número de teléfono',
                            style: GoogleFonts.manrope(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: AppColors.secondaryBackground.withOpacity(0.9),
                            ),
                            textAlign: TextAlign.start,
                          ),
                          const SizedBox(height: 4),
                          // TextField for phone number input
                          TextField(
                            controller: _phoneController,
                            decoration: InputDecoration(
                              hintText: '+34 600 000 000',
                              hintStyle: GoogleFonts.manrope(
                                color: AppColors.secondaryText,
                              ),
                              filled: true,
                              fillColor: AppColors.secondaryBackground,
                              contentPadding: const EdgeInsets.symmetric(
                                  vertical: 12, horizontal: 16),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                            ),
                            style: GoogleFonts.manrope(
                              color: AppColors.primaryText,
                            ),
                            keyboardType: TextInputType.phone,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    // --------------------------------
                    // Save Changes button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isSaving ? null : _saveChanges, // Disable if saving
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: _isSaving
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(
                                'Guardar cambios',
                                style: GoogleFonts.manrope(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.secondaryBackground,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
      ),
    );
  }
}
