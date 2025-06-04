import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;

import 'package:fl_vitatraz_app/components/medications/medication_card.dart';
import 'package:fl_vitatraz_app/models/medicamento.dart';
import 'package:fl_vitatraz_app/screens/screens.dart';
import 'package:fl_vitatraz_app/theme/theme.dart';

class MedicationsScreen extends StatefulWidget {
  static const String routeName = '/medications';

  // Callback when a medication is selected: returns a map with 'name' and 'schedule'
  final void Function(Map<String, String> med)? onMedicationSelected;

  const MedicationsScreen({super.key, this.onMedicationSelected});

  @override
  State<MedicationsScreen> createState() => _MedicationsScreenState();
}

class _MedicationsScreenState extends State<MedicationsScreen> {
  // List to hold all fetched medications
  List<Medicamento> _allMeds = [];
  // List to hold filtered medications según búsqueda
  List<Medicamento> _filteredMeds = [];
  // Flag to indicate loading state
  bool _isLoading = true;

  // Controlador y timer para debounce en búsqueda
  final _searchController = TextEditingController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _loadMeds(); // Load medications when screen initializes
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController
      ..removeListener(_onSearchChanged)
      ..dispose();
    _debounce?.cancel();
    super.dispose();
  }

  // --------------------------------
  // Load medications and handle errors
  Future<void> _loadMeds() async {
    try {
      _allMeds = await fetchAllMeds(); // Fetch list from API
      setState(() {
        _filteredMeds = List.from(_allMeds); // Inicialmente, sin filtro
        _isLoading = false; // Stop loading indicator on success
      });
    } catch (e) {
      setState(() {
        _isLoading = false; // Stop loading indicator on error
      });
      // Show error message in a SnackBar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar medicamentos: $e')),
      );
    }
  }

  // --------------------------------
  // Fetch all medications from paginated API
  Future<List<Medicamento>> fetchAllMeds() async {
    List<Medicamento> allMeds = [];
    int pagina = 1;
    int totalPaginas = 1;

    // Loop through pages until all are fetched
    while (pagina <= totalPaginas) {
      final uri = Uri.https(
        'cima.aemps.es',
        '/cima/rest/medicamentos',
        {'pagina': pagina.toString()}, // Query parameter for page number
      );
      final response = await http.get(uri); // GET request to API

      if (response.statusCode == 200) {
        final jsonMap = jsonDecode(response.body) as Map<String, dynamic>;
        // Extract results list from JSON
        final List<dynamic> jsonList = jsonMap['resultados'] as List<dynamic>;
        // Map each JSON object to a Medicamento instance
        final pageMeds = jsonList
            .map((e) => Medicamento.fromJson(e as Map<String, dynamic>))
            .toList();
        allMeds.addAll(pageMeds); // Add current page meds to full list

        // Update total pages from response (default 1 if missing)
        totalPaginas = jsonMap['numPaginas'] ?? 1;
        pagina++; // Move to next page
      } else {
        // Throw exception if status code is not 200
        throw Exception('Código de error: ${response.statusCode}');
      }
    }
    return allMeds; // Return complete list of medications
  }

  Future<List<Medicamento>> fetchMedByNregistro(String nregistro) async {
    final uri = Uri.https(
      'cima.aemps.es',
      '/cima/rest/medicamento',
      {'nregistro': nregistro},
    );

    final response = await http.get(uri);
    if (response.statusCode == 200) {
      final jsonMap = jsonDecode(response.body);
      return [Medicamento.fromJson(jsonMap)];
    } else {
      throw Exception('Error al buscar medicamento: ${response.statusCode}');
    }
  }

  Future<List<Medicamento>> fetchMedsByNombre(String nombre) async {
    final uri = Uri.https(
      'cima.aemps.es',
      '/cima/rest/medicamentos',
      {
        'nombre': nombre,
        'pagina': '1',
      },
    );

    final response = await http.get(uri);
    if (response.statusCode == 200) {
      final jsonMap = jsonDecode(response.body) as Map<String, dynamic>;
      final List<dynamic> jsonList = jsonMap['resultados'] as List<dynamic>;
      return jsonList
          .map((e) => Medicamento.fromJson(e as Map<String, dynamic>))
          .toList();
    } else {
      throw Exception('Error al buscar medicamentos: ${response.statusCode}');
    }
  }

  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () async {
      final q = _searchController.text.toLowerCase().trim();

      if (q.isEmpty) {
        setState(() {
          _filteredMeds = List.from(_allMeds);
        });
        return;
      }

      try {
        List<Medicamento> meds;
        if (RegExp(r'^\d+$').hasMatch(q)) {
          meds = await fetchMedByNregistro(q);
        } else {
          meds = await fetchMedsByNombre(q);
        }

        setState(() {
          _filteredMeds = meds;
        });
      } catch (e) {
        setState(() {
          _filteredMeds = [];
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Padding at top to account for status bar (notch)
    final safeTop = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      body: Column(
        children: [
          // --------------------------------
          // Header Container with back button and title
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
              top: safeTop + 20, // Space for status bar + extra
              left: 16,
              right: 16,
              bottom: 32,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.of(context).pop(), // Go back on tap
                      child: const Icon(
                        Icons.arrow_back,
                        color: AppColors.secondaryBackground,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      'Medicamentos',
                      style: GoogleFonts.manrope(
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                        color: AppColors.secondaryBackground,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                // --------------------
                // Campo de búsqueda añadido
                Container(
                  height: 52,
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
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          decoration: InputDecoration(
                            hintText: 'Buscar...',
                            hintStyle: GoogleFonts.manrope(
                              fontSize: 16,
                              color: AppColors.secondaryText,
                            ),
                            border: InputBorder.none,
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
                // --------------------
              ],
            ),
          ),
          const SizedBox(height: 16),
          // --------------------------------
          // Main content: show loader, empty state, or lista filtrada
          _isLoading
              ? const Expanded(
                  child: Center(
                    child: CircularProgressIndicator(), // Loading indicator
                  ),
                )
              : _filteredMeds.isEmpty
                  ? const Expanded(
                      child: Center(
                        child: Text('No hay resultados'), // No results message
                      ),
                    )
                  : Expanded(
                      child: ListView.builder(
                        padding: EdgeInsets.zero,
                        itemCount: _filteredMeds.length, // Número de ítems filtrados
                        itemBuilder: (context, i) {
                          final med = _filteredMeds[i]; // Medicamento actual
                          return MedicationCard(
                            medicamento: med,
                            onTap: () {
                              // If a callback is provided, return selected med and pop
                              if (widget.onMedicationSelected != null) {
                                Navigator.of(context).pop({
                                  'name': med.nombre,
                                  'schedule': med.dosis,
                                });
                              } else {
                                // Otherwise, navigate to detail screen
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => MedicationDetailScreen(
                                      nregistro: med.nregistro,
                                    ),
                                  ),
                                );
                              }
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
