import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const WeatherApp());
}

class WeatherApp extends StatelessWidget {
  const WeatherApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Simple Weather',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const WeatherHome(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class WeatherHome extends StatefulWidget {
  const WeatherHome({super.key});
  @override
  State<WeatherHome> createState() => _WeatherHomeState();
}

class _WeatherHomeState extends State<WeatherHome> {
  final TextEditingController _controller = TextEditingController();
  bool _loading = false;
  String? _error;
  Map<String, dynamic>? _weather;

  // TODO: replace with your OpenWeatherMap API key
  static const String _apiKey = 'c3ce8a9dca2eebc2832e2427e9777778';

  Future<void> fetchWeather(String city) async {
    setState(() {
      _loading = true;
      _error = null;
      _weather = null;
    });

    try {
      final uri = Uri.https('api.openweathermap.org', '/data/2.5/weather', {
        'q': city,
        'appid': _apiKey,
        'units': 'metric',
      });

      final res = await http.get(uri);
      if (res.statusCode != 200) {
        final body = jsonDecode(res.body);
        setState(() {
          _error = body['message'] ?? 'Error: ${res.statusCode}';
          _loading = false;
        });
        return;
      }

      final data = jsonDecode(res.body) as Map<String, dynamic>;
      setState(() {
        _weather = data;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Network error: $e';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final main = _weather?['main'];
    final temp = main != null ? (main['temp']?.toString() ?? '') : '';
    final description =
        (_weather?['weather'] != null && _weather!['weather'].isNotEmpty)
            ? _weather!['weather'][0]['description']
            : '';
    final iconCode =
        (_weather?['weather'] != null && _weather!['weather'].isNotEmpty)
            ? _weather!['weather'][0]['icon']
            : null;
    final iconUrl = iconCode != null
        ? 'https://openweathermap.org/img/wn/$iconCode@2x.png'
        : null;

    return Scaffold(
      appBar: AppBar(title: const Text('Simple Weather')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(children: [
          TextField(
            controller: _controller,
            decoration: const InputDecoration(
              labelText: 'City name',
              hintText: 'e.g. London',
              border: OutlineInputBorder(),
            ),
            onSubmitted: (v) => fetchWeather(v.trim()),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.search),
                  label: const Text('Get Weather'),
                  onPressed: _loading
                      ? null
                      : () {
                          final city = _controller.text.trim();
                          if (city.isNotEmpty) fetchWeather(city);
                        },
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          if (_loading) const CircularProgressIndicator(),
          if (_error != null) ...[
            const SizedBox(height: 12),
            Text(_error!, style: const TextStyle(color: Colors.red)),
          ],
          if (_weather != null) ...[
            const SizedBox(height: 16),
            if (iconUrl != null)
              Image.network(iconUrl, width: 100, height: 100),
            const SizedBox(height: 8),
            Text('${temp}°C',
                style:
                    const TextStyle(fontSize: 36, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            Text(description?.toString().toUpperCase() ?? '',
                style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 12),
            Text('Location: ${_weather!['name'] ?? ''}'),
            const SizedBox(height: 8),
            Text('Humidity: ${main?['humidity'] ?? '-'}%'),
            Text('Pressure: ${main?['pressure'] ?? '-'} hPa'),
          ],
        ]),
      ),
    );
  }
}
