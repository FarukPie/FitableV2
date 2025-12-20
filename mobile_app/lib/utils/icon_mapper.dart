import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class IconMapper {
  static IconData getIconForProduct(String productName) {
    final name = productName.toLowerCase();

    // Tops / T-shirts
    if (name.contains('t-shirt') || 
        name.contains('tişört') || 
        name.contains('tisort') || 
        name.contains('bluz') || 
        name.contains('top') ||
        name.contains('atlet')) {
      return PhosphorIcons.tShirt(); 
    }

    // Sweaters / Hoodies
    // User requested "uzun kollu bir sweat" (long sleeve sweat)
    if (name.contains('kazak') || 
        name.contains('sweater') || 
        name.contains('hoodie') || 
        name.contains('sweatshirt') ||
        name.contains('hırka') ||
        name.contains('cardigan')) {
      return PhosphorIcons.hoodie(); 
    }

    // Shirts (Button down)
    if (name.contains('gömlek') || name.contains('shirt')) {
      // Phosphor doesn't have a specific "button down" other than tShirt/hoodie/coat. 
      // Reuse tShirt or coat? 
      // Actually 'shirtFolded' might exist in some packs but let's try 'coat' for collared look, or 'user'..
      // Wait, 'PhosphorIcons.shirt' is T-shirt. 
      // Let's use 'PhosphorIcons.coat' for shirts/jackets often? 
      // Or maybe 'PhosphorIcons.briefcase'? No.
      // 'coat' doesn't exist. Using 'coatHanger' as it represents outerwear storage/category.
      // Alternatively, could use 'hoodie' again, but 'coatHanger' is distinct.
      // Or 'user' wearing something? 
      // Let's go with coatHanger.
      return PhosphorIcons.coatHanger();
    }

    // Outerwear
    if (name.contains('ceket') || 
        name.contains('jacket') || 
        name.contains('mont') || 
        name.contains('coat') ||
        name.contains('kaban') ||
        name.contains('palto')) {
      return PhosphorIcons.coatHanger();
    }

    // Bottoms / Pants
    if (name.contains('pantolon') || 
        name.contains('pants') || 
        name.contains('jeans') || 
        name.contains('kot') || 
        name.contains('trousers') ||
        name.contains('eşofman') ||
        name.contains('jogger')) {
      return PhosphorIcons.pants();
    }
    
    // Shorts
    if (name.contains('şort') || name.contains('short')) {
        // Fallback to pants if shorts not explicitly available in Phosphor < 2. 
        // Phosphor 2 usually has it? If not, pants.
        // Let's try PhosphorIcons.pants as a safe bet first.
        return PhosphorIcons.pants(); 
    }

    // Dresses - Phosphor often has 'dress'
    if (name.contains('elbise') || name.contains('dress') || name.contains('etek') || name.contains('skirt')) {
      return PhosphorIcons.dress();
    }

    // Shoes
    if (name.contains('ayakkabı') || 
        name.contains('shoe') || 
        name.contains('sneaker') || 
        name.contains('bot') || 
        name.contains('boot') ||
        name.contains('terlik') ||
        name.contains('sandal')) {
      return PhosphorIcons.sneaker();
    }

    // Accessories
    if (name.contains('çanta') || name.contains('bag')) {
      return PhosphorIcons.bag(); // or shoppingBag
    }
    if (name.contains('şapka') || name.contains('hat') || name.contains('bere')) {
      return PhosphorIcons.baseballCap(); // or smiley
    }
    
    // Underwear
    if (name.contains('külot') || name.contains('boxer') || name.contains('underwear') || name.contains('iç çamaşır')) {
         // Fallback 
         return PhosphorIcons.heart(); 
    }

    // Default
    return PhosphorIcons.bag(); 
  }
}
