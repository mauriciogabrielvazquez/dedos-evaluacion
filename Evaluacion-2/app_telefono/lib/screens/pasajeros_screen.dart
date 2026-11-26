import 'package:flutter/material.dart';
import '../db/database_helper.dart';
import '../models/pasajero.dart';

class PasajerosScreen extends StatefulWidget {
  const PasajerosScreen({super.key});

  @override
  State<PasajerosScreen> createState() => _PasajerosScreenState();
}

class _PasajerosScreenState extends State<PasajerosScreen> {
  final _nombreController = TextEditingController();
  final _edadController = TextEditingController();
  final _tipoController = TextEditingController();
  final _correoController = TextEditingController(); // CASO 4
  
  List<Pasajero> _listaPasajeros = [];

  // CASO 2: Consultar usuarios
  void _cargarPasajeros() async {
    final datos = await DatabaseHelper.instance.obtenerTodos();
    setState(() {
      _listaPasajeros = datos;
    });
  }

  // CASO 1: Insertar
  void _registrarPasajero() async {
    if (_nombreController.text.isEmpty || _edadController.text.isEmpty) return;

    final nuevoPasajero = Pasajero(
      nombre: _nombreController.text.trim(),
      edad: int.parse(_edadController.text.trim()),
      tipo: _tipoController.text.trim(), // Equivale a profesión
      correo: _correoController.text.trim(), // CASO 4
    );

    await DatabaseHelper.instance.insertPasajero(nuevoPasajero);
    _nombreController.clear();
    _edadController.clear();
    _tipoController.clear();
    _correoController.clear();
    
    _cargarPasajeros(); // Recargar la vista
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Pasajero registrado'), backgroundColor: Colors.green));
  }

  // CASO 3: Actualizar
  void _mostrarDialogoActualizar(Pasajero pasajero) {
    final _nuevoTipoController = TextEditingController(text: pasajero.tipo);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Modificar Tipo de Viajero'),
        content: TextField(
          controller: _nuevoTipoController,
          decoration: const InputDecoration(labelText: 'Nuevo tipo (Ej. VIP, Turista)'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () async {
              await DatabaseHelper.instance.actualizarTipoPasajero(pasajero.id!, _nuevoTipoController.text.trim());
              _cargarPasajeros();
              Navigator.pop(context);
            },
            child: const Text('Guardar'),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Formulario de Inserción
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextField(controller: _nombreController, decoration: const InputDecoration(labelText: 'Nombre del Pasajero')),
              TextField(controller: _edadController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Edad (Ej. 25)')),
              TextField(controller: _tipoController, decoration: const InputDecoration(labelText: 'Tipo de viajero (Frecuente, Turista)')),
              TextField(controller: _correoController, decoration: const InputDecoration(labelText: 'Correo Electrónico')), // CASO 4
              const SizedBox(height: 15),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFBC02D)),
                    onPressed: _registrarPasajero,
                    child: const Text('Registrar', style: TextStyle(color: Colors.black)),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1565C0)),
                    onPressed: _cargarPasajeros, // Método de consulta explícito
                    child: const Text('VER usuarios', style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            ],
          ),
        ),
        const Divider(),
        // Lista de Resultados
        Expanded(
          child: ListView.builder(
            itemCount: _listaPasajeros.length,
            itemBuilder: (context, index) {
              final p = _listaPasajeros[index];
              return ListTile(
                leading: CircleAvatar(backgroundColor: const Color(0xFF1565C0), child: Text(p.edad.toString(), style: const TextStyle(color: Colors.white))),
                title: Text(p.nombre, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text('Tipo: ${p.tipo}\nCorreo: ${p.correo}'),
                isThreeLine: true,
                trailing: IconButton(
                  icon: const Icon(Icons.edit, color: Colors.orange),
                  onPressed: () => _mostrarDialogoActualizar(p), // Detona Caso 3
                ),
              );
            },
          ),
        )
      ],
    );
  }
}