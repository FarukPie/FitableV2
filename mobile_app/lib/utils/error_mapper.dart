import 'package:flutter/material.dart';
import 'package:size_recommendation_app/l10n/app_localizations.dart';

class ErrorMapper {
  static String getErrorMessage(String error, BuildContext context) {
    if (context == null) return error; // Should not happen but safety check
    
    final l10n = AppLocalizations.of(context);
    if (l10n == null) return error;

    // Normalize error string
    final lowerError = error.toLowerCase();

    // Network Errors
    if (lowerError.contains('connection caused') || 
        lowerError.contains('clientexception') || 
        lowerError.contains('socketexception') ||
        lowerError.contains('connection aborted')) {
      return l10n.errorNetwork;
    }

    // Auth Errors
    if (lowerError.contains('login failed')) return l10n.errorLoginGeneric;
    if (lowerError.contains('registration failed')) return l10n.errorRegisterGeneric;
    if (lowerError.contains('failed to delete account')) return l10n.errorAccountDelete;
    if (lowerError.contains('invalid username or password') || 
        lowerError.contains('invalid_credentials')) {
      return l10n.invalidCredentials;
    }

    // Data Errors
    if (lowerError.contains('failed to load history')) return l10n.errorHistoryLoad;
    if (lowerError.contains('failed to load measurements')) return l10n.errorMeasurementsLoad;
    if (lowerError.contains('failed to update measurements')) return l10n.errorUpdateMeasurements;
    if (lowerError.contains('failed to add to closet')) return l10n.errorAddToCloset;
    if (lowerError.contains('failed to remove')) return l10n.errorRemoveFromCloset;

    // Fallback
    // If we can't map it, and the user insisted on Turkish, we can prefix it or just return a generic error.
    // Access Denied / Bot Protection
    if (lowerError.contains('access denied') || 
        lowerError.contains('site erişimi') || 
        lowerError.contains('bot koruması') ||
        lowerError.contains('sunucu hatası') ||
        lowerError.contains('internal server error')) {
      // Return the clean error message without 'Exception: ' prefix if possible, 
      // or just return the localized/specific string.
      return error.replaceAll("Exception: ", ""); 
    }

    if (lowerError.contains('exception: ')) {
      return l10n.errorUnknown; 
    }
    
    return error;
  }
}
