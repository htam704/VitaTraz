import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import 'package:fl_vitatraz_app/theme/app_colors.dart';
import 'package:fl_vitatraz_app/components/components.dart'; 
import 'package:fl_vitatraz_app/screens/principals/patients_screen.dart';
import 'package:fl_vitatraz_app/screens/principals/medications_screen.dart';

class CreateRecordScreen extends StatefulWidget {
  static const String routeName = '/createRecord';
  const CreateRecordScreen({super.key});

  @override
  State<CreateRecordScreen> createState() => _CreateRecordScreenState();
}

class _CreateRecordScreenState extends State<CreateRecordScreen> {
  final _dateController = TextEditingController();
  final _timeController = TextEditingController();
  final _reasonController = TextEditingController();
  final _diagnosisController = TextEditingController();
  final _notesController = TextEditingController();

  Map<String, dynamic>? _selectedPatient;

  final List<Map<String, String>> _medications = [];

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _dateController.text = DateFormat('dd/MM/yyyy').format(now);
    _timeController.text = DateFormat('HH:mm').format(now);
  }

  @override
  void dispose() {
    _dateController.dispose();
    _timeController.dispose();
    _reasonController.dispose();
    _diagnosisController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _selectPatient() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) {
          return PatientsScreen(
            onPatientSelected: (p) {
              setState(() {
                _selectedPatient = p;
              });
            },
          );
        },
      ),
    );
  }

  Future<void> _selectMedication() async {
    final med = await Navigator.push<Map<String, String>>(
      context,
      MaterialPageRoute(
        builder: (_) => MedicationsScreen(
          onMedicationSelected: (_) {},
        ),
      ),
    );

    if (med != null) {
      setState(() {
        _medications.add(med);
      });
    }
  }

  DateTime? _parseDateTimeFromFields() {
    try {
      final dateParts = _dateController.text.split('/');
      if (dateParts.length != 3) return null;
      final day = int.parse(dateParts[0]);
      final month = int.parse(dateParts[1]);
      final year = int.parse(dateParts[2]);

      final timeParts = _timeController.text.split(':');
      if (timeParts.length != 2) return null;
      final hour = int.parse(timeParts[0]);
      final minute = int.parse(timeParts[1]);

      return DateTime(year, month, day, hour, minute);
    } catch (_) {
      return null;
    }
  }

  Future<void> _saveRecord() async {
    if (_selectedPatient == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecciona un paciente primero')),
      );
      return;
    }

    final ingresoDateTime = _parseDateTimeFromFields();
    if (ingresoDateTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('La fecha o la hora no tienen formato válido')),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final dniPaciente = _selectedPatient!['dni'] as String;
      final pacienteRef = FirebaseFirestore.instance
          .collection('pacientes')
          .doc(dniPaciente);

      final Map<String, dynamic> fichaData = {
        'fechaIngreso': Timestamp.fromDate(ingresoDateTime),
        'motivoIngreso': _reasonController.text.trim(),
        'diagnosticoPrincipal': _diagnosisController.text.trim(),
        'anotacion': _notesController.text.trim(),
        'medicamentos': _medications.map((m) {
          return {
            'name': m['name']!,
            'schedule': m['schedule']!,
            'route': m['route'] ?? '',
            'lastDose': m['lastDose'] ?? '',
          };
        }).toList(),
      };

      await pacienteRef.collection('fichas').add(fichaData);

      Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error guardando la ficha: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        leading: const BackButton(color: AppColors.secondaryBackground),
        title: Text(
          'Crear Ficha Clínica',
          style: GoogleFonts.manrope(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.secondaryBackground,
          ),
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Column(
              children: [
                ElevatedButton.icon(
                  icon: const Icon(Icons.person_search),
                  label: Text(
                    _selectedPatient == null
                        ? 'Seleccionar paciente'
                        : 'Cambiar paciente',
                  ),
                  onPressed: _isSaving ? null : _selectPatient,
                ),
                if (_selectedPatient != null) ...[
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: PatientCard(
                      name: _selectedPatient!['nombre'] as String,
                      dni: _selectedPatient!['dni'] as String,
                      birthdate: _formatBirthdate(_selectedPatient!['fechaNacimiento']),
                      allergies: (_selectedPatient!['alergias'] is List)
                          ? List<String>.from(_selectedPatient!['alergias'] as List)
                          : (_selectedPatient!['alergias'] as String)
                              .split(',')
                              .map((s) => s.trim())
                              .toList(),
                      backgroundColor: AppColors.secondaryBackground,
                      borderColor: (_selectedPatient!['sexo'] as String)
                          .toLowerCase()
                          .contains('f')
                      ? AppColors.lightCoral
                      : AppColors.persianGreen,
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
                Section(
                  title: 'Datos de Ingreso',
                  icon: Icons.calendar_today_outlined,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _buildInputField(
                            controller: _dateController,
                            hintText: 'DD/MM/YYYY',
                            onTap: _isSaving ? null : _pickDate,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildInputField(
                            controller: _timeController,
                            hintText: 'HH:mm',
                            onTap: _isSaving ? null : _pickTime,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildInputField(
                      controller: _reasonController,
                      hintText: 'Motivo de ingreso',
                      maxLines: 2,
                      onTap: null,
                    ),
                    const SizedBox(height: 12),
                    _buildInputField(
                      controller: _diagnosisController,
                      hintText: 'Diagnóstico principal',
                      onTap: null,
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                Section(
                  title: 'Medicamentos Suministrados',
                  icon: Icons.local_hospital_outlined,
                  action: IconButton(
                    icon: const Icon(Icons.add, color: AppColors.primary),
                    onPressed: _isSaving ? null : _selectMedication,
                  ),
                  children: [
                    for (var med in _medications) _buildMedRow(med),
                    if (_medications.isEmpty)
                      Text(
                        'No se han añadido medicamentos.',
                        style: GoogleFonts.manrope(
                          fontSize: 14,
                          color: AppColors.secondaryText,
                        ),
                      ),
                  ],
                ),

                const SizedBox(height: 24),

                Section(
                  title: 'Anotaciones',
                  icon: Icons.note_alt_outlined,
                  children: [
                    _buildInputField(
                      controller: _notesController,
                      hintText: 'Escribe aquí tus anotaciones...',
                      maxLines: 4,
                      onTap: null,
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      minimumSize: const Size.fromHeight(48),
                    ),
                    onPressed: _isSaving ? null : _saveRecord,
                    child: Text(
                      'Guardar Ficha',
                      style: GoogleFonts.manrope(
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 16),
              ],
            ),
          ),

          if (_isSaving)
            Container(
              color: Colors.black26,
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String hintText,
    int maxLines = 1,
    VoidCallback? onTap,
  }) {
    return TextField(
      controller: controller,
      readOnly: onTap != null, 
      maxLines: maxLines,
      onTap: onTap,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: GoogleFonts.manrope(color: AppColors.secondaryText),
        filled: true,
        fillColor: AppColors.secondaryBackground,
        contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
      style: GoogleFonts.manrope(color: AppColors.primaryText),
    );
  }

  Widget _buildMedRow(Map<String, String> med) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              '${med['name']} — ${med['schedule']}',
              style: GoogleFonts.manrope(
                fontSize: 14,
                color: AppColors.primaryText,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            color: AppColors.error,
            onPressed: _isSaving
                ? null
                : () {
                    setState(() => _medications.remove(med));
                  },
          ),
        ],
      ),
    );
  }

  Future<void> _pickDate() async {
    final today = DateTime.now();
    final d = await showDatePicker(
      context: context,
      initialDate: today,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (d != null) {
      _dateController.text = DateFormat('dd/MM/yyyy').format(d);
    }
  }

  Future<void> _pickTime() async {
    final now = TimeOfDay.now();
    final t = await showTimePicker(context: context, initialTime: now);
    if (t != null) {
      _timeController.text = t.format(context);
    }
  }

  String _formatBirthdate(dynamic rawFecha) {
    if (rawFecha is String) {
      return rawFecha;
    }
    if (rawFecha is Timestamp) {
      final dt = rawFecha.toDate();
      return DateFormat('dd/MM/yyyy').format(dt);
    }
    if (rawFecha is DateTime) {
      return DateFormat('dd/MM/yyyy').format(rawFecha);
    }
    return '';
  }
}
