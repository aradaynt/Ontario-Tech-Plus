import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'ml_service.dart';

class RecommendationPage extends ConsumerStatefulWidget {
  const RecommendationPage({super.key});

  @override
  ConsumerState<RecommendationPage> createState() => _RecommendationPageState();
}

class _RecommendationPageState extends ConsumerState<RecommendationPage> {
  // Initialize our TFLite Service
  final MLService _mlService = MLService();

  // Sliders for Big 5 Traits (0 to 10 scale)
  double _openness = 5.0;
  double _conscientiousness = 5.0;
  double _extraversion = 5.0;
  double _agreeableness = 5.0;
  double _neuroticism = 5.0;

  bool _isLoading = false;
  bool _isModelReady = false;
  String? _recommendedClub;

  @override
  void initState() {
    super.initState();
    _loadModel();
  }

  Future<void> _loadModel() async {
    await _mlService.initialize();
    if (mounted) {
      setState(() {
        _isModelReady = true;
      });
    }
  }

  void _generateRecommendations() {
    if (!_isModelReady) return;

    setState(() => _isLoading = true);

    final userTraits = [_openness, _conscientiousness, _extraversion, _agreeableness, _neuroticism];
    
    // Slight delay for UI feedback
    Future.delayed(const Duration(milliseconds: 600), () {
      final club = _mlService.predictClub(userTraits);

      if (mounted) {
        setState(() {
          _recommendedClub = club;
          _isLoading = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _mlService.dispose(); // Close the TFLite interpreter
    super.dispose();
  }

  Widget _buildTraitSlider(String label, double value, ValueChanged<double> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("$label: ${value.toStringAsFixed(1)}", style: const TextStyle(fontWeight: FontWeight.bold)),
        Slider(
          value: value,
          min: 0.0,
          max: 10.0,
          divisions: 20,
          activeColor: Colors.blueAccent,
          onChanged: onChanged,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("AI Club Matcher"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              "Rate your personality traits (0 - 10). Our trained Neural Network will find the perfect campus club for you!",
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 24),

            _buildTraitSlider("Openness (Creativity/Curiosity)", _openness, (v) => setState(() => _openness = v)),
            _buildTraitSlider("Conscientiousness (Organization)", _conscientiousness, (v) => setState(() => _conscientiousness = v)),
            _buildTraitSlider("Extraversion (Outgoingness)", _extraversion, (v) => setState(() => _extraversion = v)),
            _buildTraitSlider("Agreeableness (Empathy/Cooperation)", _agreeableness, (v) => setState(() => _agreeableness = v)),
            _buildTraitSlider("Neuroticism (Stress/Competitiveness)", _neuroticism, (v) => setState(() => _neuroticism = v)),
            
            const SizedBox(height: 24),

            ElevatedButton(
              onPressed: (_isLoading || !_isModelReady) ? null : _generateRecommendations,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: const Color(0xFF0B2C66),
              ),
              child: _isLoading 
                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) 
                : Text(!_isModelReady ? "Loading AI Model..." : "Find My Club", style: const TextStyle(fontSize: 18, color: Colors.white)),
            ),

            if (_recommendedClub != null) ...[
              const SizedBox(height: 32),
              const Divider(),
              const SizedBox(height: 16),
              const Text("Your AI Match", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
              const SizedBox(height: 16),
              
              Card(
                color: Colors.green.shade50,
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ListTile(
                    leading: const Icon(Icons.groups, color: Colors.green, size: 40),
                    title: const Text("Top Match"),
                    subtitle: Text(_recommendedClub!, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Colors.black87)),
                  ),
                ),
              ),
            ]
          ],
        ),
      ),
    );
  }
}