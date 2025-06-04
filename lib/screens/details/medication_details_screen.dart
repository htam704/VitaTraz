import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;

import 'package:fl_vitatraz_app/theme/theme.dart';

class MedicationDetailScreen extends StatefulWidget {
  final String nregistro;

  const MedicationDetailScreen({
    super.key,
    required this.nregistro,
  });

  @override
  State<MedicationDetailScreen> createState() => _MedicationDetailScreenState();
}

class _MedicationDetailScreenState extends State<MedicationDetailScreen> {
  late Future<Map<String, dynamic>> _detailFuture;

  @override
  void initState() {
    super.initState();
    // initialize future to fetch medication detail
    _detailFuture = fetchMedicationDetail(widget.nregistro);
  }

  // fetch detailed medication data from API using nregistro
  Future<Map<String, dynamic>> fetchMedicationDetail(String nregistro) async {
    final uri = Uri.https(
      'cima.aemps.es',
      '/cima/rest/medicamento',
      {'nregistro': nregistro},
    );
    final response = await http.get(uri);
    if (response.statusCode == 200) {
      // parse JSON response into a map
      return jsonDecode(response.body) as Map<String, dynamic>;
    } else {
      throw Exception('Error loading detail: ${response.statusCode}');
    }
  }

  // convert boolean-like values to "Sí"/"No" or "No aplica"
  String boolToSiNo(dynamic b) {
    if (b == null) return 'No aplica';
    if (b is bool) return b ? 'Sí' : 'No';
    final s = b.toString().toLowerCase();
    return (s == 'true') ? 'Sí' : 'No';
  }

  @override
  Widget build(BuildContext context) {
    final safeTop = MediaQuery.of(context).padding.top;
    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      body: Column(
        children: [
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
              top: safeTop + 20, // account for status bar
              left: 16,
              right: 16,
              bottom: 32,
            ),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(), // go back on tap
                  child: const Icon(
                    Icons.arrow_back,
                    color: AppColors.secondaryBackground,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    'Detalles Medicamentos',
                    style: GoogleFonts.manrope(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      color: AppColors.secondaryBackground,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: FutureBuilder<Map<String, dynamic>>(
              future: _detailFuture, // future that fetches data
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  // show loading indicator while waiting
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  // display error message if fetch failed
                  return Center(
                    child: Text(
                      'Error: ${snapshot.error}',
                      style: GoogleFonts.manrope(
                        fontSize: 16,
                        color: AppColors.primaryText,
                      ),
                    ),
                  );
                }

                final data = snapshot.data!;

                // extract fields with default fallback to empty string
                final registro = (data['nregistro'] ?? '').toString();
                final nombre = (data['nombre'] ?? '').toString();
                final labTitular = (data['labtitular'] ?? '').toString();
                final labComer = (data['labcomercializador'] ?? '').toString();
                final cpresc = (data['cpresc'] ?? '').toString();
                final dosis = (data['dosis'] ?? '').toString();

                // convert flags to "Sí"/"No"
                final comercializado = boolToSiNo(data['comerc']);
                final requiereReceta = boolToSiNo(data['receta']);
                final generico = boolToSiNo(data['generico']);
                final controlado = boolToSiNo(data['conduc']);
                final triangulo = boolToSiNo(data['triangulo']);
                final huerfano = boolToSiNo(data['huerfano']);
                final biosimilar = boolToSiNo(data['biosimilar']);
                final ema = boolToSiNo(data['ema']);
                final psum = boolToSiNo(data['psum']);
                final notas = boolToSiNo(data['notas']);
                final materialesInf = boolToSiNo(data['materialesInf']);

                // parse active principles list
                List<String> principiosActivosTexto = [];
                if (data['principiosActivos'] is List) {
                  final lista = data['principiosActivos'] as List<dynamic>;
                  for (var item in lista) {
                    if (item is Map<String, dynamic>) {
                      final nombrePA = (item['nombre'] ?? '').toString();
                      final cantidad = (item['cantidad'] ?? '').toString();
                      final unidad = (item['unidad'] ?? '').toString();
                      principiosActivosTexto.add('$nombrePA: $cantidad $unidad');
                    }
                  }
                }

                // parse administration routes list
                List<String> viasTexto = [];
                if (data['viasAdministracion'] is List) {
                  final lista = data['viasAdministracion'] as List<dynamic>;
                  for (var item in lista) {
                    if (item is Map<String, dynamic>) {
                      viasTexto.add((item['nombre'] ?? '').toString());
                    }
                  }
                }

                // parse presentations list
                List<String> presentacionesTexto = [];
                if (data['presentaciones'] is List) {
                  final lista = data['presentaciones'] as List<dynamic>;
                  for (var item in lista) {
                    if (item is Map<String, dynamic>) {
                      final cn = (item['cn'] ?? '').toString();
                      final nombreP = (item['nombre'] ?? '').toString();
                      final comen = boolToSiNo(item['comerc']);
                      presentacionesTexto
                          .add('($cn) $nombreP — Comercializado: $comen');
                    }
                  }
                }

                // parse excipients list
                List<String> excipientesTexto = [];
                if (data['excipientes'] is List) {
                  final lista = data['excipientes'] as List<dynamic>;
                  for (var item in lista) {
                    if (item is Map<String, dynamic>) {
                      final nombreE = (item['nombre'] ?? '').toString();
                      final cantidad = (item['cantidad'] ?? '').toString();
                      final unidad = (item['unidad'] ?? '').toString();
                      excipientesTexto.add('$nombreE: $cantidad $unidad');
                    }
                  }
                }

                // parse photo URLs list
                List<String> fotosUrls = [];
                if (data['fotos'] is List) {
                  final lista = data['fotos'] as List<dynamic>;
                  for (var item in lista) {
                    if (item is Map<String, dynamic>) {
                      final url = (item['url'] ?? '').toString();
                      if (url.isNotEmpty) fotosUrls.add(url);
                    }
                  }
                }

                // extract pharmaceutical form names
                final formaFarm = (data['formaFarmaceutica']?['nombre'] ?? '').toString();
                final formaFarmSimpl =
                    (data['formaFarmaceuticaSimplificada']?['nombre'] ?? '').toString();

                // extract VTM and non-substitutable names
                final vtm = (data['vtm']?['nombre'] ?? '').toString();
                final nosustituible = (data['nosustituible']?['nombre'] ?? '').toString();

                // render UI
                return ListView(
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                  children: [
                    // Identification section
                    const SectionHeaderWithIcon(
                      title: 'Identificación',
                      icon: Icons.medical_services_outlined,
                    ),
                    LabelValueCard(
                      label: 'Registro',
                      value: registro,
                    ),
                    LabelValueCard(
                      label: 'Nombre',
                      value: nombre,
                    ),
                    const SizedBox(height: 24),

                    // active principles section
                    if (principiosActivosTexto.isNotEmpty) ...[
                      const SectionHeaderWithIcon(
                        title: 'Principios Activos',
                        icon: Icons.science_outlined,
                      ),
                      const SizedBox(height: 8),
                      ...principiosActivosTexto.map((pa) => SingleLineCard(text: pa)),
                      const SizedBox(height: 24),
                    ],

                    // laboratories section
                    const SectionHeaderWithIcon(
                      title: 'Laboratorios',
                      icon: Icons.biotech_outlined,
                    ),
                    const SizedBox(height: 8),
                    MultiValueCard(
                      values: {
                        'Titular': labTitular,
                        if (labComer.isNotEmpty) 'Comercializador': labComer,
                      },
                    ),
                    const SizedBox(height: 24),

                    // prescription and authorization section
                    if (cpresc.isNotEmpty) ...[
                      const SectionHeaderWithIcon(
                        title: 'Prescripción y Autorización',
                        icon: Icons.receipt_long_outlined,
                      ),
                      const SizedBox(height: 8),
                      MultiValueCard(
                        values: {
                          'Código Prescripción': cpresc,
                        },
                      ),
                      const SizedBox(height: 24),
                    ],

                    // regulation info section in two columns
                    const SectionHeaderWithIcon(
                      title: 'Información de Regulación',
                      icon: Icons.verified_outlined,
                    ),
                    const SizedBox(height: 8),
                    LayoutBuilder(builder: (context, constraints) {
                      final itemWidth = (constraints.maxWidth - 16) / 2;
                      final regulacionEntries = {
                        'Comercializado': comercializado,
                        'Requiere Receta': requiereReceta,
                        'Genérico': generico,
                        'Controlado': controlado,
                        'Triángulo': triangulo,
                        'Huérfano': huerfano,
                        'Biosimilar': biosimilar,
                        'EMA': ema,
                        'PSUM': psum,
                        'Notas': notas,
                        'Materiales Inf.': materialesInf,
                      }.entries.where((e) => e.value.isNotEmpty).toList();

                      return Wrap(
                        spacing: 16,
                        runSpacing: 12,
                        children: regulacionEntries.map((entry) {
                          return SizedBox(
                            width: itemWidth,
                            child: Card(
                              color: AppColors.secondaryBackground,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 2,
                              shadowColor: AppColors.primary.withOpacity(0.1),
                              margin: const EdgeInsets.symmetric(vertical: 6),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      entry.key,
                                      style: GoogleFonts.manrope(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.primaryText,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      entry.value,
                                      style: GoogleFonts.manrope(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w400,
                                        color: AppColors.primaryText,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      );
                    }),
                    const SizedBox(height: 24),

                    // administration routes section
                    if (viasTexto.isNotEmpty) ...[
                      const SectionHeaderWithIcon(
                        title: 'Vías de Administración',
                        icon: Icons.local_pharmacy_outlined,
                      ),
                      const SizedBox(height: 8),
                      LabelValueCard(
                        label: 'Vía',
                        value: viasTexto.join(', '),
                      ),
                      const SizedBox(height: 24),
                    ],

                    // pharmaceutical form section
                    if (formaFarm.isNotEmpty || formaFarmSimpl.isNotEmpty) ...[
                      const SectionHeaderWithIcon(
                        title: 'Forma Farmacéutica',
                        icon: Icons.category_outlined,
                      ),
                      const SizedBox(height: 8),
                      MultiValueCard(values: {
                        if (formaFarm.isNotEmpty) 'Formato': formaFarm,
                        if (formaFarmSimpl.isNotEmpty) 'Simplificada': formaFarmSimpl,
                      }),
                      const SizedBox(height: 24),
                    ],

                    // VTM & dosage section
                    if (vtm.isNotEmpty || dosis.isNotEmpty) ...[
                      const SectionHeaderWithIcon(
                        title: 'VTM y Dosis',
                        icon: Icons.medication_outlined,
                      ),
                      const SizedBox(height: 8),
                      MultiValueCard(values: {
                        if (vtm.isNotEmpty) 'VTM': vtm,
                        if (dosis.isNotEmpty) 'Dosis': dosis,
                      }),
                      const SizedBox(height: 24),
                    ],

                    // presentations section
                    if (presentacionesTexto.isNotEmpty) ...[
                      const SectionHeaderWithIcon(
                        title: 'Presentaciones',
                        icon: Icons.inventory_2_outlined,
                      ),
                      const SizedBox(height: 8),
                      ...presentacionesTexto.map((pres) => SingleLineCard(text: pres)),
                      const SizedBox(height: 24),
                    ],

                    // excipients section
                    if (excipientesTexto.isNotEmpty) ...[
                      const SectionHeaderWithIcon(
                        title: 'Excipientes',
                        icon: Icons.grain_outlined,
                      ),
                      const SizedBox(height: 8),
                      ...excipientesTexto.map((exc) => SingleLineCard(text: exc)),
                      const SizedBox(height: 24),
                    ],

                    // non-substitutable section
                    if (nosustituible.isNotEmpty) ...[
                      const SectionHeaderWithIcon(
                        title: 'No Sustituible',
                        icon: Icons.block_flipped,
                      ),
                      const SizedBox(height: 8),
                      LabelValueCard(label: 'No Sustituible', value: nosustituible),
                      const SizedBox(height: 24),
                    ],

                    // photos carousel at the end
                    if (fotosUrls.isNotEmpty) ...[
                      const SectionHeaderWithIcon(
                        title: 'Fotos',
                        icon: Icons.photo_library_outlined,
                      ),
                      const SizedBox(height: 8),
                      ImageCarousel(imageUrls: fotosUrls),
                      const SizedBox(height: 24),
                    ],
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// section header widget with icon and bold title
class SectionHeaderWithIcon extends StatelessWidget {
  final String title;
  final IconData icon;

  const SectionHeaderWithIcon({
    super.key,
    required this.title,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.primaryBackground.withOpacity(0.2),
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.primary),
          const SizedBox(width: 8),
          Text(
            title,
            style: GoogleFonts.manrope(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.primaryText,
            ),
          ),
        ],
      ),
    );
  }
}

/// card widget showing a label and its corresponding value
class LabelValueCard extends StatelessWidget {
  final String label;
  final String value;

  const LabelValueCard({
    super.key,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.secondaryBackground,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      elevation: 2,
      shadowColor: AppColors.primary.withOpacity(0.1),
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: GoogleFonts.manrope(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppColors.primaryText,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              value.isEmpty ? '—' : value,
              style: GoogleFonts.manrope(
                fontSize: 13,
                fontWeight: FontWeight.w400,
                color: AppColors.primaryText.withOpacity(0.9),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// card widget that groups multiple label→value pairs
class MultiValueCard extends StatelessWidget {
  final Map<String, String> values;

  const MultiValueCard({
    super.key,
    required this.values,
  });

  @override
  Widget build(BuildContext context) {
    if (values.isEmpty) return const SizedBox.shrink();

    return Card(
      color: AppColors.secondaryBackground,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      elevation: 2,
      shadowColor: AppColors.primary.withOpacity(0.1),
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (var entry in values.entries) ...[
              Text(
                entry.key,
                style: GoogleFonts.manrope(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryText,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                entry.value.isEmpty ? '—' : entry.value,
                style: GoogleFonts.manrope(
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                  color: AppColors.primaryText.withOpacity(0.9),
                ),
              ),
              const SizedBox(height: 12),
            ],
          ],
        ),
      ),
    );
  }
}

/// card widget showing a single line of text without empty-value dash
class SingleLineCard extends StatelessWidget {
  final String text;

  const SingleLineCard({
    Key? key,
    required this.text,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.secondaryBackground,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      elevation: 1,
      shadowColor: AppColors.primary.withOpacity(0.05),
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: Container(
        decoration: BoxDecoration(
          border: Border(
            left: BorderSide(
              color: AppColors.primary.withOpacity(0.5),
              width: 3,
            ),
          ),
          borderRadius: BorderRadius.circular(14),
        ),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        child: Text(
          text,
          style: GoogleFonts.manrope(
            fontSize: 13,
            fontWeight: FontWeight.w400,
            color: AppColors.primaryText.withOpacity(0.9),
          ),
        ),
      ),
    );
  }
}

/// horizontal carousel of image thumbnails displayed at the end
class ImageCarousel extends StatelessWidget {
  final List<String> imageUrls;

  const ImageCarousel({
    super.key,
    required this.imageUrls,
  });

  @override
  Widget build(BuildContext context) {
    if (imageUrls.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: 140,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        scrollDirection: Axis.horizontal,
        itemCount: imageUrls.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final url = imageUrls[index];
          return Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                url,
                width: 120,
                height: 120,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, progress) {
                  if (progress == null) return child;
                  return const SizedBox(
                    width: 120,
                    height: 120,
                    child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
                  );
                },
                errorBuilder: (_, __, ___) => Container(
                  width: 120,
                  height: 120,
                  color: Colors.grey[200],
                  child: const Icon(Icons.broken_image, color: Colors.grey),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
