// test/main/registration_data_test.dart
import 'package:flutter_test/flutter_test.dart';
import '../../lib/main/registration_data.dart';

void main() {
  group('RegistrationData Tests', () {
    group('Phone Number Integration', () {
      test('cleanedPhoneNumber uses PhoneNumberUtils correctly', () {
        final regData = RegistrationData(phoneNumber: '+639171234567');
        expect(regData.cleanedPhoneNumber, '639171234567');

        final regData2 = RegistrationData(phoneNumber: '09171234567');
        expect(regData2.cleanedPhoneNumber, '639171234567');

        final regData3 = RegistrationData(phoneNumber: '9171234567');
        expect(regData3.cleanedPhoneNumber, '639171234567');
      });

      test('cleanedPhoneNumber handles invalid numbers gracefully', () {
        final regData = RegistrationData(phoneNumber: 'invalid');
        expect(regData.cleanedPhoneNumber, null);

        final regData2 = RegistrationData(phoneNumber: null);
        expect(regData2.cleanedPhoneNumber, null);
      });
    });

    group('Role Mapping', () {
      test('role maps userType correctly', () {
        final plhivUser = RegistrationData(userType: 'PLHIV');
        expect(plhivUser.role, 'plhiv');

        final infoSeeker = RegistrationData(
          userType: 'Health Information Seeker',
        );
        expect(infoSeeker.role, 'infoSeeker');

        final defaultUser = RegistrationData(userType: null);
        expect(defaultUser.role, 'infoSeeker');

        final unknownUser = RegistrationData(userType: 'Unknown');
        expect(unknownUser.role, 'infoSeeker');
      });
    });

    group('Age Range Computation', () {
      test('computeAgeRange calculates correctly', () {
        final now = DateTime.now();

        // Youth (20 years old)
        final youthUser = RegistrationData(
          birthDate: DateTime(now.year - 20, now.month, now.day),
        );
        youthUser.computeAgeRange();
        expect(youthUser.ageRange, '18-24');
        expect(youthUser.isYouth, true);

        // Adult (30 years old)
        final adultUser = RegistrationData(
          birthDate: DateTime(now.year - 30, now.month, now.day),
        );
        adultUser.computeAgeRange();
        expect(adultUser.ageRange, '25-34');
        expect(adultUser.isYouth, false);

        // Senior (50 years old)
        final seniorUser = RegistrationData(
          birthDate: DateTime(now.year - 50, now.month, now.day),
        );
        seniorUser.computeAgeRange();
        expect(seniorUser.ageRange, '45+');

        // Minor (15 years old)
        final minorUser = RegistrationData(
          birthDate: DateTime(now.year - 15, now.month, now.day),
        );
        minorUser.computeAgeRange();
        expect(minorUser.ageRange, 'Under 18');
      });
    });

    group('MSM Detection', () {
      test('isMSM detects correctly', () {
        // MSM case 1: Male + Male
        final msm1 = RegistrationData(
          sexAssignedAtBirth: 'Male',
          unprotectedSexWith: 'Male',
        );
        expect(msm1.isMSM, true);

        // MSM case 2: Male + Both
        final msm2 = RegistrationData(
          sexAssignedAtBirth: 'Male',
          unprotectedSexWith: 'Both',
        );
        expect(msm2.isMSM, true);

        // Not MSM case 1: Male + Female
        final notMsm1 = RegistrationData(
          sexAssignedAtBirth: 'Male',
          unprotectedSexWith: 'Female',
        );
        expect(notMsm1.isMSM, false);

        // Not MSM case 2: Female + Male
        final notMsm2 = RegistrationData(
          sexAssignedAtBirth: 'Female',
          unprotectedSexWith: 'Male',
        );
        expect(notMsm2.isMSM, false);
      });
    });

    group('Firestore Data Structure', () {
      test('toFirestore creates flattened structure', () {
        final regData = RegistrationData(
          phoneNumber: '+639171234567',
          userType: 'PLHIV',
          sexAssignedAtBirth: 'Male',
          genderIdentity: 'Male',
          city: 'Davao City',
          barangay: 'Poblacion',
          unprotectedSexWith: 'Male',
          yearDiagnosed: 2020,
          treatmentHub: 'Davao Medical Center',
          birthDate: DateTime(1995, 1, 1),
        );

        final firestoreData = regData.toFirestore();

        // Check core fields are at root level
        expect(firestoreData['phoneNumber'], '+639171234567');
        expect(firestoreData['cleanedPhone'], '639171234567');
        expect(firestoreData['role'], 'plhiv');
        expect(firestoreData['sexAssignedAtBirth'], 'Male');
        expect(firestoreData['city'], 'Davao City');
        expect(firestoreData['barangay'], 'Poblacion');

        // Check computed fields
        expect(firestoreData['isMSM'], true);
        expect(firestoreData['ageRange'], isNotNull);

        // Check PLHIV-specific fields
        expect(firestoreData['yearDiagnosed'], 2020);
        expect(firestoreData['treatmentHub'], 'Davao Medical Center');
        expect(firestoreData['verifiedPLHIV'], false); // No confirmatory code

        // Ensure no nested objects
        expect(firestoreData.containsKey('demographics'), false);
        expect(firestoreData.containsKey('location'), false);
        expect(firestoreData.containsKey('uicData'), false);
      });

      test('toFirestore throws error for invalid phone', () {
        final regData = RegistrationData(
          phoneNumber: 'invalid',
          userType: 'PLHIV',
        );

        expect(() => regData.toFirestore(), throwsArgumentError);
      });

      test('toFirestore handles Info Seeker without PLHIV fields', () {
        final regData = RegistrationData(
          phoneNumber: '+639171234567',
          userType: 'Health Information Seeker',
          sexAssignedAtBirth: 'Female',
          city: 'Davao City',
        );

        final firestoreData = regData.toFirestore();

        expect(firestoreData['role'], 'infoSeeker');
        expect(firestoreData.containsKey('yearDiagnosed'), false);
        expect(firestoreData.containsKey('treatmentHub'), false);
        expect(firestoreData.containsKey('verifiedPLHIV'), false);
      });
    });

    group('JSON Serialization', () {
      test('toJson/fromJson maintains data integrity', () {
        final original = RegistrationData(
          phoneNumber: '+639171234567',
          userType: 'PLHIV',
          sexAssignedAtBirth: 'Male',
          genderIdentity: 'Male',
          nationality: 'Filipino',
          city: 'Davao City',
          yearDiagnosed: 2020,
          birthDate: DateTime(1995, 1, 1),
        );

        final json = original.toJson();
        final restored = RegistrationData.fromJson(json);

        expect(restored.phoneNumber, original.phoneNumber);
        expect(restored.userType, original.userType);
        expect(restored.sexAssignedAtBirth, original.sexAssignedAtBirth);
        expect(restored.city, original.city);
        expect(restored.yearDiagnosed, original.yearDiagnosed);
        expect(restored.birthDate, original.birthDate);
      });
    });

    group('Data Validation', () {
      test('validates required fields for PLHIV', () {
        final plhivUser = RegistrationData(
          phoneNumber: '+639171234567',
          userType: 'PLHIV',
          city: 'Davao City',
          // Missing yearDiagnosed - should be handled in validation
        );

        final firestoreData = plhivUser.toFirestore();
        expect(firestoreData['role'], 'plhiv');
        expect(firestoreData['yearDiagnosed'], null);
      });
    });
  });
}
