import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import 'package:fl_vitatraz_app/components/components.dart';
import 'package:fl_vitatraz_app/screens/details/patient_details_screen.dart';
import 'package:fl_vitatraz_app/theme/app_colors.dart';

class PatientsScreen extends StatefulWidget {
  static const String routeName = '/patients';

  // Optional callback when a patient is selected
  final void Function(Map<String, dynamic> patient)? onPatientSelected;

  const PatientsScreen({super.key, this.onPatientSelected});

  @override
  State<PatientsScreen> createState() => _PatientsScreenState();
}

class _PatientsScreenState extends State<PatientsScreen> {
  // Controller for the search text field
  final _searchController = TextEditingController();
  // Timer to debounce search input
  Timer? _debounce;
  // Reference to the 'pacientes' collection in Firestore
  final _patientsCollection = FirebaseFirestore.instance.collection('pacientes');

  @override
  void initState() {
    super.initState();
    // Listen for changes in the search field and debounce them
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    // Remove listener and dispose controller when widget is destroyed
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  // --------------------------------
  // Called whenever the search input changes; applies a debounce before rebuilding
  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      setState(() {}); // Trigger rebuild to update filtered list
    });
  }

  // --------------------------------
  // Parse allergies from Firestore data which could be a List or comma-separated String
  List<String> _parseAllergies(dynamic raw) {
    if (raw is List) {
      return raw.cast<String>(); // Already a List<String>
    } else if (raw is String) {
      // Split comma-separated string into a list of trimmed values
      return raw
          .split(',')
          .map((s) => s.trim())
          .where((s) => s.isNotEmpty)
          .toList();
    } else {
      return <String>[]; // Return empty list if unexpected type
    }
  }

  // --------------------------------
  // Format Firestore Timestamp to 'dd/MM/yyyy' string
  String _formatDate(Timestamp ts) {
    final date = ts.toDate();
    return DateFormat('dd/MM/yyyy').format(date);
  }

  // --------------------------------
  // Check if patient name or DNI contains the search query
  bool _matchesQuery(String name, String dni, String query) {
    final q = query.toLowerCase();
    return name.toLowerCase().contains(q) || dni.toLowerCase().contains(q);
  }

  // --------------------------------
  // Retrieve patient image URL from Firebase Storage; return null if not found
  Future<String?> _getPatientImageUrl(String dni) async {
    try {
      final ref = FirebaseStorage.instance
          .ref()
          .child('vitatraz/pacientes/$dni.jpg');
      final url = await ref.getDownloadURL();
      return url;
    } catch (e) {
      return null; // No image available
    }
  }

  @override
  Widget build(BuildContext context) {
    // Safe area top padding to account for status bar / notch
    final safeTop = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      body: Column(
        children: [
          // ----------------------------------
          // HEADER SECTION
          Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(25),
                bottomRight: Radius.circular(25),
              ),
            ),
            padding: EdgeInsets.only(
              top: safeTop + 20, // Add space below status bar
              left: 16,
              right: 16,
              bottom: 24,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    // Back button to pop this screen
                    GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: const Icon(
                        Icons.arrow_back,
                        color: AppColors.secondaryBackground,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Screen title
                    Text(
                      'Pacientes',
                      style: GoogleFonts.manrope(
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                        color: AppColors.secondaryBackground,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // --------------------------------
                // SEARCH BAR SECTION
                Container(
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.secondaryBackground,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.search_rounded,
                        color: AppColors.secondaryText,
                      ),
                      const SizedBox(width: 12),
                      // Search text field
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          decoration: InputDecoration(
                            hintText: 'Buscar por DNI o nombre',
                            hintStyle: GoogleFonts.manrope(
                              fontSize: 16,
                              color: AppColors.secondaryText,
                            ),
                            border: InputBorder.none, // No default border
                          ),
                          style: GoogleFonts.manrope(
                            fontSize: 16,
                            color: AppColors.primaryText,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // --------------------------------
          // PATIENT LIST SECTION
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _patientsCollection.snapshots(), // Listen to patients collection
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  // Show loading indicator while waiting for Firestore data
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  // Show error message if something went wrong
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                final docs = snapshot.data!.docs; // All patient documents
                // Filter documents based on search query
                final filtered = docs.where((doc) {
                  final name = doc.get('nombre') as String;
                  final dni = doc.id;
                  return _matchesQuery(name, dni, _searchController.text);
                }).toList();

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: filtered.length, // Number of filtered patients
                  itemBuilder: (context, index) {
                    final doc = filtered[index];
                    final data = doc.data() as Map<String, dynamic>;
                    // Determine border color based on gender
                    final borderColor = (data['sexo'] as String)
                            .toLowerCase()
                            .contains('f')
                        ? AppColors.lightCoral
                        : AppColors.persianGreen;
                    // Use a neutral background for all cards
                    final cardBackground = AppColors.secondaryBackground;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 24),
                      child: FutureBuilder<String?>(
                        future: _getPatientImageUrl(doc.id), // Load avatar URL
                        builder: (context, imageSnapshot) {
                          // Build a map of patient data to pass as argument or callback
                          final patientMap = {
                            'nombre': data['nombre'],
                            'dni': doc.id,
                            'fechaNacimiento': data['fechaNacimiento'],
                            'sexo': data['sexo'],
                            'direccion': data['direccion'],
                            'telefono': data['telefono'],
                            'telefonoFamiliar': data['telefonoFamiliar'],
                            'email': data['email'],
                            'alergias': data['alergias'],
                            'comentario': data['comentario'],
                          };

                          return PatientCard(
                            name: data['nombre'] as String,
                            dni: doc.id,
                            birthdate:
                                _formatDate(data['fechaNacimiento'] as Timestamp),
                            allergies: _parseAllergies(data['alergias']),
                            backgroundColor: cardBackground, // Fixed neutral background
                            borderColor: borderColor, // Gender-based border color
                            avatarUrl: imageSnapshot.data, // Display avatar if available
                            onTap: () {
                              if (widget.onPatientSelected != null) {
                                // If callback provided, send data and pop
                                widget.onPatientSelected!(patientMap);
                                Navigator.of(context).pop();
                              } else {
                                // Otherwise navigate to PatientDetailsScreen
                                Navigator.pushNamed(
                                  context,
                                  PatientDetailsScreen.routeName,
                                  arguments: patientMap,
                                );
                              }
                            },
                          );
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
