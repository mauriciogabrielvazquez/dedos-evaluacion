import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class WeatherWidget extends StatefulWidget {
  final double lat;
  final double lon;

  const WeatherWidget({Key? key, required this.lat, required this.lon}) : super(key: key);

  @override
  _WeatherWidgetState createState() => _WeatherWidgetState();
}

class _WeatherWidgetState extends State<WeatherWidget> {
  String temperatura = "";
  bool isLoading = true;
  bool isError = false;

  @override
  void initState() {
    super.initState();
    _obtenerClima();
  }

  Future<void> _obtenerClima() async {
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
      setState(() {
        isError = true;
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Column(
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 8),
          Text('Consultando clima...'),
        ],
      );
    }

    if (isError) {
      return const Text(
        'No fue posible obtener el clima.',
        style: TextStyle(color: Colors.red),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.thermostat, color: Colors.orange),
            const SizedBox(width: 8),
            Text('Clima actual: $temperatura', style: const TextStyle(fontSize: 18)),
          ],
        ),
      ),
    );
  }
}