import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MedicationProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String medicationTime = '';
  int currentInventory = 0;
  int threshold = 0;
  String treatmentHub = '';
  String generatedUIC = '';
  bool isLoading = false;
  bool isSetupComplete = false; // NEW: Track if initial setup is done

  // Calendar tracking
  DateTime? lastTakenDate;
  int consecutiveMissedDays = 0;
  List<DateTime> takenDates = [];
  DateTime? inventoryRunsOutDate;

  // Check if user has completed initial setup
  Future<bool> checkSetupStatus() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return false;

      final medDoc =
          await _firestore.collection('medicalTracker').doc(user.uid).get();
      isSetupComplete = medDoc.exists;

      return isSetupComplete;
    } catch (e) {
      print('Error checking setup status: $e');
      return false;
    }
  }

  // Load user's medication data including UIC and treatment hub from profiles
  Future<void> loadMedicationData() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      isLoading = true;
      notifyListeners();

      // Load UIC and treatment hub from profiles
      final profileDoc =
          await _firestore.collection('profiles').doc(user.uid).get();

      if (profileDoc.exists) {
        final profileData = profileDoc.data()!;
        generatedUIC = profileData['generatedUIC'] ?? '';

        // Get treatment hub from roleData/plhiv subcollection
        final roleDataDoc =
            await _firestore
                .collection('profiles')
                .doc(user.uid)
                .collection('roleData')
                .doc('plhiv')
                .get();

        if (roleDataDoc.exists) {
          treatmentHub = roleDataDoc.data()?['treatmentHub'] ?? '';
        }
      }

      // Load medication settings from medicalTracker
      final medDoc =
          await _firestore.collection('medicalTracker').doc(user.uid).get();

      if (medDoc.exists) {
        isSetupComplete = true;
        final data = medDoc.data()!;
        medicationTime = data['medicationTime'] ?? '';
        currentInventory = data['currentInventory'] ?? 0;
        threshold = data['threshold'] ?? 0;

        // Load last taken date
        if (data['lastTakenDate'] != null) {
          lastTakenDate = (data['lastTakenDate'] as Timestamp).toDate();
        }

        consecutiveMissedDays = data['consecutiveMissedDays'] ?? 0;

        // Load taken dates history (last 90 days)
        await _loadTakenDatesHistory(user.uid);

        // Calculate when inventory runs out
        _calculateInventoryRunsOut();
      } else {
        isSetupComplete = false;
        print('⚠️ No medicalTracker document found - setup required');
      }

      isLoading = false;
      notifyListeners();
    } catch (e) {
      print('Error loading medication data: $e');
      isLoading = false;
      notifyListeners();
    }
  }

  // Load medication intake history
  Future<void> _loadTakenDatesHistory(String uid) async {
    try {
      final now = DateTime.now();
      final ninetyDaysAgo = now.subtract(Duration(days: 90));

      final logs =
          await _firestore
              .collection('medicalTracker')
              .doc(uid)
              .collection('intakeLogs')
              .where(
                'timestamp',
                isGreaterThan: Timestamp.fromDate(ninetyDaysAgo),
              )
              .orderBy('timestamp', descending: true)
              .get();

      takenDates =
          logs.docs.map((doc) {
            final timestamp = doc.data()['timestamp'] as Timestamp;
            return timestamp.toDate();
          }).toList();
    } catch (e) {
      print('Error loading taken dates: $e');
    }
  }

  // Calculate when inventory will run out based on daily intake
  void _calculateInventoryRunsOut() {
    if (currentInventory > 0) {
      inventoryRunsOutDate = DateTime.now().add(
        Duration(days: currentInventory),
      );
    } else {
      inventoryRunsOutDate = null;
    }
  }

  // Check if a specific date is within inventory range
  bool isDateCovered(DateTime date) {
    if (inventoryRunsOutDate == null) return false;

    final dateOnly = DateTime(date.year, date.month, date.day);
    final today = DateTime.now();
    final todayOnly = DateTime(today.year, today.month, today.day);
    final runsOutDateOnly = DateTime(
      inventoryRunsOutDate!.year,
      inventoryRunsOutDate!.month,
      inventoryRunsOutDate!.day,
    );

    return (dateOnly.isAtSameMomentAs(todayOnly) ||
            dateOnly.isAfter(todayOnly)) &&
        (dateOnly.isBefore(runsOutDateOnly) ||
            dateOnly.isAtSameMomentAs(runsOutDateOnly));
  }

  // Check if medication was taken on a specific date
  bool wasTakenOnDate(DateTime date) {
    final dateOnly = DateTime(date.year, date.month, date.day);
    return takenDates.any((takenDate) {
      final takenDateOnly = DateTime(
        takenDate.year,
        takenDate.month,
        takenDate.day,
      );
      return takenDateOnly.isAtSameMomentAs(dateOnly);
    });
  }

  // Save initial medication settings
  Future<bool> saveMedicationSettings({
    required String time,
    required int inventory,
    required int reminderThreshold,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return false;

      await _firestore.collection('medicalTracker').doc(user.uid).set({
        'uid': user.uid,
        'generatedUIC': generatedUIC,
        'treatmentHub': treatmentHub,
        'medicationTime': time,
        'currentInventory': inventory,
        'threshold': reminderThreshold,
        'lastTakenDate': null,
        'consecutiveMissedDays': 0,
        'setupDate': FieldValue.serverTimestamp(),
        'lastUpdated': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      medicationTime = time;
      currentInventory = inventory;
      threshold = reminderThreshold;
      isSetupComplete = true;

      _calculateInventoryRunsOut();
      notifyListeners();

      print('✅ Initial medication settings saved');
      return true;
    } catch (e) {
      print('Error saving medication settings: $e');
      return false;
    }
  }

  // Update medication time - WITH SETUP CHECK
  Future<bool> updateMedicationTime(String newTime) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return false;

      // Check if document exists first
      final docExists = await checkSetupStatus();

      if (!docExists) {
        print('⚠️ Cannot update - setup not complete');
        // Create initial document with just the time
        await _firestore.collection('medicalTracker').doc(user.uid).set({
          'uid': user.uid,
          'generatedUIC': generatedUIC,
          'treatmentHub': treatmentHub,
          'medicationTime': newTime,
          'currentInventory': 0,
          'threshold': 0,
          'setupDate': FieldValue.serverTimestamp(),
          'lastUpdated': FieldValue.serverTimestamp(),
        });
        isSetupComplete = true;
      } else {
        await _firestore.collection('medicalTracker').doc(user.uid).update({
          'medicationTime': newTime,
          'lastUpdated': FieldValue.serverTimestamp(),
        });
      }

      medicationTime = newTime;
      notifyListeners();

      print('✅ Medication time updated to: $newTime');
      return true;
    } catch (e) {
      print('Error updating medication time: $e');
      return false;
    }
  }

  // Update threshold - WITH SETUP CHECK
  Future<bool> updateThreshold(int newThreshold) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return false;

      // Check if document exists first
      final docExists = await checkSetupStatus();

      if (!docExists) {
        print('⚠️ Cannot update - setup not complete');
        // Create initial document with just the threshold
        await _firestore.collection('medicalTracker').doc(user.uid).set({
          'uid': user.uid,
          'generatedUIC': generatedUIC,
          'treatmentHub': treatmentHub,
          'medicationTime': '',
          'currentInventory': 0,
          'threshold': newThreshold,
          'setupDate': FieldValue.serverTimestamp(),
          'lastUpdated': FieldValue.serverTimestamp(),
        });
        isSetupComplete = true;
      } else {
        await _firestore.collection('medicalTracker').doc(user.uid).update({
          'threshold': newThreshold,
          'lastUpdated': FieldValue.serverTimestamp(),
        });
      }

      threshold = newThreshold;
      notifyListeners();

      print('✅ Threshold updated to: $newThreshold');
      return true;
    } catch (e) {
      print('Error updating threshold: $e');
      return false;
    }
  }

  // Log medication taken
  Future<bool> logMedicationTaken() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return false;

      if (!isSetupComplete) {
        print('⚠️ Cannot log medication - setup not complete');
        return false;
      }

      if (currentInventory <= 0) {
        print('⚠️ No pills in inventory');
        return false;
      }

      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);

      // Check if already taken today
      if (wasTakenOnDate(today)) {
        print('⚠️ Medication already logged for today');
        return false;
      }

      final newInventory = currentInventory - 1;

      // Create intake log
      await _firestore
          .collection('medicalTracker')
          .doc(user.uid)
          .collection('intakeLogs')
          .add({
            'timestamp': FieldValue.serverTimestamp(),
            'inventoryBefore': currentInventory,
            'inventoryAfter': newInventory,
            'generatedUIC': generatedUIC,
            'treatmentHub': treatmentHub,
          });

      // Update main tracker
      await _firestore.collection('medicalTracker').doc(user.uid).update({
        'currentInventory': newInventory,
        'lastTakenDate': FieldValue.serverTimestamp(),
        'consecutiveMissedDays': 0,
        'lastUpdated': FieldValue.serverTimestamp(),
      });

      currentInventory = newInventory;
      lastTakenDate = now;
      consecutiveMissedDays = 0;
      takenDates.insert(0, now);

      _calculateInventoryRunsOut();

      // Check if below threshold and send alert to center
      if (newInventory <= threshold) {
        await _sendLowInventoryAlert();
      }

      notifyListeners();
      print('✅ Medication logged successfully');
      return true;
    } catch (e) {
      print('Error logging medication intake: $e');
      return false;
    }
  }

  // Check for missed doses and update
  Future<void> checkMissedDoses() async {
    try {
      final user = _auth.currentUser;
      if (user == null || !isSetupComplete) return;

      if (lastTakenDate == null) return;

      final now = DateTime.now();
      final daysSinceLastTaken = now.difference(lastTakenDate!).inDays;

      if (daysSinceLastTaken > consecutiveMissedDays &&
          daysSinceLastTaken > 0) {
        consecutiveMissedDays = daysSinceLastTaken;

        await _firestore.collection('medicalTracker').doc(user.uid).update({
          'consecutiveMissedDays': consecutiveMissedDays,
          'lastUpdated': FieldValue.serverTimestamp(),
        });

        // Alert center if missed more than 3 days
        if (consecutiveMissedDays >= 3) {
          await _sendMissedDosesAlert();
        }

        notifyListeners();
      }
    } catch (e) {
      print('Error checking missed doses: $e');
    }
  }

  // Send alert to treatment center for low inventory
  Future<void> _sendLowInventoryAlert() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      await _firestore.collection('centerAlerts').add({
        'type': 'lowInventory',
        'uid': user.uid,
        'generatedUIC': generatedUIC,
        'treatmentHub': treatmentHub,
        'currentInventory': currentInventory,
        'threshold': threshold,
        'message':
            'Patient $generatedUIC has $currentInventory pills remaining (below threshold of $threshold)',
        'status': 'pending',
        'timestamp': FieldValue.serverTimestamp(),
      });

      print('✅ Low inventory alert sent to center');
    } catch (e) {
      print('Error sending low inventory alert: $e');
    }
  }

  // Send alert for missed doses
  Future<void> _sendMissedDosesAlert() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      await _firestore.collection('centerAlerts').add({
        'type': 'missedDoses',
        'uid': user.uid,
        'generatedUIC': generatedUIC,
        'treatmentHub': treatmentHub,
        'consecutiveMissedDays': consecutiveMissedDays,
        'lastTakenDate':
            lastTakenDate != null ? Timestamp.fromDate(lastTakenDate!) : null,
        'message':
            'Patient $generatedUIC has not taken medication for $consecutiveMissedDays consecutive days',
        'status': 'pending',
        'timestamp': FieldValue.serverTimestamp(),
      });

      print('✅ Missed doses alert sent to center');
    } catch (e) {
      print('Error sending missed doses alert: $e');
    }
  }

  // Log refill - WITH SETUP CHECK
  Future<bool> logRefill({required int bottles, String? hub}) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return false;

      final pillsAdded = bottles * 30;
      final newInventory = currentInventory + pillsAdded;

      // Check if document exists
      final docExists = await checkSetupStatus();

      if (!docExists) {
        // Create document if it doesn't exist
        await _firestore.collection('medicalTracker').doc(user.uid).set({
          'uid': user.uid,
          'generatedUIC': generatedUIC,
          'treatmentHub': hub ?? treatmentHub,
          'medicationTime': '',
          'currentInventory': newInventory,
          'threshold': 0,
          'lastRefill': FieldValue.serverTimestamp(),
          'setupDate': FieldValue.serverTimestamp(),
          'lastUpdated': FieldValue.serverTimestamp(),
        });
        isSetupComplete = true;
      } else {
        // Update existing document
        await _firestore.collection('medicalTracker').doc(user.uid).update({
          'currentInventory': newInventory,
          'lastRefill': FieldValue.serverTimestamp(),
          'lastUpdated': FieldValue.serverTimestamp(),
        });
      }

      // Save refill log
      await _firestore
          .collection('medicalTracker')
          .doc(user.uid)
          .collection('refillLogs')
          .add({
            'bottles': bottles,
            'pillsAdded': pillsAdded,
            'previousInventory': currentInventory,
            'newInventory': newInventory,
            'hub': hub ?? treatmentHub,
            'generatedUIC': generatedUIC,
            'timestamp': FieldValue.serverTimestamp(),
          });

      currentInventory = newInventory;
      if (hub != null) treatmentHub = hub;

      _calculateInventoryRunsOut();
      notifyListeners();

      print('✅ Refill logged: +$pillsAdded pills');
      return true;
    } catch (e) {
      print('Error logging refill: $e');
      return false;
    }
  }

  // Get adherence rate (percentage of days medication was taken)
  double getAdherenceRate(int days) {
    if (takenDates.isEmpty) return 0.0;

    final now = DateTime.now();
    final startDate = now.subtract(Duration(days: days));

    final recentTaken =
        takenDates.where((date) {
          return date.isAfter(startDate);
        }).length;

    return (recentTaken / days) * 100;
  }

  bool get isBelowThreshold => currentInventory <= threshold;
  bool get hasInventory => currentInventory > 0;
  bool get needsRefill => currentInventory <= threshold;
}
