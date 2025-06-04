import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

import 'package:fl_vitatraz_app/components/records/patient_record.dart';
import 'package:fl_vitatraz_app/screens/screens.dart';
import 'package:fl_vitatraz_app/theme/app_colors.dart';

class RecordsScreen extends StatefulWidget {
  static const String routeName = '/records';

  const RecordsScreen({super.key});

  @override
  State<RecordsScreen> createState() => _RecordsScreenState();
}

class _RecordsScreenState extends State<RecordsScreen> {
  // Controller for the search input field
  final _searchController = TextEditingController();
  // Timer to debounce search input
  Timer? _debounce;

  // List holding all records fetched from Firestore
  List<Map<String, dynamic>> _allRecords = [];
  // List holding records filtered by the search query
  List<Map<String, dynamic>> _filteredRecords = [];

  // Firestore instance to query data
  final _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    // Listen for changes in the search field and debounce them
    _searchController.addListener(_onSearchChanged);
    // Load all records on initialization
    _loadAllRecords();
  }

  @override
  void dispose() {
    // Remove listener and dispose controller when widget is destroyed
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  // Called whenever the search input changes; debounces before rebuilding
  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      final query = _searchController.text.toLowerCase().trim();
      setState(() {
        if (query.isEmpty) {
          // If the search query is empty, show all records
          _filteredRecords = List.from(_allRecords);
        } else {
          // Otherwise, filter records where patientName or patientDni contains query
          _filteredRecords = _allRecords.where((rec) {
            final name = (rec['patientName'] as String).toLowerCase();
            final dni = (rec['patientDni'] as String).toLowerCase();
            return name.contains(query) || dni.contains(query);
          }).toList();
        }
      });
    });
  }

  // Load all patient records using collectionGroup('fichas') and cache patient data
  Future<void> _loadAllRecords() async {
    final List<Map<String, dynamic>> tempList = [];
    // Cache to avoid repeated reads of the same patient document
    final Map<DocumentReference, Map<String, dynamic>> pacienteCache = {};

    // Query all 'fichas' subcollections across Firestore, ordered by 'fechaIngreso' descending
    final fichasQuery = _firestore
        .collectionGroup('fichas')
        .orderBy('fechaIngreso', descending: true);

    final fichasSnapshot = await fichasQuery.get();

    for (final fichaDoc in fichasSnapshot.docs) {
      final fichaData = fichaDoc.data();

      // Parent of 'fichas' collection is the patient's document
      final patientCollection = fichaDoc.reference.parent.parent;
      if (patientCollection == null) {
        continue; // Skip if parent not found
      }

      // If patient data not cached, fetch and store in cache
      if (!pacienteCache.containsKey(patientCollection)) {
        final pacienteSnap = await patientCollection.get();
        final pacienteMap = pacienteSnap.data() ?? {};
        pacienteCache[patientCollection] = {
          'patientName': pacienteMap['nombre'] as String? ?? '',
          'patientDni': pacienteSnap.id,
          'patientSexo': pacienteMap['sexo'] as String? ?? '',
          'patientBirthTs': pacienteMap['fechaNacimiento'] as Timestamp?,
          'patientAvatar': pacienteMap['avatarUrl'] as String? ?? '',
        };
      }

      final pacienteInfo = pacienteCache[patientCollection]!;

      // Convert 'fechaIngreso' Timestamp to DateTime and format as string
      Timestamp? rawTs = fichaData['fechaIngreso'] as Timestamp?;
      DateTime? fechaIngresoDt = rawTs?.toDate();
      final fechaIngresoStr = fechaIngresoDt != null
          ? DateFormat('dd/MM/yyyy').format(fechaIngresoDt)
          : '';

      // Calculate patient age at time of record admission
      String edadStr = '';
      final birthTs = pacienteInfo['patientBirthTs'] as Timestamp?;
      if (fechaIngresoDt != null && birthTs != null) {
        final birthDt = birthTs.toDate();
        final diff = fechaIngresoDt.difference(birthDt);
        final ageYears = (diff.inDays / 365.25).floor();
        edadStr = ageYears.toString();
      }

      // Build a unified map combining patient and record data
      final recordMap = <String, dynamic>{
        'patientName': pacienteInfo['patientName'] as String,
        'patientDni': pacienteInfo['patientDni'] as String,
        'recordId': fichaDoc.id,
        'fechaIngreso': rawTs, // original Timestamp
        'motivoIngreso': fichaData['motivoIngreso'] as String? ?? '',
        'diagnosticoPrincipal':
            fichaData['diagnosticoPrincipal'] as String? ?? '',
        'anotacion': fichaData['anotacion'] as String? ?? '',
        'medicamentos': fichaData['medicamentos'] as List<dynamic>? ?? <int>[],
        'enfermeroRef': fichaData['enfermeroRef'] as DocumentReference?,
        // Additional fields for UI:
        'createdTs': fechaIngresoDt,    // DateTime for sorting
        'createdDate': fechaIngresoStr, // String for display on card
        'age': edadStr,                 // Calculated age string
        'sex': pacienteInfo['patientSexo'] as String,
        'avatar': pacienteInfo['patientAvatar'] as String,
      };

      tempList.add(recordMap);
    }

    // Sort the list locally by 'createdTs' descending (newest first)
    tempList.sort((a, b) {
      final aDt = a['createdTs'] as DateTime?;
      final bDt = b['createdTs'] as DateTime?;
      if (aDt == null && bDt == null) return 0;
      if (aDt == null) return 1;
      if (bDt == null) return -1;
      return bDt.compareTo(aDt);
    });

    setState(() {
      _allRecords = tempList;
      _filteredRecords = List.from(_allRecords);
    });
  }

  @override
  Widget build(BuildContext context) {
    // Safe area top padding to account for status bar / notch
    final safeTop = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      // --------------------------------
      // Floating button to navigate to CreateRecordScreen and refresh on return
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, size: 28),
        onPressed: () async {
          final created = await Navigator.push<bool>(
            context,
            MaterialPageRoute(
              builder: (_) => const CreateRecordScreen(),
            ),
          );
          if (created == true) {
            _loadAllRecords(); // Reload records if a new one was created
          }
        },
      ),
      body: Column(
        children: [
          // --------------------------------------
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
              top: safeTop + 20, // Add extra top padding below status bar
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
                      'Fichas Médicas',
                      style: GoogleFonts.manrope(
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                        color: AppColors.secondaryBackground,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // --------------------------------------
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
                      // Search TextField for filtering records by patient name or DNI
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          decoration: InputDecoration(
                            hintText: 'Buscar por DNI o nombre',
                            hintStyle: GoogleFonts.manrope(
                              fontSize: 16,
                              color: AppColors.secondaryText,
                            ),
                            border: InputBorder.none, // Remove default border
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
          // --------------------------------------
          // RECORD LIST SECTION
          Expanded(
            child: _filteredRecords.isEmpty
                ? Center(
                    child: _allRecords.isEmpty
                        // Show loading indicator while initial load is in progress
                        ? const CircularProgressIndicator()
                        // Show message if no records match the search
                        : Text(
                            'Ninguna ficha encontrada.',
                            style: GoogleFonts.manrope(
                              fontSize: 16,
                              color: AppColors.secondaryText,
                            ),
                          ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _filteredRecords.length,
                    itemBuilder: (context, i) {
                      final r = _filteredRecords[i];

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 24),
                        child: PatientRecord(
                          name:        r['patientName'] as String,
                          dni:         r['patientDni'] as String,
                          createdDate: r['createdDate'] as String,
                          diagnosis:   r['diagnosticoPrincipal'] as String,
                          reason:      r['motivoIngreso'] as String,
                          age:         r['age'] as String,
                          sex:         r['sex'] as String,
                          avatarUrl:   (r['avatar'] as String).isEmpty
                              ? null
                              : r['avatar'] as String,
                          onTap: () {
                            // Navigate to RecordDetailsScreen with record data
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    RecordDetailsScreen(data: r),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
