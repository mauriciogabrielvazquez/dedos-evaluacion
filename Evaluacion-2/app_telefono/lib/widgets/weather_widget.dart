import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class WeatherWidget extends StatefulWidget {
  final double lat;
  final double lon;

  const WeatherWidget({super.key, required this.lat, required this.lon});

  @override
  State<WeatherWidget> createState() => _WeatherWidgetState();
}

class _WeatherWidgetState extends State<WeatherWidget> {
  String temperatura = "";
  bool isLoading = false;
  bool isError = false;
  bool isInitial = true; // Controla si aún no se ha hecho la primera consulta

  Future<void> _obtenerClima() async {
    setState(() {
      isInitial = false;
      isLoading = true;
      isError = false;
    });

    // RF03: URL preasignada (Apunta a Open-Meteo usando las coordenadas recibidas)
    final url = Uri.parse(
        'https://api.open-meteo.com/v1/forecast?latitude=${widget.lat}&longitude=${widget.lon}&current_weather=true');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          temperatura = "${data['current_weather']['temperature']} °C";
          isLoading = false;
        });
      } else {
        setState(() {
          isError = true;
          isLoading = false;
        });
      }
    } catch (e) {
      // Entra aquí si no hay internet o si la URL es incorrecta
      setState(() {
        isError = true;
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: const Color(0xFFF1F5F9), // Fondo sutil que combina con tu paleta
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // RF01: Al iniciar la aplicación deberá mostrar: Consulta de información
            const Text(
              'Consulta de información',
              style: TextStyle(
                fontSize: 16, 
                fontWeight: FontWeight.bold, 
                color: Color(0xFF1565C0) // Azul Agua de tu paleta
              ),
            ),
            const SizedBox(height: 15),

            // RF05: Mientras se realiza la petición deberá mostrarse: Consultando...
            if (isLoading)
              const Row(
                children: [
                  SizedBox(
                    width: 20, 
                    height: 20, 
                    child: CircularProgressIndicator(strokeWidth: 2)
                  ),
                  SizedBox(width: 15),
                  Text('Consultando...', style: TextStyle(fontSize: 14)),
                ],
              ),

            // RF06: Si existe un error de conexión deberá mostrarse: No fue posible obtener la información.
            if (isError) ...[
              const Text(
                'No fue posible obtener la información.',
                style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
            ],

            // RF04: La información obtenida deberá mostrarse en pantalla.
            if (!isInitial && !isLoading && !isError)
              Row(
                children: [
                  const Icon(Icons.thermostat, color: Colors.orange),
                  const SizedBox(width: 8),
                  Text('Clima actual: $temperatura', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                ],
              ),

            // RF02: Deberá existir un botón: CONSULTAR
            if (isInitial || isError)
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1565C0), // Azul Agua
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: _obtenerClima, // RF03: Realiza la petición al presionar
                  child: const Text('CONSULTAR', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
          ],
        ),
      ),
    );
  }
}