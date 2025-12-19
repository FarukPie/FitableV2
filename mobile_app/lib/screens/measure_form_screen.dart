import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
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
  
  // Body Shape (Read Only)
  String? _currentBodyShape;

  // Animation State
  double _buttonScale = 1.0;
  bool _showFullForm = false; // Changed from _areBasicDetailsValid

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

  void _onContinuePressed() {
    final height = _heightController.text.trim();
    final weight = _weightController.text.trim();
    if (height.isNotEmpty && weight.isNotEmpty) {
      setState(() {
        _showFullForm = true;
      });
    } else {
       ScaffoldMessenger.of(context).showSnackBar(
         SnackBar(content: Text(AppLocalizations.of(context)!.requiredError)), 
       );
    }
  }

  @override
  void initState() {
    super.initState();
    _heightController.addListener(_calculateHandSpan);
    // Removed auto-check listeners
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!widget.isInitialSetup) {
        _loadMeasurements();
      } else {
        _showInstructionPopup();
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
        // _footLengthController.text = measurements.footLength.toString(); // Removed UI
        _currentBodyShape = measurements.bodyShape;
        
        // Show full form if data exists
        _showFullForm = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !widget.isInitialSetup,
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          title: Text(
            AppLocalizations.of(context)!.myMeasurementsTitle,
            style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).appBarTheme.titleTextStyle?.color),
          ),
          centerTitle: true,
          backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
          elevation: 0,
          foregroundColor: Theme.of(context).appBarTheme.iconTheme?.color,
          automaticallyImplyLeading: !widget.isInitialSetup,
          actions: [
            IconButton(
              icon: Icon(
                Provider.of<AppProvider>(context).themeMode == ThemeMode.dark ? Icons.light_mode : Icons.dark_mode,
                color: Theme.of(context).appBarTheme.iconTheme?.color,
              ),
              onPressed: () {
                Provider.of<AppProvider>(context, listen: false).toggleTheme();
              },
            ),
          ],
        ),
        body: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 800),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (!widget.isInitialSetup) ...[
                        Consumer<AppProvider>(
                            builder: (context, provider, _) { 
                                final fullName = provider.user?.fullName;
                                final username = provider.user?.username;
                                final emailName = provider.user?.email.split('@')[0] ?? "Kullanıcı";
                                
                                // Priority: Full Name > Username > Email Name > "Kullanıcı"
                                final displayName = (fullName != null && fullName.isNotEmpty) 
                                    ? fullName 
                                    : (username != null && username.isNotEmpty 
                                        ? username 
                                        : emailName);
                                    
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 32.0, top: 8.0),
                                  child: Column(
                                    children: [
                                       Container(
                                          padding: const EdgeInsets.all(4),
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            border: Border.all(color: Theme.of(context).primaryColor, width: 2),
                                          ),
                                           child: CircleAvatar(
                                            radius: 40,
                                            backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
                                            child: Builder(
                                              builder: (context) {
                                                final rawGender = provider.user?.gender;
                                                // debugPrint("Avatar Debug: Raw Gender: $rawGender");
                                                
                                                final gender = rawGender?.toLowerCase() ?? 'male';
                                                IconData iconData;
                                                Color iconColor;

                                                if (gender.contains('erkek') || gender.contains('male')) {
                                                  iconData = Icons.man;
                                                  iconColor = Colors.blue;
                                                } else if (gender.contains('kadın') || gender.contains('kadin') || gender.contains('female') || gender.contains('woman')) {
                                                  iconData = Icons.woman;
                                                  iconColor = Colors.pink;
                                                } else {
                                                  iconData = Icons.transgender;
                                                  iconColor = Colors.purple;
                                                }

                                                return Icon(
                                                  iconData,
                                                  size: 50,
                                                  color: iconColor,
                                                );
                                              },
                                            ),
                                          ),
                                        ),
                                       const SizedBox(height: 16),
                                       Text(
                                          "Merhaba, $displayName",
                                          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Theme.of(context).textTheme.bodyLarge?.color),
                                       ),
                                       if (provider.user?.email != null)
                                          Padding(
                                            padding: const EdgeInsets.only(top: 4.0),
                                            child: Text(
                                              provider.user!.email,
                                              style: TextStyle(fontSize: 14, color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.6)),
                                            ),
                                          ),
                                    ],
                                  ),
                                );
                            }
                        ),
                    ],
                    if (widget.isInitialSetup) ...[
                      Text(
                        AppLocalizations.of(context)!.measureWelcome,
                        style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color, fontSize: 16),
                        textAlign: TextAlign.center,
                      ),
                    ],
                    const SizedBox(height: 16),
                    
                    if (_currentBodyShape != null) ...[
                      _buildSectionTitle(AppLocalizations.of(context)!.bodyShapeTitle),
                      const SizedBox(height: 12),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardTheme.color,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Theme.of(context).primaryColor.withOpacity(0.3)),
                          boxShadow: [
                            BoxShadow(
                              color: Theme.of(context).cardTheme.shadowColor ?? Colors.black26,
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            )
                          ]
                        ),
                        child: Row(
                          children: [
                             Container(
                               padding: const EdgeInsets.all(12),
                               decoration: BoxDecoration(
                                 color: Theme.of(context).primaryColor.withOpacity(0.1),
                                 shape: BoxShape.circle,
                               ),
                               child: Icon(_getShapeIcon(_currentBodyShape!), color: Theme.of(context).primaryColor, size: 32),
                             ),
                             const SizedBox(width: 16),
                             Column(
                               crossAxisAlignment: CrossAxisAlignment.start,
                               children: [
                                 Text(_getShapeLabel(_currentBodyShape!), style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color, fontWeight: FontWeight.bold, fontSize: 18)),
                                 const SizedBox(height: 4),
                                 Text(AppLocalizations.of(context)!.autoCalculated, style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7), fontSize: 13)),
                               ],
                             )
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],

                    _buildSectionTitle(AppLocalizations.of(context)!.personalDetails),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardTheme.color,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [BoxShadow(color: Theme.of(context).cardTheme.shadowColor ?? Colors.black26, blurRadius: 10)],
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(child: _buildInput(AppLocalizations.of(context)!.heightLabel, _heightController, icon: Icons.height)),
                              const SizedBox(width: 16),
                              Expanded(child: _buildInput(AppLocalizations.of(context)!.weightLabel, _weightController, icon: Icons.monitor_weight_outlined)),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    
                    // Show "Continue" button only if full form is hidden
                     if (!_showFullForm)
                      Center(
                        child: ElevatedButton(
                           onPressed: _onContinuePressed,
                           style: ElevatedButton.styleFrom(
                             backgroundColor: Theme.of(context).primaryColor,
                             foregroundColor: Colors.white,
                             shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                             padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                           ),
                           child: const Text("Continue", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        )
                      ),

                    AnimatedCrossFade(
                      firstChild: const SizedBox.shrink(),
                      secondChild: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _buildSectionTitle(AppLocalizations.of(context)!.bodyMeasurements),
                          const SizedBox(height: 12),
                          
                          // --- Hand Span Toggle Section ---
                          Container(
                             decoration: BoxDecoration(
                               color: _isHandSpanMode ? Theme.of(context).primaryColor.withOpacity(0.15) : Theme.of(context).cardTheme.color,
                               borderRadius: BorderRadius.circular(16),
                               border: Border.all(color: _isHandSpanMode ? Theme.of(context).primaryColor : Colors.transparent),
                             ),
                             child: SwitchListTile(
                               title: Text(AppLocalizations.of(context)!.handSpanMode, style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).textTheme.bodyLarge?.color)),
                               subtitle: Text(
                                   _estimatedHandSpan > 0 
                                     ? AppLocalizations.of(context)!.handSpanInfo(_estimatedHandSpan.toStringAsFixed(1))
                                     : AppLocalizations.of(context)!.enterHeightFirst,
                                   style: TextStyle(color: _estimatedHandSpan > 0 ? Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7) : Colors.grey)
                               ),
                               value: _isHandSpanMode,
                               onChanged: _estimatedHandSpan > 0 
                                 ? (val) {
                                     if (val) {
                                       showDialog(
                                         context: context,
                                         builder: (context) => AlertDialog(
                                           backgroundColor: Theme.of(context).cardTheme.color,
                                            title: Row(
                                              children: [
                                                Icon(Icons.info_outline, color: Theme.of(context).primaryColor),
                                                const SizedBox(width: 10),
                                                Text("Bilgilendirme", style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color)),
                                              ],
                                            ),
                                           content: Text(
                                             "Karış hesabı yöntemiyle tahmini ölçümlerinizi girebilirsiniz. \n\nDetaylı bilgi için lütfen ilgili kutucukların yanındaki bilgi (i) butonlarını kullanın.",
                                             style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color),
                                           ),
                                           actions: [
                                             TextButton(
                                               onPressed: () {
                                                 Navigator.pop(context);
                                                 setState(() => _isHandSpanMode = true);
                                               },
                                               child: Text("Anladım", style: TextStyle(color: Theme.of(context).primaryColor)),
                                             )
                                           ],
                                         ),
                                       );
                                     } else {
                                       setState(() => _isHandSpanMode = false);
                                     }
                                 }
                                 : null,
                               activeColor: Theme.of(context).primaryColor,
                               contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                               secondary: Icon(Icons.handshake_outlined, color: _isHandSpanMode ? Theme.of(context).primaryColor : Colors.grey),
                             ),
                          ),
                          const SizedBox(height: 16),

                          Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: Theme.of(context).cardTheme.color,
                              borderRadius: BorderRadius.circular(24),
                              boxShadow: [BoxShadow(color: Theme.of(context).cardTheme.shadowColor ?? Colors.black26, blurRadius: 10)],
                            ),
                            child: Column(
                              children: [
                               _buildDynamicInput(AppLocalizations.of(context)!.shoulderLabel, _shoulderController,
                                   guideTitle: AppLocalizations.of(context)!.howToMeasureTitle,
                                   guideText: AppLocalizations.of(context)!.shoulderMeasureGuide),
                               const SizedBox(height: 16),
                               _buildDynamicInput(AppLocalizations.of(context)!.chestLabel, _chestController,
                                  guideTitle: AppLocalizations.of(context)!.howToMeasureTitle,
                                  guideText: Provider.of<AppProvider>(context).user?.gender == 'female' 
                                    ? AppLocalizations.of(context)!.chestMeasureGuideFemale 
                                    : AppLocalizations.of(context)!.chestMeasureGuideMale),
                               const SizedBox(height: 16),
                               _buildDynamicInput(AppLocalizations.of(context)!.waistLabel, _waistController,
                                   guideTitle: AppLocalizations.of(context)!.howToMeasureTitle,
                                   guideText: AppLocalizations.of(context)!.waistMeasureGuide),
                               const SizedBox(height: 16),
                               _buildDynamicInput(AppLocalizations.of(context)!.legLengthLabel, _legLengthController,
                                   guideTitle: AppLocalizations.of(context)!.howToMeasureTitle,
                                   guideText: AppLocalizations.of(context)!.legLengthMeasureGuide),
                               // Foot length removed as per request
                              ],
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
                              child: SizedBox(
                                height: 60,
                                child: ElevatedButton(
                                  onPressed: _submit,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Theme.of(context).primaryColor,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                                    elevation: 8,
                                    shadowColor: Theme.of(context).primaryColor.withOpacity(0.5),
                                  ),
                                  child: _isLoading 
                                   ? const CircularProgressIndicator(color: Colors.white)
                                   : Text(
                                    widget.isInitialSetup ? AppLocalizations.of(context)!.completeSetup : AppLocalizations.of(context)!.updateProfile,
                                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 1.0),
                                  ),
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                      crossFadeState: _showFullForm ? CrossFadeState.showSecond : CrossFadeState.showFirst,
                      duration: const Duration(milliseconds: 500),
                    ),
                    
                    if (_showFullForm && !widget.isInitialSetup) ...[
                      const SizedBox(height: 32),
                      const Divider(color: Colors.grey),
                      const SizedBox(height: 16),
                      
                      // Logout Button
                      _buildLogoutButton(),
                      
                      const SizedBox(height: 16),
                      
                      // Delete Account Button
                      Container(
                        width: double.infinity,
                        height: 55,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          gradient: LinearGradient(
                            colors: [
                              Colors.red.shade900.withOpacity(0.8),
                              Colors.red.shade600,
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.red.withOpacity(0.3),
                              blurRadius: 12,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: ElevatedButton(
                          onPressed: _showDeleteConfirmation,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.delete_forever_rounded, color: Colors.white),
                              SizedBox(width: 8),
                              Text(
                                "Hesabı Sil",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4.0),
      child: Text(
        title,
        style: TextStyle(
          color: Theme.of(context).textTheme.bodyLarge?.color,
          fontSize: 16,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.0,
        ),
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

       // Switch guide text if in Hand Span Mode
       String? effectiveGuideText = guideText;
       if (_isHandSpanMode) {
          effectiveGuideText = AppLocalizations.of(context)!.handSpanMeasureGuide;
       }
       
       return _buildInput(displayText, controller, suffixOverride: suffix, guideTitle: guideTitle, guideText: effectiveGuideText);

  }

  void _showGuide(String title, String guide) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).dialogTheme.backgroundColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.info_outline, color: Theme.of(context).primaryColor),
            const SizedBox(width: 10),
            Text(title, style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color)),
          ],
        ),
        content: Text(guide, style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7))),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("OK", style: TextStyle(color: Theme.of(context).primaryColor)),
          ),
        ],
      ),
    );
  }

  Widget _buildInput(String label, TextEditingController controller, {String suffixOverride = "cm", String? guideTitle, String? guideText, IconData? icon}) {
    return TextFormField(
      controller: controller,
      style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color, fontWeight: FontWeight.bold),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Theme.of(context).inputDecorationTheme.labelStyle?.color ?? Colors.grey[500]),
        filled: true,
        fillColor: Theme.of(context).inputDecorationTheme.fillColor,
        suffixText: suffixOverride,
        suffixStyle: TextStyle(color: Theme.of(context).inputDecorationTheme.hintStyle?.color ?? Colors.grey[400]),
        prefixIcon: icon != null ? Icon(icon, color: Theme.of(context).primaryColor, size: 20) : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        suffixIcon: guideText != null
            ? IconButton(
                icon: Icon(Icons.help_outline, color: Theme.of(context).primaryColor.withOpacity(0.7)),
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
        footLength: 0.0, // Removed UI, default to 0
        gender: Provider.of<AppProvider>(context, listen: false).user!.gender,

      );

      Provider.of<AppProvider>(context, listen: false)
          .saveMeasurements(measurement)
          .then((_) {
        ScaffoldMessenger.of(context).showSnackBar(
             SnackBar(
               content: Text(AppLocalizations.of(context)!.measurementsSaved),
               backgroundColor: Colors.green,
             ));
        // Always pop to return to the previous screen (Home), 
        // even if it was initial setup (because we push it from Home now)
        if (Navigator.canPop(context)) {
          Navigator.pop(context);
        }
      });
    }
  }

  String _getShapeLabel(String key) {
    // Need context to access localizations, so this method should dependent on it or be inside build if possible.
    // Since it's a helper method in State, we can access context.
    final l10n = AppLocalizations.of(context)!;
    switch (key) {
      case 'inverted_triangle': return l10n.shapeInvertedTriangle;
      case 'triangle': return l10n.shapeTriangle;
      case 'oval': return l10n.shapeOval;
      case 'rectangular': return l10n.shapeRectangular;
      default: return key;
    }
  }

  IconData _getShapeIcon(String key) {
     switch (key) {
      case 'inverted_triangle': return Icons.filter_list_alt;
      case 'triangle': return Icons.change_history;
      case 'oval': return Icons.circle_outlined;
      case 'rectangular': return Icons.crop_portrait;
      default: return Icons.help_outline;
    }
  }

  void _showInstructionPopup() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const _InstructionDialog(),
    );
  }

  Widget _buildLogoutButton() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      width: double.infinity,
      height: 55,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: isDark ? null : Colors.grey.shade300, // Light mode visible background
        gradient: isDark ? LinearGradient(
          colors: [
            Colors.white.withOpacity(0.1),
            Colors.white.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ) : null,
        border: Border.all(color: isDark ? Colors.white.withOpacity(0.2) : Colors.transparent),
      ),
      child: InkWell(
        onTap: () {
           Provider.of<AppProvider>(context, listen: false).logout();
           Navigator.pop(context); 
        },
        borderRadius: BorderRadius.circular(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.logout_rounded, color: isDark ? Colors.white : Colors.black87),
            const SizedBox(width: 8),
            Text(
              "Çıkış Yap",
              style: TextStyle(
                color: isDark ? Colors.white : Colors.black87,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).cardTheme.color,
        title: const Text("Hesabı Sil", style: TextStyle(color: Colors.red)),
        content: const Text(
          "Hesabınızı ve tüm verilerinizi kalıcı olarak silmek istediğinizden emin misiniz? Bu işlem geri alınamaz.",
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("İptal"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              _performDeletion();
            },
            child: const Text("Sil", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Future<void> _performDeletion() async {
    setState(() => _isLoading = true);
    try {
      await Provider.of<AppProvider>(context, listen: false).deleteAccount();
      if (mounted) {
         Navigator.pop(context); // Go back to Home/Login
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Hata: $e"), backgroundColor: Colors.red),
        );
        setState(() => _isLoading = false);
      }
    }
  }
}

class _InstructionDialog extends StatefulWidget {
  const _InstructionDialog();

  @override
  State<_InstructionDialog> createState() => _InstructionDialogState();
}

class _InstructionDialogState extends State<_InstructionDialog> {
  bool _canClose = false;
  int _secondsRemaining = 3;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_secondsRemaining > 0) {
          _secondsRemaining--;
        } else {
          _canClose = true;
          _timer?.cancel();
        }
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: Theme.of(context).cardTheme.color,
        title: Row(
          children: [
            Icon(Icons.info_outline, color: Theme.of(context).primaryColor), // Using accentColor
            SizedBox(width: 10),
            Text("Ölçüm Tavsiyesi", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            RichText(
              text: TextSpan(
                style: const TextStyle(color: Colors.white70, fontSize: 15),
                children: [
                  const TextSpan(text: "Ölçümlerinizi nasıl yapacağınızı öğrenmek için, lütfen ilgili kutucuğun yanındaki "),
                  WidgetSpan(
                    alignment: PlaceholderAlignment.middle,
                    child: Icon(Icons.help_outline, color: Theme.of(context).primaryColor, size: 20),
                  ),
                  const TextSpan(text: " butonuna tıklayınız."),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: _canClose ? () => Navigator.of(context).pop() : null,
            child: Text(
              _canClose ? "Anladım" : "Anladım ($_secondsRemaining)",
              style: TextStyle(
                color: _canClose ? const Color(0xFF2962FF) : Colors.grey,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
