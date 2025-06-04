import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:fl_vitatraz_app/screens/screens.dart';
import 'package:fl_vitatraz_app/theme/theme.dart';
import 'package:fl_vitatraz_app/components/components.dart';

class HomeScreen extends StatefulWidget {
  static const String routeName = '/home';
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _medicationCount = 25123;
  int _totalPatientsCount = 0;
  int _totalFichasCount = 0;

  String _orderBy = 'fecha';

  @override
  void initState() {
    super.initState();
    _fetchMedicationCountOnce();
    _fetchTotalPatients();
    _fetchTotalFichas();
  }

  // Fetches the total number of medications from the API once
  Future<void> _fetchMedicationCountOnce() async {
    int totalCount = 0;
    int pagina = 1;
    const int pageSize = 200;

    try {
      while (true) {
        final uri = Uri.https(
          'cima.aemps.es',
          '/cima/rest/medicamentos',
          {'pagina': pagina.toString()},
        );
        final response = await http.get(uri);

        if (response.statusCode != 200) {
          debugPrint('Error al obtener página $pagina: ${response.statusCode}');
          break;
        }

        final jsonMap = jsonDecode(response.body) as Map<String, dynamic>;
        final List<dynamic> resultados = jsonMap['resultados'] as List<dynamic>;

        totalCount += resultados.length;

        if (resultados.length < pageSize) break;

        pagina++;
      }
    } catch (e) {
      debugPrint('Error al obtener medicamentos: $e');
    }

    if (mounted) {
      setState(() {
        _medicationCount = totalCount;
      });
    }
  }

  // Fetches total number of patients in the database
  Future<void> _fetchTotalPatients() async {
    try {
      final snapshot = await FirebaseFirestore.instance.collection('pacientes').get();
      if (mounted) {
        setState(() {
          _totalPatientsCount = snapshot.docs.length;
        });
      }
    } catch (e) {
      debugPrint('Error al obtener pacientes: $e');
    }
  }

  // Fetches total number of medical records using collectionGroup
  Future<void> _fetchTotalFichas() async {
    try {
      final snapshot = await FirebaseFirestore.instance.collectionGroup('fichas').get();
      if (mounted) {
        setState(() {
          _totalFichasCount = snapshot.docs.length;
        });
      }
    } catch (e) {
      debugPrint('Error al obtener fichas médicas: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final email = user?.email ?? '';

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: AppColors.primary,
      bottomNavigationBar: const AppBottomNavBar(currentIndex: 0),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // --------------------------------
            // HEADER SECTION
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('VitaTraz', style: Theme.of(context).textTheme.headlineMedium),
                ],
              ),
            ),
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: AppColors.primaryBackground,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(25),
                    topRight: Radius.circular(25),
                  ),
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.only(top: 20, bottom: 20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // --------------------------------
                      // UPPER CARDS SECTION
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                // --------------------------------
                                // MEDICATIONS CARD
                                Expanded(
                                  child: WidgetCard(
                                    title: 'Medicamentos',
                                    subtitle: _medicationCount == 25123
                                        ? '$_medicationCount disponibles'
                                        : '$_medicationCount disponibles',
                                    icon: Icons.medication,
                                    onTap: () {
                                      Navigator.pushNamed(
                                        context,
                                        MedicationsScreen.routeName,
                                      );
                                    },
                                  ),
                                ),
                                const SizedBox(width: 10),
                                // --------------------------------
                                // RECORDS CARD
                                Expanded(
                                  child: WidgetCard(
                                    title: 'Fichas médicas',
                                    subtitle: '$_totalFichasCount registradas',
                                    icon: Icons.folder_shared,
                                    onTap: () {
                                      Navigator.pushNamed(
                                        context,
                                        RecordsScreen.routeName,
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            // --------------------------------
                            // PATIENTS CARD
                            SizedBox(
                              width: double.infinity,
                              child: WidgetCard(
                                title: 'Pacientes',
                                subtitle: '$_totalPatientsCount registrados',
                                icon: Icons.people,
                                onTap: () {
                                  Navigator.pushNamed(
                                    context,
                                    PatientsScreen.routeName,
                                  );
                                },
                              ),
                            ),
                            const SizedBox(height: 20),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // --------------------------------
                      // TO DO LIST SECTION HEADER
                      TodoListHeader(
                        onAdd: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const AddTodoScreen(),
                            ),
                          );
                        },
                      ),
                      
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 8),
                        child: Row(
                          children: [
                            Text(
                              'Ordenar por:',
                              style: GoogleFonts.manrope(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: AppColors.secondaryText,
                              ),
                            ),
                            const SizedBox(width: 8),

                            // Hacemos que ocupe solo el espacio mínimo
                            // quitamos el boxShadow y reducimos padding
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.secondaryBackground,
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: AppColors.lineColor.withOpacity(0.5),
                                  width: 1,
                                ),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  value: _orderBy,
                                  // al quitar isExpanded, el dropdown se ajusta al contenido
                                  // (es más estrecho)
                                  isDense: true, // para que el espacio vertical sea menor
                                  dropdownColor: AppColors.primaryBackground,
                                  icon: Icon(
                                    Icons.arrow_drop_down,
                                    color: AppColors.primary,
                                    size: 20,
                                  ),
                                  style: GoogleFonts.manrope(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.primaryText,
                                  ),
                                  underline: const SizedBox(),
                                  items: const [
                                    DropdownMenuItem(value: 'fecha', child: Text('Fecha')),
                                    DropdownMenuItem(value: 'prioridad', child: Text('Prioridad')),
                                  ],
                                  onChanged: (value) {
                                    if (value != null) {
                                      setState(() {
                                        _orderBy = value;
                                      });
                                    }
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // TO-DO list (filtered in Flutter)
                      email.isNotEmpty
                          ? buildTodoList(email)
                          : const Text('No se ha iniciado sesión'),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --------------------------------
  // TO DO LIST METHOD
  Widget buildTodoList(String enfermeroEmail) {
        final Stream<QuerySnapshot> todoStream =
        _orderBy == 'prioridad'
            ? FirebaseFirestore.instance
                .collection('enfermeros')
                .doc(enfermeroEmail)
                .collection('TO-DO')
                .orderBy('nivelImportancia', descending: true)
                .snapshots()
            : FirebaseFirestore.instance
                .collection('enfermeros')
                .doc(enfermeroEmail)
                .collection('TO-DO')
                .orderBy('fechaCreacion', descending: true)
                .snapshots();

    return StreamBuilder<QuerySnapshot>(
      stream: todoStream,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Text('Error al cargar los TO-DOs');
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        // filtered in Flutter to show only non-completed tasks
        final todos = snapshot.data!.docs.where((doc) {
          final data = doc.data() as Map<String, dynamic>;
          return data['completada'] != true; // only shows the non-completed ones
        }).toList();

        // if everything is completed or empty, it shows a message
        if (todos.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(24),
            child: Center(
              child: Column(
                children: [
                  Icon(Icons.check_circle_outline, size: 48, color: Colors.green),
                  SizedBox(height: 12),
                  Text(
                    '¡Todo en orden!\nNo hay tareas pendientes 🎉',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        // returns a list with all the cards with the corresponding data
        return Column(
          children: todos.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            final titulo = data['mensaje'] ?? 'Sin título';
            final nivel = data['nivelImportancia'] ?? 1;
            final fecha = (data['fechaCreacion'] as Timestamp?)?.toDate();

            return RecordatorioTile(
              nivelImportancia: nivel,
              title: titulo,
              label: fecha != null
                  ? '${fecha.day}/${fecha.month}/${fecha.year} ${fecha.hour}:${fecha.minute.toString().padLeft(2, '0')}'
                  : 'Sin fecha',
              onComplete: () {
                FirebaseFirestore.instance
                    .collection('enfermeros')
                    .doc(enfermeroEmail)
                    .collection('TO-DO')
                    .doc(doc.id)
                    .update({'completada': true});
              },
            );
          }).toList(),
        );
      },
    );
  }
}
