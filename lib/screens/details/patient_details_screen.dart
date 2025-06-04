import 'package:fl_vitatraz_app/screens/screens.dart';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_vitatraz_app/theme/theme.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class PatientDetailsScreen extends StatelessWidget {
  static const String routeName = '/patientDetails';

  // Receive a map with all patient data
  final Map<String, dynamic> data;
  const PatientDetailsScreen({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    // Avatar URL (may be empty)
    final avatar = (data['avatar'] as String?) ?? '';

    // Convert birthdate (could be Timestamp or String)
    String birthdate;
    final rawBirth = data['fechaNacimiento'];
    if (rawBirth is Timestamp) {
      birthdate = DateFormat('dd/MM/yyyy').format(rawBirth.toDate());
    } else {
      birthdate = rawBirth?.toString() ?? '';
    }

    // Convert allergies (could be List or comma-separated String)
    List<String> allergiesList;
    final rawAll = data['alergias'];
    if (rawAll is List) {
      allergiesList = rawAll.cast<String>();
    } else if (rawAll is String) {
      allergiesList = rawAll
          .split(',')
          .map((s) => s.trim())
          .where((s) => s.isNotEmpty)
          .toList();
    } else {
      allergiesList = <String>[];
    }
    final allergies = allergiesList.join(', ');

    // Phone numbers
    final phone = data['telefono']?.toString() ?? '';
    final familyPhone = data['telefonoFamiliar']?.toString() ?? '';

    // Other fields
    final dni = data['dni'] as String? ?? '';
    final name = data['nombre'] as String? ?? '';
    final sex = data['sexo'] as String? ?? '';
    final address = data['direccion'] as String? ?? '';
    final email = data['email'] as String? ?? '';
    final comment = data['comentario'] as String? ?? '';

    // Reference to patient document in Firestore
    final pacienteRef = FirebaseFirestore.instance.collection('pacientes').doc(dni);

    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        leading: const BackButton(color: AppColors.secondaryBackground),
        title: Text(
          'Detalles Pacientes',
          style: GoogleFonts.manrope(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: AppColors.secondaryBackground,
          ),
        ),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          children: [
            // Top card with avatar, name, and DNI
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.secondaryBackground,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  )
                ],
              ),
              child: Row(
                children: [
                  // Display avatar or default icon
                  CircleAvatar(
                    radius: 32,
                    backgroundImage: avatar.isNotEmpty ? NetworkImage(avatar) : null,
                    backgroundColor:
                        avatar.isEmpty ? AppColors.accent3 : Colors.transparent,
                    child: avatar.isEmpty
                        ? Icon(Icons.person, size: 32, color: AppColors.secondaryText)
                        : null,
                  ),
                  const SizedBox(width: 16),
                  // Display name and DNI
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: GoogleFonts.manrope(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primaryText,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        dni,
                        style: GoogleFonts.manrope(
                          fontSize: 14,
                          color: AppColors.secondaryText,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Personal Information section
            _buildSection(
              title: 'Información Personal',
              icon: Icons.person_outline,
              children: [
                _kv('DNI/NIE', dni),
                _kv('Name', name),
                _kv('Sex', sex),
                _kv('Birthdate', birthdate),
                _kv('Address', address),
                _kv('Phone', phone),
                _kv('Family Phone', familyPhone),
                _kv('Email', email),
              ],
            ),

            const SizedBox(height: 16),

            // Medical Information section
            _buildSection(
              title: 'Información Médica',
              icon: Icons.medical_services_outlined,
              children: [
                _kv('Allergies', allergies),
              ],
            ),

            const SizedBox(height: 16),

            // Comments section
            _buildSection(
              title: 'Comentarios',
              icon: Icons.comment_outlined,
              children: comment.isNotEmpty
                  ? comment
                      .split(';')
                      .map((c) => c.trim())
                      .where((c) => c.isNotEmpty)
                      .map((c) => _bullet(c))
                      .toList()
                  : [
                      Text(
                        'Sin comentarios.',
                        style: GoogleFonts.manrope(
                          fontSize: 14,
                          color: AppColors.secondaryText,
                        ),
                      ),
                    ],
            ),

            const SizedBox(height: 16),

            // Dynamic list of clinical records
            StreamBuilder<QuerySnapshot>(
              stream: pacienteRef
                  .collection('fichas')
                  .orderBy('fechaIngreso', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  // Show loading indicator while fetching records
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                if (snapshot.hasError) {
                  // Show error message if fetch fails
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: Text(
                      'Error cargando fichas: ${snapshot.error}',
                      style: GoogleFonts.manrope(
                        fontSize: 14,
                        color: Colors.red,
                      ),
                    ),
                  );
                }

                final docs = snapshot.data!.docs;
                if (docs.isEmpty) {
                  // Show message if no records available
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: Text(
                      'No hay fichas disponibles.',
                      style: GoogleFonts.manrope(
                        fontSize: 14,
                        color: AppColors.secondaryText,
                      ),
                    ),
                  );
                }

                // Display each record in a custom card
                return _buildSection(
                  title: 'Fichas Clínicas',
                  icon: Icons.folder_open_outlined,
                  children: docs.map((fichaDoc) {
                    final fichaData = fichaDoc.data() as Map<String, dynamic>;

                    // Convert fechaIngreso to string
                    String fechaIngresoStr = '';
                    DateTime? fechaIngresoDt;
                    final rawFecha = fichaData['fechaIngreso'] as Timestamp?;
                    if (rawFecha != null) {
                      fechaIngresoDt = rawFecha.toDate();
                      fechaIngresoStr =
                          DateFormat('dd/MM/yyyy HH:mm').format(fechaIngresoDt);
                    }

                    // Extract relevant fields from record
                    final motivo = fichaData['motivoIngreso'] as String? ?? '';
                    final diagPrincipal =
                        fichaData['diagnosticoPrincipal'] as String? ?? '';
                    final anotacion = fichaData['anotacion'] as String? ?? '';

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: GestureDetector(
                        onTap: () {
                          // Get sex directly from patient data
                          final patientSex = data['sexo'] as String? ?? '';

                          // Convert birthdate to DateTime if Timestamp
                          DateTime? birthDate;
                          final rawBirth = data['fechaNacimiento'];
                          if (rawBirth is Timestamp) {
                            birthDate = rawBirth.toDate();
                          } else if (rawBirth is String) {
                            // Attempt to parse string-formatted date "dd/MM/yyyy"
                            try {
                              final parts = rawBirth.split('/');
                              birthDate = DateTime(
                                int.parse(parts[2]),
                                int.parse(parts[1]),
                                int.parse(parts[0]),
                              );
                            } catch (_) {
                              birthDate = null;
                            }
                          }

                          // Original fechaIngreso Timestamp
                          final fechaIngresoTimestamp = rawFecha;

                          // Calculate age at time of record admission
                          String ageStr = '';
                          if (birthDate != null && fechaIngresoTimestamp != null) {
                            final ingresoDt = fechaIngresoTimestamp.toDate();
                            final diff = ingresoDt.difference(birthDate);
                            final years = (diff.inDays / 365.25).floor();
                            ageStr = years.toString();
                          }

                          // Build map with additional 'sex' and 'age'
                          final recordMap = <String, dynamic>{
                            'patientDni': dni,
                            'patientName': name,
                            'sex': patientSex,
                            'age': ageStr,
                            'recordId': fichaDoc.id,
                            'fechaIngreso': rawFecha,
                            'motivoIngreso': motivo,
                            'diagnosticoPrincipal': diagPrincipal,
                            'anotacion': anotacion,
                            'medicamentos': fichaData['medicamentos'] ?? <int>[],
                            'enfermeroRef': fichaData['enfermeroRef'],
                          };

                          Navigator.pushNamed(
                            context,
                            RecordDetailsScreen.routeName,
                            arguments: recordMap,
                          );
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: AppColors.secondaryBackground,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.03),
                                blurRadius: 6,
                                offset: const Offset(0, 3),
                              )
                            ],
                          ),
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            children: [
                              Icon(Icons.insert_drive_file_outlined,
                                  color: AppColors.primary),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (fechaIngresoStr.isNotEmpty)
                                      Text(
                                        fechaIngresoStr,
                                        style: GoogleFonts.manrope(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.primary,
                                        ),
                                      ),
                                    const SizedBox(height: 4),
                                    Text(
                                      motivo,
                                      style: GoogleFonts.manrope(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.primaryText,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      diagPrincipal,
                                      style: GoogleFonts.manrope(
                                        fontSize: 14,
                                        color: AppColors.primaryText,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(Icons.arrow_forward_ios,
                                  size: 16, color: AppColors.secondaryText),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                );
              },
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  // Build a section with a header and a list of child widgets
  Widget _buildSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.only(
        top: 16,
        bottom: 16,
        left: 16,
        right: 8,
      ),
      decoration: BoxDecoration(
        color: AppColors.secondaryBackground,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 6,
            offset: const Offset(0, 3),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section header with icon
          Row(
            children: [
              Icon(icon, color: AppColors.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.manrope(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryText,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Display child widgets inside section
          ...children,
        ],
      ),
    );
  }

  // Build a key-value row
  Widget _kv(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(label,
                style: GoogleFonts.manrope(
                  fontSize: 14,
                  color: AppColors.secondaryText,
                )),
          ),
          Expanded(
            flex: 5,
            child: Text(value,
                style: GoogleFonts.manrope(
                  fontSize: 14,
                  color: AppColors.primaryText,
                )),
          ),
        ],
      ),
    );
  }

  // Build a bullet list item
  Widget _bullet(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('• ',
              style: GoogleFonts.manrope(
                fontSize: 18,
              )),
          Expanded(
            child: Text(text,
                style: GoogleFonts.manrope(
                  fontSize: 14,
                  color: AppColors.primaryText,
                )),
          ),
        ],
      ),
    );
  }
}
