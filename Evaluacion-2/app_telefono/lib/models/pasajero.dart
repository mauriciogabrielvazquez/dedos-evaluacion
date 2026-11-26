class Pasajero {
  final int? id;
  final String nombre;
  final int edad;
  final String tipo; 
  final String correo;

  Pasajero({
    this.id,
    required this.nombre,
    required this.edad,
    required this.tipo,
    required this.correo,
  });

  // Convierte el objeto a un Map para SQLite
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nombre': nombre,
      'edad': edad,
      'tipo': tipo,
      'correo': correo,
    };
  }

  // Crea un objeto desde un Map de SQLite
  factory Pasajero.fromMap(Map<String, dynamic> map) {
    return Pasajero(
      id: map['id'],
      nombre: map['nombre'],
      edad: map['edad'],
      tipo: map['tipo'],
      correo: map['correo'],
    );
  }
}