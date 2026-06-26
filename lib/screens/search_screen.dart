import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/weather_provider.dart';
import 'detail_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _controller = TextEditingController();

  void _search() async {
    final city = _controller.text.trim();
    if (city.isEmpty) return;

    final provider = Provider.of<WeatherProvider>(context, listen: false);
    await provider.fetchWeather(city);

    if (!mounted) return;

    if (provider.error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.error!),
          backgroundColor: Colors.red,
        ),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => DetailScreen(city: city),
        ),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Buscar Ciudades'),
        centerTitle: true,
      ),
      // resizeToAvoidBottomInset evita el overflow con el teclado
      resizeToAvoidBottomInset: true,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        child: Column(
          children: [
            const SizedBox(height: 20),

            const Icon(Icons.travel_explore, size: 80, color: Colors.blue),

            const SizedBox(height: 24),

            const Text(
              'Escribe el nombre de cualquier ciudad del mundo',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),

            const SizedBox(height: 32),

            TextField(
              controller: _controller,
              onSubmitted: (_) => _search(),
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                hintText: 'Ej: Tokyo, Paris, Queretaro...',
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () => _controller.clear(),
                ),
              ),
            ),

            const SizedBox(height: 16),

            Consumer<WeatherProvider>(
              builder: (context, provider, _) {
                if (provider.isLoading) {
                  return const Padding(
                    padding: EdgeInsets.all(16),
                    child: CircularProgressIndicator(),
                  );
                }
                return SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.search),
                    label: const Text('Buscar'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.all(16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: _search,
                  ),
                );
              },
            ),

            const SizedBox(height: 32),

            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Ciudades sugeridas:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),

            const SizedBox(height: 12),

            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                'Queretaro', 'Ciudad de Mexico', 'Guadalajara',
                'Monterrey', 'Cancun', 'Merida', 'Tokyo', 'Paris', 'New York'
              ].map((city) => ActionChip(
                label: Text(city),
                onPressed: () {
                  _controller.text = city;
                  _search();
                },
              )).toList(),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}