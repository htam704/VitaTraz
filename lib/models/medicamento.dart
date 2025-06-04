class Medicamento {
  final String nregistro;
  final String nombre;
  final String labtitular;
  final String cpresc;
  final String receta;
  final String dosis;
  final String? principioActivo; 
  final List<String> fotos;

  Medicamento({
    required this.nregistro,
    required this.nombre,
    required this.labtitular,
    required this.cpresc,
    required this.receta,
    required this.dosis,
    this.principioActivo,
    required this.fotos,
  });

  factory Medicamento.fromJson(Map<String, dynamic> json) {
    List<String> listaFotos = [];
    if (json['fotos'] is List) {
      for (final f in json['fotos'] as List<dynamic>) {
        final url = (f['url'] ?? '').toString();
        if (url.isNotEmpty) listaFotos.add(url);
      }
    }
    return Medicamento(
      nregistro: json['nregistro'] as String,
      nombre: json['nombre'] as String,
      labtitular: json['labtitular'] as String,
      cpresc: json['cpresc'] as String,
      receta: json['receta'].toString(),
      dosis: json['dosis'] as String,
      principioActivo: json['vtm'] != null ? json['vtm']['nombre'] as String? : null,
      fotos: listaFotos,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nregistro': nregistro,
      'nombre': nombre,
      'labtitular': labtitular,
      'cpresc': cpresc,
      'receta': receta,
      'dosis': dosis,
      'principioActivo': principioActivo,
    };
  }
}
