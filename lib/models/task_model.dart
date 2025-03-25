class Task {
  final int id;
  final String titulo;
  final String descripcion;
  final bool completada;

  Task({
    required this.id,
    required this.titulo,
    required this.descripcion,
    required this.completada,
  });

  /// Constructor auxiliar para tareas nuevas (sin ID aún)
  factory Task.newTask({
    required String titulo,
    required String descripcion,
    bool completada = false,
  }) {
    return Task(
      id: 0,
      titulo: titulo,
      descripcion: descripcion,
      completada: completada,
    );
  }

  /// Convertir JSON a objeto Task
  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      titulo: json['titulo'],
      descripcion: json['descripcion'],
      completada: json['completada'],
    );
  }

  /// Convertir objeto Task a JSON
  Map<String, dynamic> toJson() {
    final data = {
      'titulo': titulo,
      'descripcion': descripcion,
      'completada': completada,
    };

    // Solo incluir 'id' si es mayor que 0 (para actualizar)
    if (id > 0) {
      data['id'] = id;
    }

    return data;
  }
}
