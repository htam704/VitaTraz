import 'package:fl_vitatraz_app/components/components.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_vitatraz_app/theme/app_colors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class RecordDetailsScreen extends StatelessWidget {
  static const String routeName = '/recordDetails';

  final Map<String, dynamic> data;
  const RecordDetailsScreen({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    // Patient data
    final String patientName = data['patientName'] as String? ?? '';
    final String patientDni = data['patientDni'] as String? ?? '';

    final age = data['age'] as String? ?? '';
    final sex = data['sex'] as String? ?? '';

    // Admission date (Timestamp)
    final Timestamp? rawTs = data['fechaIngreso'] as Timestamp?;
    final String fechaIngresoStr = rawTs != null
        ? DateFormat('dd/MM/yyyy HH:mm').format(rawTs.toDate())
        : '';

    // Reason for admission and primary diagnosis
    final String motivoIngreso = data['motivoIngreso'] as String? ?? '';
    final String diagnosticoPrincipal =
        data['diagnosticoPrincipal'] as String? ?? '';

    // Notes field
    final String anotacion = data['anotacion'] as String? ?? '';

    // Medications field may be a list of maps or a list of IDs
    final dynamic rawMedicList = data['medicamentos'];
    final List<Map<String, String>> medsComoMap = [];
    final List<String> medsComoIds = [];

    if (rawMedicList is List) {
      for (final item in rawMedicList) {
        if (item is Map) {
          // Convert dynamic map to Map<String, String>
          final converted = <String, String>{};
          item.forEach((key, value) {
            converted[key.toString()] = value?.toString() ?? '';
          });
          medsComoMap.add(converted);
        } else {
          // Treat non-map entries as IDs
          medsComoIds.add(item.toString());
        }
      }
    }

    // Record ID
    final String recordId = data['recordId'] as String? ?? '';

    // Reference to patient document for fetching assigned nurses
    final pacienteRef =
        FirebaseFirestore.instance.collection('pacientes').doc(patientDni);

    // Fetch medication documents by IDs
    Future<List<QueryDocumentSnapshot>> _fetchMedByIds() async {
      if (medsComoIds.isEmpty) return [];
      final List<String> batch =
          medsComoIds.length > 10 ? medsComoIds.sublist(0, 10) : medsComoIds;
      final snapshot = await FirebaseFirestore.instance
          .collection('medicamentos')
          .where(FieldPath.documentId, whereIn: batch)
          .get();
      return snapshot.docs;
    }

    // Fetch nurses assigned to this patient
    Future<List<QueryDocumentSnapshot>> fetchAssignedNurses() async {
      final snapshot = await FirebaseFirestore.instance
          .collection('enfermeros')
          .where('pacientesAsignados', arrayContains: pacienteRef)
          .get();
      return snapshot.docs;
    }

    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        leading: const BackButton(color: AppColors.secondaryBackground),
        title: Text(
          'Detalles de la Ficha',
          style: GoogleFonts.manrope(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.secondaryBackground,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          children: [
            // 1. Patient Identification
            Section(
              title: 'Paciente',
              icon: Icons.person_outline,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text.rich(
                        TextSpan(children: [
                          TextSpan(
                            text: 'Nombre: ',
                            style: GoogleFonts.manrope(
                              fontWeight: FontWeight.w600,
                              color: AppColors.primaryText,
                            ),
                          ),
                          TextSpan(
                            text: patientName,
                            style: GoogleFonts.manrope(
                              color: AppColors.primaryText,
                            ),
                          ),
                        ]),
                      ),
                    ),
                    Expanded(
                      child: Text.rich(
                        TextSpan(children: [
                          TextSpan(
                            text: 'DNI/NIE: ',
                            style: GoogleFonts.manrope(
                              fontWeight: FontWeight.w600,
                              color: AppColors.primaryText,
                            ),
                          ),
                          TextSpan(
                            text: patientDni,
                            style: GoogleFonts.manrope(
                              color: AppColors.primaryText,
                            ),
                          ),
                        ]),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text.rich(
                  TextSpan(children: [
                    TextSpan(
                      text: 'ID: ',
                      style: GoogleFonts.manrope(
                        fontWeight: FontWeight.w600,
                        color: AppColors.primaryText,
                      ),
                    ),
                    TextSpan(
                      text: recordId,
                      style: GoogleFonts.manrope(
                        color: AppColors.primaryText,
                      ),
                    ),
                  ]),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // 2. Demographic and Clinical Data
            Section(
              title: 'Datos Clínicos y Demográficos',
              icon: Icons.medical_services_outlined,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text.rich(TextSpan(children: [
                        TextSpan(
                          text: 'Edad: ',
                          style: GoogleFonts.manrope(
                            fontWeight: FontWeight.w600,
                            color: AppColors.primaryText,
                          ),
                        ),
                        TextSpan(
                          text: age,
                          style: GoogleFonts.manrope(
                            color: AppColors.primaryText,
                          ),
                        ),
                      ])),
                    ),
                    Expanded(
                      child: Text.rich(TextSpan(children: [
                        TextSpan(
                          text: 'Género: ',
                          style: GoogleFonts.manrope(
                            fontWeight: FontWeight.w600,
                            color: AppColors.primaryText,
                          ),
                        ),
                        TextSpan(
                          text: sex,
                          style: GoogleFonts.manrope(
                            color: AppColors.primaryText,
                          ),
                        ),
                      ])),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 24),

            // 3. Admission Data
            Section(
              title: 'Datos de Admisión',
              icon: Icons.calendar_today_outlined,
              children: [
                Text.rich(
                  TextSpan(children: [
                    TextSpan(
                      text: 'Fecha y Hora: ',
                      style: GoogleFonts.manrope(
                        fontWeight: FontWeight.w600,
                        color: AppColors.primaryText,
                      ),
                    ),
                    TextSpan(
                      text: fechaIngresoStr,
                      style: GoogleFonts.manrope(
                        color: AppColors.primaryText,
                      ),
                    ),
                  ]),
                ),
                const SizedBox(height: 8),
                Text.rich(
                  TextSpan(children: [
                    TextSpan(
                      text: 'Motivo: ',
                      style: GoogleFonts.manrope(
                        fontWeight: FontWeight.w600,
                        color: AppColors.primaryText,
                      ),
                    ),
                    TextSpan(
                      text: motivoIngreso,
                      style: GoogleFonts.manrope(
                        color: AppColors.primaryText,
                      ),
                    ),
                  ]),
                ),
                const SizedBox(height: 8),
                Text.rich(
                  TextSpan(children: [
                    TextSpan(
                      text: 'Diagnóstico: ',
                      style: GoogleFonts.manrope(
                        fontWeight: FontWeight.w600,
                        color: AppColors.primaryText,
                      ),
                    ),
                    TextSpan(
                      text: diagnosticoPrincipal,
                      style: GoogleFonts.manrope(
                        color: AppColors.primaryText,
                      ),
                    ),
                  ]),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // 4. Supplied Medications
            Section(
              title: 'Medications',
              icon: Icons.local_hospital_outlined,
              children: [
                if (medsComoMap.isNotEmpty) ...[
                  // Case A: medication objects with name/schedule/route/lastDose
                  for (var med in medsComoMap) ...[
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            med['name'] ?? 'No name',
                            style: GoogleFonts.manrope(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primaryText,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  '${med['schedule'] ?? ''} • ${med['route'] ?? ''}',
                                  style: GoogleFonts.manrope(
                                    fontSize: 14,
                                    color: AppColors.primaryText,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    if (med != medsComoMap.last)
                      const Divider(
                        height: 24,
                        thickness: 1,
                        color: AppColors.lineColor,
                      ),
                  ],
                ] else if (medsComoIds.isNotEmpty) ...[
                  // Case B: medication IDs, fetch from 'medicamentos' collection
                  FutureBuilder<List<QueryDocumentSnapshot>>(
                    future: _fetchMedByIds(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (snapshot.hasError) {
                        return Text(
                          'Error cargando medicamentos.',
                          style: GoogleFonts.manrope(
                            color: Colors.red,
                            fontSize: 14,
                          ),
                        );
                      }
                      final docs = snapshot.data ?? [];
                      if (docs.isEmpty) {
                        return Text(
                          'No se encontraron medicamentos.',
                          style: GoogleFonts.manrope(
                            color: AppColors.secondaryText,
                            fontSize: 14,
                          ),
                        );
                      }
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: docs.map((medDoc) {
                          final medData = medDoc.data() as Map<String, dynamic>;
                          final medName =
                              medData['nombre'] as String? ?? 'No name';
                          final medDesc =
                              medData['descripcion'] as String? ?? '';
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  medName,
                                  style: GoogleFonts.manrope(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.primaryText,
                                  ),
                                ),
                                if (medDesc.isNotEmpty) ...[
                                  const SizedBox(height: 4),
                                  Text(
                                    medDesc,
                                    style: GoogleFonts.manrope(
                                      fontSize: 14,
                                      color: AppColors.primaryText,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          );
                        }).toList(),
                      );
                    },
                  ),
                ] else ...[
                  // Neither objects nor IDs → no medications registered
                  Text(
                    'No hay medicamentos registrados.',
                    style: GoogleFonts.manrope(
                      color: AppColors.secondaryText,
                      fontSize: 14,
                    ),
                  ),
                ],
              ],
            ),

            const SizedBox(height: 16),

            // 5. Notes
            Section(
              title: 'Notas',
              icon: Icons.comment_outlined,
              children: anotacion.isNotEmpty
                  ? anotacion
                      .split('\n')
                      .map((line) => line.trim())
                      .where((line) => line.isNotEmpty)
                      .map((line) => Padding(
                            padding: const EdgeInsets.only(bottom: 6),
                            child: Text(
                              '• $line',
                              style: GoogleFonts.manrope(
                                fontSize: 14,
                                color: AppColors.primaryText,
                              ),
                            ),
                          ))
                      .toList()
                  : [
                      Text(
                        'Sin notas registradas.',
                        style: GoogleFonts.manrope(
                          color: AppColors.secondaryText,
                          fontSize: 14,
                        ),
                      ),
                    ],
            ),

            const SizedBox(height: 16),

            // 6. Assigned Nurses
            Section(
              title: 'Enfermeros asignados',
              icon: Icons.people_alt_outlined,
              children: [
                FutureBuilder<List<QueryDocumentSnapshot>>(
                  future: fetchAssignedNurses(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return Text(
                        'Error cargando enfermeros.',
                        style: GoogleFonts.manrope(
                          color: Colors.red,
                          fontSize: 14,
                        ),
                      );
                    }
                    final docs = snapshot.data ?? [];
                    if (docs.isEmpty) {
                      return Text(
                        'Sin enfermeros asignados.',
                        style: GoogleFonts.manrope(
                          color: AppColors.secondaryText,
                          fontSize: 14,
                        ),
                      );
                    }
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: docs.map((nurseDoc) {
                        final nurseData =
                            nurseDoc.data() as Map<String, dynamic>;
                        final nurseName =
                            nurseData['nombre'] as String? ?? 'Sin nombre';
                        final nursePhone =
                            nurseData['numeroTelefono']?.toString() ?? '';
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                nurseName,
                                style: GoogleFonts.manrope(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.primaryText,
                                ),
                              ),
                              if (nursePhone.isNotEmpty) ...[
                                const SizedBox(height: 2),
                                Text(
                                  'Tlfno: $nursePhone',
                                  style: GoogleFonts.manrope(
                                    fontSize: 14,
                                    color: AppColors.primaryText,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        );
                      }).toList(),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
