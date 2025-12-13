import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../models/user_measurement.dart';
import '../providers/app_provider.dart';

class MeasureFormScreen extends StatefulWidget {
  const MeasureFormScreen({super.key});

  @override
  State<MeasureFormScreen> createState() => _MeasureFormScreenState();
}

class _MeasureFormScreenState extends State<MeasureFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();
  final _chestController = TextEditingController();
  final _waistController = TextEditingController();
  final _hipsController = TextEditingController();
  String _gender = 'male';

  // Animation State
  double _buttonScale = 1.0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadMeasurements();
    });
  }

  Future<void> _loadMeasurements() async {
    final measurements = await Provider.of<AppProvider>(context, listen: false).fetchMeasurements();
    if (measurements != null) {
      setState(() {
        _heightController.text = measurements.height.toString();
        _weightController.text = measurements.weight.toString();
        _chestController.text = measurements.chest.toString();
        _waistController.text = measurements.waist.toString();
        _hipsController.text = measurements.hips.toString();
        _gender = measurements.gender;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("My Measurements")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildSectionTitle("Personal Details"),
              const SizedBox(height: 12),
              Card(
                elevation: 4,
                shadowColor: Colors.black26,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                color: const Color(0xFF1E1E1E),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      _buildGenderSelector(),
                      const Divider(height: 30, color: Colors.grey),
                      Row(
                        children: [
                          Expanded(child: _buildInput("Height (cm)", _heightController)),
                          const SizedBox(width: 16),
                          Expanded(child: _buildInput("Weight (kg)", _weightController)),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              _buildSectionTitle("Body Measurements"),
              const SizedBox(height: 12),
              Card(
                 elevation: 4,
                shadowColor: Colors.black26,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                color: const Color(0xFF1E1E1E),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                       _buildInput("Chest (cm)", _chestController),
                       const SizedBox(height: 16),
                       _buildInput("Waist (cm)", _waistController),
                       const SizedBox(height: 16),
                       _buildInput("Hips (cm)", _hipsController),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 40),
              GestureDetector(
                onTapDown: (_) => setState(() => _buttonScale = 0.95),
                onTapUp: (_) => setState(() => _buttonScale = 1.0),
                onTapCancel: () => setState(() => _buttonScale = 1.0),
                child: AnimatedScale(
                  scale: _buttonScale,
                  duration: const Duration(milliseconds: 100),
                  child: ElevatedButton(
                    onPressed: _submit,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      backgroundColor: Theme.of(context).primaryColor,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                      elevation: 8,
                      shadowColor: Theme.of(context).primaryColor.withOpacity(0.5),
                    ),
                    child: const Text(
                      "Update Profile",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: Colors.white70,
        fontSize: 14,
        fontWeight: FontWeight.w600,
        letterSpacing: 1.2,
      ),
    );
  }

  Widget _buildInput(String label, TextEditingController controller) {
    return TextFormField(
      controller: controller,
      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.grey[400]),
        filled: true,
        fillColor: const Color(0xFF2C2C2C),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      keyboardType: TextInputType.number,
      validator: (value) =>
          value == null || value.isEmpty ? "Required" : null,
    );
  }

  Widget _buildGenderSelector() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildGenderOption('Male', 'male', Icons.man),
        _buildGenderOption('Female', 'female', Icons.woman),
      ],
    );
  }

  Widget _buildGenderOption(String label, String value, IconData icon) {
    final isSelected = _gender == value;
    final color = isSelected ? Theme.of(context).primaryColor : Colors.grey[600];
    
    return GestureDetector(
      onTap: () {
        setState(() => _gender = value);
        HapticFeedback.selectionClick();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? color!.withOpacity(0.2) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color!, width: isSelected ? 2 : 1),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _submit() {
    HapticFeedback.lightImpact();
    if (_formKey.currentState!.validate()) {
      final measurements = UserMeasurement(
        height: double.parse(_heightController.text),
        weight: double.parse(_weightController.text),
        chest: double.parse(_chestController.text),
        waist: double.parse(_waistController.text),
        hips: double.parse(_hipsController.text),
        gender: _gender,
      );

      Provider.of<AppProvider>(context, listen: false)
          .saveMeasurements(measurements)
          .then((_) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Measurements Saved!")));
        Navigator.pop(context);
      });
    }
  }
}
