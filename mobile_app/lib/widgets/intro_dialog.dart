import 'package:flutter/material.dart';
import 'package:size_recommendation_app/l10n/app_localizations.dart';

class IntroDialog extends StatelessWidget {
  const IntroDialog({super.key});

  @override
  Widget build(BuildContext context) {
    // We can hardcode texts or use localization if available. 
    // Since we just added "welcome" key, we might lack specific intro keys.
    // I will use hardcoded Turkish texts for now as per user request context "Hoşgeldiniz",
    // or try to use existing keys if possible. Use hardcoded for the specific explanation requested.
    
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black87;
    final descriptionColor = isDark ? Colors.white70 : Colors.black54;

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: backgroundColor,
      surfaceTintColor: backgroundColor,
      title: Column(
        children: [
          const Icon(Icons.waving_hand_rounded, size: 48, color: Colors.orangeAccent),
          const SizedBox(height: 16),
          Text(
            AppLocalizations.of(context)!.welcome, 
            textAlign: TextAlign.center,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24, color: textColor),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 10),
            _buildFeatureRow(
              context,
              Icons.link_rounded,
              "Ürün Ara",
              "Beğendiğin ürünün linkini yapıştır, sana en uygun bedeni bulalım.",
              textColor,
              descriptionColor,
            ),
            const SizedBox(height: 24),
            _buildFeatureRow(
              context,
              Icons.checkroom_rounded,
              "Sanal Dolap",
              "Daha önce arattığın ve kaydettiğin tüm ürünlere buradan ulaşabilirsin.",
              textColor,
              descriptionColor,
            ),
            const SizedBox(height: 24),
            _buildFeatureRow(
              context,
              Icons.person_rounded,
              "Profil",
              "Vücut ölçülerini veya kişisel bilgilerini buradan güncelleyebilirsin.",
              textColor,
              descriptionColor,
            ),
          ],
        ),
      ),
      actions: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: const Text(
              "Anladım, Başla!",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFeatureRow(BuildContext context, IconData icon, String title, String description, Color titleColor, Color descColor) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: Theme.of(context).primaryColor, size: 28),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: titleColor),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: TextStyle(color: descColor, fontSize: 14, height: 1.4),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
