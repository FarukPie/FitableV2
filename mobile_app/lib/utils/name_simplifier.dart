class NameSimplifier {
  static String simplify(String fullName) {
    if (fullName.isEmpty) return "";

    final lowerName = fullName.toLowerCase();
    String? category;
    String? style;

    // 1. Identify Category
    if (lowerName.contains("tişört") || lowerName.contains("t-shirt") || lowerName.contains("tshirt")) {
      category = "Tişört";
    } else if (lowerName.contains("kazak")) {
      category = "Kazak";
    } else if (lowerName.contains("pantolon")) {
      category = "Pantolon";
    } else if (lowerName.contains("gömlek")) {
      category = "Gömlek";
    } else if (lowerName.contains("mont")) {
      category = "Mont";
    } else if (lowerName.contains("ceket")) {
      category = "Ceket";
    } else if (lowerName.contains("sweatshirt") || lowerName.contains("hoodie") || lowerName.contains("sweat")) {
      category = "Sweatshirt";
    } else if (lowerName.contains("şort") || lowerName.contains("short")) {
      category = "Şort";
    } else if (lowerName.contains("ayakkabı") || lowerName.contains("sneaker")) {
      category = "Ayakkabı";
    } else if (lowerName.contains("elbise")) {
      category = "Elbise";
    } else if (lowerName.contains("etek")) {
      category = "Etek";
    }

    // 2. Identify Style / Attribute
    // Neck types
    if (lowerName.contains("bisiklet yaka")) {
      style = "Bisiklet Yaka";
    } else if (lowerName.contains("v yaka")) {
      style = "V Yaka";
    } else if (lowerName.contains("polo yaka")) {
      style = "Polo Yaka";
    } else if (lowerName.contains("boğazlı") || lowerName.contains("yarım boğazlı")) {
      style = "Boğazlı";
    } else if (lowerName.contains("kapüşonlu") || lowerName.contains("kapşonlu")) {
      style = "Kapüşonlu";
    } 
    // Fabrics / Types
    else if (lowerName.contains("kot") || lowerName.contains("jean") || lowerName.contains("denim")) {
      style = "Kot";
    } else if (lowerName.contains("kumaş")) {
      style = "Kumaş";
    } else if (lowerName.contains("keten")) {
      style = "Keten";
    } else if (lowerName.contains("deri")) {
      style = "Deri";
    } else if (lowerName.contains("kadife")) {
      style = "Kadife";
    } else if (lowerName.contains("triko")) {
      style = "Triko";
    } else if (lowerName.contains("şişme")) {
      style = "Şişme";
    }

    // fallback for style: check fit?
    if (style == null) {
       if (lowerName.contains("oversize")) style = "Oversize";
       else if (lowerName.contains("slim fit")) style = "Slim Fit";
       else if (lowerName.contains("regular")) style = "Regular";
    }

    // Combine
    if (category != null) {
      if (style != null) {
        return "$style $category";
      }
      return category;
    }

    // If no category matched, return original (or truncated?)
    // User wants "sadece adını", so maybe try to find the last meaningful word?
    // But original is better than nothing if we fail.
    return fullName; 
  }
}
