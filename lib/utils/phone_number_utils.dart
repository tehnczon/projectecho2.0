// lib/utils/phone_number_utils.dart

class PhoneNumberUtils {
  // Philippines country code
  static const String PH_COUNTRY_CODE = '63';
  static const String PH_MOBILE_PREFIX = '9';

  /// Cleans and standardizes phone number for Firestore document ID
  /// Returns format: 639XXXXXXXXX (always 12 digits)
  static String cleanForDocumentId(String? phoneNumber) {
    if (phoneNumber == null || phoneNumber.isEmpty) {
      throw ArgumentError('Phone number cannot be null or empty');
    }

    // Remove all non-digit characters
    String cleaned = phoneNumber.replaceAll(RegExp(r'[^\d]'), '');

    // Handle different input formats
    if (cleaned.startsWith('639') && cleaned.length == 12) {
      // Already in correct format: 639XXXXXXXXX
      return cleaned;
    } else if (cleaned.startsWith('63') && cleaned.length == 11) {
      // Format: 63XXXXXXXXX -> add '9'
      return '63$PH_MOBILE_PREFIX${cleaned.substring(2)}';
    } else if (cleaned.startsWith('09') && cleaned.length == 11) {
      // Format: 09XXXXXXXXX -> replace 0 with 639
      return '$PH_COUNTRY_CODE$PH_MOBILE_PREFIX${cleaned.substring(2)}';
    } else if (cleaned.startsWith('9') && cleaned.length == 10) {
      // Format: 9XXXXXXXXX -> add 63
      return '$PH_COUNTRY_CODE$cleaned';
    } else if (cleaned.length == 10 && !cleaned.startsWith('9')) {
      // Format: XXXXXXXXXX -> add 639
      return '$PH_COUNTRY_CODE$PH_MOBILE_PREFIX$cleaned';
    }

    // If none of the above, throw error
    throw ArgumentError('Invalid Philippine phone number format: $phoneNumber');
  }

  /// Formats phone number for display
  /// Returns format: +639 XXX XXX XXXX
  static String formatForDisplay(String? phoneNumber) {
    if (phoneNumber == null || phoneNumber.isEmpty) return '';

    try {
      String cleaned = cleanForDocumentId(phoneNumber);
      // Format: 639XXXXXXXXX -> +639 XXX XXX XXXX
      return '+${cleaned.substring(0, 2)} ${cleaned.substring(2, 3)} ${cleaned.substring(3, 6)} ${cleaned.substring(6, 9)} ${cleaned.substring(9)}';
    } catch (e) {
      return phoneNumber; // Return original if formatting fails
    }
  }

  /// Formats phone number for Firebase Auth
  /// Returns format: +639XXXXXXXXX
  static String formatForAuth(String? phoneNumber) {
    if (phoneNumber == null || phoneNumber.isEmpty) return '';

    try {
      String cleaned = cleanForDocumentId(phoneNumber);
      return '+$cleaned';
    } catch (e) {
      return phoneNumber.startsWith('+') ? phoneNumber : '+$phoneNumber';
    }
  }

  /// Validates if phone number is a valid Philippine mobile number
  static bool isValidPhilippineMobile(String? phoneNumber) {
    if (phoneNumber == null || phoneNumber.isEmpty) return false;

    try {
      String cleaned = cleanForDocumentId(phoneNumber);

      // Must be 12 digits, start with 639, and have valid mobile prefix
      if (cleaned.length != 12 || !cleaned.startsWith('639')) {
        return false;
      }

      // Valid mobile prefixes in Philippines (after 639)
      List<String> validPrefixes = [
        '905',
        '906',
        '915',
        '916',
        '917',
        '918',
        '919',
        '920',
        '921',
        '922',
        '923',
        '924',
        '925',
        '926',
        '927',
        '928',
        '929',
        '930',
        '931',
        '932',
        '933',
        '934',
        '935',
        '936',
        '937',
        '938',
        '939',
        '940',
        '941',
        '942',
        '943',
        '944',
        '945',
        '946',
        '947',
        '948',
        '949',
        '950',
        '951',
        '952',
        '953',
        '954',
        '955',
        '956',
        '957',
        '958',
        '959',
        '960',
        '961',
        '962',
        '963',
        '964',
        '965',
        '966',
        '967',
        '968',
        '969',
        '970',
        '971',
        '972',
        '973',
        '974',
        '975',
        '976',
        '977',
        '978',
        '979',
        '980',
        '981',
        '982',
        '983',
        '984',
        '985',
        '986',
        '987',
        '988',
        '989',
        '990',
        '991',
        '992',
        '993',
        '994',
        '995',
        '996',
        '997',
        '998',
        '999',
      ];

      String prefix = cleaned.substring(2, 5);
      return validPrefixes.contains(prefix);
    } catch (e) {
      return false;
    }
  }

  /// Gets all possible phone number formats for database queries
  /// Useful when searching across different stored formats
  static List<String> getAllPossibleFormats(String? phoneNumber) {
    if (phoneNumber == null || phoneNumber.isEmpty) return [];

    try {
      String standard = cleanForDocumentId(phoneNumber);
      String withPlus = formatForAuth(phoneNumber);
      String original = phoneNumber;

      // Remove duplicates and return list
      Set<String> formats = {standard, withPlus, original};
      return formats.toList();
    } catch (e) {
      return [phoneNumber];
    }
  }

  /// Compares two phone numbers regardless of format
  static bool areEqual(String? phone1, String? phone2) {
    if (phone1 == phone2) return true;
    if (phone1 == null || phone2 == null) return false;

    try {
      return cleanForDocumentId(phone1) == cleanForDocumentId(phone2);
    } catch (e) {
      return false;
    }
  }
}
