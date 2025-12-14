import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../models/user_measurement.dart';
import '../providers/app_provider.dart';
import 'package:size_recommendation_app/l10n/app_localizations.dart';

class MeasureFormScreen extends StatefulWidget {
  final bool isInitialSetup;
  const MeasureFormScreen({super.key, this.isInitialSetup = false});

  @override
  State<MeasureFormScreen> createState() => _MeasureFormScreenState();
}

class _MeasureFormScreenState extends State<MeasureFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();
  final _chestController = TextEditingController();
  final _waistController = TextEditingController();
  final _hipsController = TextEditingController(); // Hidden but kept for model compatibility
  final _shoulderController = TextEditingController();
  final _legLengthController = TextEditingController();
  final _footLengthController = TextEditingController();

  // Animation State
  double _buttonScale = 1.0;

  bool _isHandSpanMode = false;
  double _estimatedHandSpan = 0.0;
  bool _isLoading = false;

  void _calculateHandSpan() {
    final height = double.tryParse(_heightController.text);
    if (height != null && height > 0) {
      setState(() {
        _estimatedHandSpan = height * 0.125;
      });
    } else {
       setState(() {
        _estimatedHandSpan = 0.0;
        _isHandSpanMode = false; // Disable if height invalid
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _heightController.addListener(_calculateHandSpan);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!widget.isInitialSetup) {
        _loadMeasurements();
      }
    });
  }

  @override
  void dispose() {
    _heightController.removeListener(_calculateHandSpan);
    _heightController.dispose();
    _weightController.dispose();
    _chestController.dispose();
    _waistController.dispose();
    _hipsController.dispose();
    _shoulderController.dispose();
    _legLengthController.dispose();
    _footLengthController.dispose();
    super.dispose();
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
        _shoulderController.text = measurements.shoulder.toString();
        _legLengthController.text = measurements.legLength.toString();
        _footLengthController.text = measurements.footLength.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !widget.isInitialSetup,
      child: Scaffold(
        appBar: AppBar(
          title: Text(AppLocalizations.of(context)!.myMeasurementsTitle),
          automaticallyImplyLeading: !widget.isInitialSetup,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (widget.isInitialSetup) ...[
                  Text(
                    AppLocalizations.of(context)!.measureWelcome,
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                ],
                _buildSectionTitle(AppLocalizations.of(context)!.personalDetails),
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
                        const Divider(height: 30, color: Colors.grey),
                        Row(
                          children: [
                            Expanded(child: _buildInput(AppLocalizations.of(context)!.heightLabel, _heightController)),
                            const SizedBox(width: 16),
                            Expanded(child: _buildInput(AppLocalizations.of(context)!.weightLabel, _weightController)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                _buildSectionTitle(AppLocalizations.of(context)!.bodyMeasurements),
                const SizedBox(height: 12),
                
                // --- Hand Span Toggle Section ---
                Card(
                   color: _isHandSpanMode ? Theme.of(context).primaryColor.withOpacity(0.15) : const Color(0xFF1E1E1E),
                   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: _isHandSpanMode ? Theme.of(context).primaryColor : Colors.transparent)),
                   child: Column(
                     children: [
                       SwitchListTile(
                         title: Text(AppLocalizations.of(context)!.handSpanMode, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                         subtitle: Text(
                             _estimatedHandSpan > 0 
                               ? AppLocalizations.of(context)!.handSpanInfo(_estimatedHandSpan.toStringAsFixed(1))
                               : AppLocalizations.of(context)!.enterHeightFirst,
                             style: TextStyle(color: _estimatedHandSpan > 0 ? Colors.white70 : Colors.grey)
                         ),
                         value: _isHandSpanMode,
                         onChanged: _estimatedHandSpan > 0 
                           ? (val) => setState(() => _isHandSpanMode = val) 
                           : null,
                         activeColor: Theme.of(context).primaryColor,
                       ),
                     ],
                   ),
                ),
                const SizedBox(height: 16),

                Card(
                   elevation: 4,
                  shadowColor: Colors.black26,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  color: const Color(0xFF1E1E1E),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                       _buildDynamicInput(AppLocalizations.of(context)!.shoulderLabel, _shoulderController,
                           guideTitle: AppLocalizations.of(context)!.howToMeasureTitle,
                           guideText: AppLocalizations.of(context)!.shoulderMeasureGuide),
                       const SizedBox(height: 16),
                       _buildDynamicInput(AppLocalizations.of(context)!.chestLabel, _chestController),
                       const SizedBox(height: 16),
                       _buildDynamicInput(AppLocalizations.of(context)!.waistLabel, _waistController,
                           guideTitle: AppLocalizations.of(context)!.howToMeasureTitle,
                           guideText: AppLocalizations.of(context)!.waistMeasureGuide),
                       const SizedBox(height: 16),
                       _buildDynamicInput(AppLocalizations.of(context)!.legLengthLabel, _legLengthController,
                           guideTitle: AppLocalizations.of(context)!.howToMeasureTitle,
                           guideText: AppLocalizations.of(context)!.legLengthMeasureGuide),
                       const SizedBox(height: 16),
                       _buildDynamicInput(AppLocalizations.of(context)!.footLengthLabel, _footLengthController,
                           guideTitle: AppLocalizations.of(context)!.howToMeasureTitle,
                           guideText: AppLocalizations.of(context)!.footLengthMeasureGuide),
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
                      child: Text(
                        widget.isInitialSetup ? AppLocalizations.of(context)!.completeSetup : AppLocalizations.of(context)!.updateProfile,
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                )
              ],
            ),
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

  // Wrapper for dynamic input based on mode
  Widget _buildDynamicInput(String label, TextEditingController controller, {String? guideTitle, String? guideText}) {
       String displayText = label;
       String suffix = "cm";
       
       if (_isHandSpanMode) {
           displayText = "$label (${AppLocalizations.of(context)!.spansSuffix})";
           suffix = AppLocalizations.of(context)!.spansSuffix;
       }
       
       return _buildInput(displayText, controller, suffixOverride: suffix, guideTitle: guideTitle, guideText: guideText);   
  }

  void _showGuide(String title, String guide) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2C2C2C),
        title: Row(
          children: [
            Icon(Icons.info_outline, color: Theme.of(context).primaryColor),
            const SizedBox(width: 10),
            Text(title, style: const TextStyle(color: Colors.white)),
          ],
        ),
        content: Text(guide, style: const TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  Widget _buildInput(String label, TextEditingController controller, {String suffixOverride = "cm", String? guideTitle, String? guideText}) {
    return TextFormField(
      controller: controller,
      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.grey[400]),
        filled: true,
        fillColor: const Color(0xFF2C2C2C),
        suffixText: suffixOverride,
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
        suffixIcon: guideText != null
            ? IconButton(
                icon: Icon(Icons.info_outline, color: Theme.of(context).primaryColor),
                onPressed: () => _showGuide(guideTitle!, guideText),
              )
            : null,
      ),
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      validator: (value) =>
          value == null || value.isEmpty ? AppLocalizations.of(context)!.requiredError : null,
    );
  }



  // Helper to convert span to cm
  double _convertVal(String text) {
      if (text.isEmpty) return 0.0;
      double val = double.tryParse(text) ?? 0.0;
      if (_isHandSpanMode && _estimatedHandSpan > 0) {
          return val * _estimatedHandSpan;
      }
      return val;
  }

  void _submit() {
    HapticFeedback.lightImpact();
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      
      final measurement = UserMeasurement(
        height: double.parse(_heightController.text),
        weight: double.parse(_weightController.text),
        shoulder: _convertVal(_shoulderController.text),
        chest: _convertVal(_chestController.text),
        waist: _convertVal(_waistController.text),
        hips: _hipsController.text.isNotEmpty ? double.parse(_hipsController.text) : 0.0,
        legLength: _convertVal(_legLengthController.text),
        footLength: _convertVal(_footLengthController.text),
        gender: Provider.of<AppProvider>(context, listen: false).user!.gender,
      );

      Provider.of<AppProvider>(context, listen: false)
          .saveMeasurements(measurement)
          .then((_) {
        ScaffoldMessenger.of(context).showSnackBar(
             SnackBar(content: Text(AppLocalizations.of(context)!.measurementsSaved)));
        if (!widget.isInitialSetup) {
          Navigator.pop(context);
        }
      });
    }
  }
}
