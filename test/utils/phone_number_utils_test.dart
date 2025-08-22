// test/utils/phone_number_utils_test.dart
import 'package:flutter_test/flutter_test.dart';
import '../../lib/utils/phone_number_utils.dart';

void main() {
  group('PhoneNumberUtils Tests', () {
    group('cleanForDocumentId', () {
      test('handles +639XXXXXXXXX format correctly', () {
        expect(
          PhoneNumberUtils.cleanForDocumentId('+639123456789'),
          '639123456789',
        );
      });

      test('handles 09XXXXXXXXX format correctly', () {
        expect(
          PhoneNumberUtils.cleanForDocumentId('09123456789'),
          '639123456789',
        );
      });

      test('handles 9XXXXXXXXX format correctly', () {
        expect(
          PhoneNumberUtils.cleanForDocumentId('9123456789'),
          '639123456789',
        );
      });

      test('handles 639XXXXXXXXX format correctly', () {
        expect(
          PhoneNumberUtils.cleanForDocumentId('639123456789'),
          '639123456789',
        );
      });

      test('handles phone with spaces and dashes', () {
        expect(
          PhoneNumberUtils.cleanForDocumentId('+63 912 345 6789'),
          '639123456789',
        );
        expect(
          PhoneNumberUtils.cleanForDocumentId('0912-345-6789'),
          '639123456789',
        );
      });

      test('throws error for invalid phone numbers', () {
        expect(
          () => PhoneNumberUtils.cleanForDocumentId('12345'),
          throwsArgumentError,
        );
        expect(
          () => PhoneNumberUtils.cleanForDocumentId(''),
          throwsArgumentError,
        );
        expect(
          () => PhoneNumberUtils.cleanForDocumentId(null),
          throwsArgumentError,
        );
      });
    });

    group('formatForDisplay', () {
      test('formats phone number for display', () {
        expect(
          PhoneNumberUtils.formatForDisplay('639123456789'),
          '+63 9 123 456 789',
        );
        expect(
          PhoneNumberUtils.formatForDisplay('+639123456789'),
          '+63 9 123 456 789',
        );
        expect(
          PhoneNumberUtils.formatForDisplay('09123456789'),
          '+63 9 123 456 789',
        );
      });
    });

    group('formatForAuth', () {
      test('formats phone number for Firebase Auth', () {
        expect(PhoneNumberUtils.formatForAuth('639123456789'), '+639123456789');
        expect(PhoneNumberUtils.formatForAuth('09123456789'), '+639123456789');
      });
    });

    group('isValidPhilippineMobile', () {
      test('validates correct Philippine mobile numbers', () {
        // Common Globe prefixes
        expect(PhoneNumberUtils.isValidPhilippineMobile('639171234567'), true);
        expect(PhoneNumberUtils.isValidPhilippineMobile('639051234567'), true);

        // Common Smart prefixes
        expect(PhoneNumberUtils.isValidPhilippineMobile('639181234567'), true);
        expect(PhoneNumberUtils.isValidPhilippineMobile('639281234567'), true);

        // Different input formats
        expect(PhoneNumberUtils.isValidPhilippineMobile('+639171234567'), true);
        expect(PhoneNumberUtils.isValidPhilippineMobile('09171234567'), true);
        expect(PhoneNumberUtils.isValidPhilippineMobile('9171234567'), true);
      });

      test('rejects invalid Philippine mobile numbers', () {
        // Invalid country code
        expect(
          PhoneNumberUtils.isValidPhilippineMobile('6491712345678'),
          false,
        );

        // Invalid mobile prefix (landline)
        expect(
          PhoneNumberUtils.isValidPhilippineMobile('6328212345678'),
          false,
        );

        // Too short/long
        expect(PhoneNumberUtils.isValidPhilippineMobile('639171234'), false);
        expect(
          PhoneNumberUtils.isValidPhilippineMobile('63917123456789'),
          false,
        );

        // Invalid format
        expect(PhoneNumberUtils.isValidPhilippineMobile('abc123456789'), false);
        expect(PhoneNumberUtils.isValidPhilippineMobile(''), false);
        expect(PhoneNumberUtils.isValidPhilippineMobile(null), false);
      });
    });

    group('areEqual', () {
      test('compares phone numbers correctly regardless of format', () {
        expect(PhoneNumberUtils.areEqual('+639123456789', '09123456789'), true);
        expect(PhoneNumberUtils.areEqual('639123456789', '9123456789'), true);
        expect(
          PhoneNumberUtils.areEqual('+639123456789', '+639123456789'),
          true,
        );
        expect(
          PhoneNumberUtils.areEqual('+639123456789', '+639876543210'),
          false,
        );
      });
    });

    group('getAllPossibleFormats', () {
      test('returns all possible formats for database queries', () {
        final formats = PhoneNumberUtils.getAllPossibleFormats('09123456789');
        expect(formats.contains('639123456789'), true);
        expect(formats.contains('+639123456789'), true);
        expect(formats.contains('09123456789'), true);
        expect(formats.length, greaterThanOrEqualTo(3));
      });
    });
  });
}
