// lib/screens/analytics/testing/providers/user_role_provider.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:convert';
import 'dart:io';

class UserRoleProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String _currentRole = 'infoSeeker';
  bool _isAuthenticated = false;
  Map<String, dynamic>? _userData;
  bool _isLoading = false;
  bool _isInitialized = false;

  // Getters
  String get currentRole => _currentRole;
  bool get isAuthenticated => _isAuthenticated;
  bool get isLoading => _isLoading;
  bool get isInitialized => _isInitialized;
  Map<String, dynamic>? get userData => _userData;

  // Role helpers
  bool get isInfoSeeker => _currentRole == 'infoSeeker';
  bool get isPLHIV => _currentRole == 'plhiv';
  bool get isResearcher => _currentRole == 'researcher';

  // Dashboard helpers
  bool get shouldShowGeneralDashboard => isInfoSeeker || isPLHIV;
  bool get shouldShowResearcherDashboard => isResearcher;

  Future<void> checkUserRole() async {
    // Prevent multiple simultaneous calls
    if (_isLoading) {
      print('⏳ Already loading, skipping duplicate call');
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      final user = _auth.currentUser;
      if (user == null) {
        print('❌ No current user');
        _setGuestState();
        return;
      }

      print('🔍 Checking role for user: ${user.uid}');
      _isAuthenticated = true;

      final userDoc = await _firestore.collection('user').doc(user.uid).get();

      if (userDoc.exists) {
        _userData = userDoc.data();

        if (_userData!.containsKey('role')) {
          _currentRole = _userData!['role'];
        } else {
          _currentRole = 'infoSeeker';
        }

        print('✅ Role loaded: $_currentRole');
        print('📊 User data: ${_userData!.keys.join(', ')}');

        // Update last login timestamp
        await _firestore.collection('user').doc(user.uid).update({
          'lastLogin': FieldValue.serverTimestamp(),
        });

        _isInitialized = true;
        print('✅ Provider initialized successfully');
      } else {
        print('⚠️ No user doc found for ${user.uid}');
        _setGuestState();
      }
    } catch (e) {
      print('❌ Error checking role: $e');
      if (_userData == null) {
        _setGuestState();
      }
    } finally {
      _isLoading = false;
      notifyListeners();
      print(
        '🏁 checkUserRole completed. isInitialized: $_isInitialized, role: $_currentRole',
      );
    }
  }

  Future<bool> requestResearcherUpgrade({
    required String fullName,
    required String email,
    required String centerId,
    required String centerName,
    required PlatformFile pdfFile,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        print('❌ No authenticated user');
        return false;
      }

      final uid = user.uid;
      print('📤 Starting researcher request for user: $uid');

      String? pdfBase64;
      List<int> pdfBytes;

      try {
        if (pdfFile.bytes != null) {
          pdfBytes = pdfFile.bytes!;
          print('✅ PDF bytes from web platform');
        } else if (pdfFile.path != null) {
          final file = File(pdfFile.path!);
          if (!await file.exists()) {
            print('❌ PDF file does not exist at path: ${pdfFile.path}');
            return false;
          }
          pdfBytes = await file.readAsBytes();
          print('✅ PDF bytes read from file path');
        } else {
          print('❌ No PDF bytes or path available');
          return false;
        }

        pdfBase64 = base64Encode(pdfBytes);
        print(
          '✅ PDF converted to base64: ${pdfFile.name} (${pdfBytes.length} bytes)',
        );
      } catch (e) {
        print('❌ Error converting PDF: $e');
        return false;
      }

      try {
        final requestData = {
          'userId': uid,
          'userEmail': user.email ?? email,
          'fullName': fullName,
          'email': email,
          'centerId': centerId,
          'centerName': centerName,
          'pdfFileName': pdfFile.name,
          'pdfFileSize': pdfFile.size,
          'status': 'pending',
          'currentRole': _currentRole,
          'requestedAt': FieldValue.serverTimestamp(),
          'reviewedAt': null,
          'reviewedBy': null,
          'reviewNotes': null,
        };

        final docRef = await _firestore.collection('requests').add(requestData);
        print('✅ Request document created: ${docRef.id}');

        await _sendEmailWithPdfAttachment(
          requestId: docRef.id,
          userId: uid,
          fullName: fullName,
          email: email,
          centerName: centerName,
          pdfFileName: pdfFile.name,
          pdfBase64: pdfBase64,
        );

        print('✅ Researcher request submitted successfully');
        return true;
      } catch (e) {
        print('❌ Error saving request to Firestore: $e');
        return false;
      }
    } catch (e) {
      print('❌ Error requesting researcher upgrade: $e');
      return false;
    }
  }

  Future<void> _sendEmailWithPdfAttachment({
    required String requestId,
    required String userId,
    required String fullName,
    required String email,
    required String centerName,
    required String pdfFileName,
    required String pdfBase64,
  }) async {
    try {
      await _firestore.collection('mail').add({
        'to': ['tehnczonlanticse@gmail.com'],
        'from': 'Project ECHO <tehnczonlanticse@gmail.com>',
        'replyTo': email,
        'message': {
          'subject': '🔬 New Researcher Access Request - $fullName',
          'text': '''
New Researcher Access Request Received

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

👤 Applicant Details:
   Name: $fullName
   Email: $email
   User ID: $userId

🏥 Institution:
   $centerName

📄 Research Proposal:
   Please see the attached PDF document.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Request ID: $requestId

To approve or reject this request, please log in to the Project ECHO admin panel.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Project ECHO - Healthcare Analytics Platform
          ''',
          'html': '''
<!DOCTYPE html>
<html>
<head>
  <style>
    body { font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; line-height: 1.6; color: #333; margin: 0; padding: 0; }
    .container { max-width: 600px; margin: 0 auto; background: #ffffff; }
    .header { background: linear-gradient(135deg, #1877F2 0%, #0C63D4 100%); color: white; padding: 40px 30px; text-align: center; }
    .header h1 { margin: 0; font-size: 24px; font-weight: 600; }
    .header p { margin: 10px 0 0 0; font-size: 14px; opacity: 0.9; }
    .content { padding: 30px; }
    .info-box { background: #f8f9fa; border-left: 4px solid #1877F2; padding: 20px; margin: 20px 0; border-radius: 4px; }
    .info-row { margin-bottom: 15px; }
    .info-label { font-weight: 600; color: #1877F2; font-size: 13px; text-transform: uppercase; letter-spacing: 0.5px; margin-bottom: 5px; }
    .info-value { color: #333; font-size: 16px; }
    .attachment-notice { background: #fff3cd; border: 1px solid #ffc107; border-radius: 8px; padding: 15px; margin: 20px 0; }
    .attachment-notice p { margin: 0; color: #856404; }
    .attachment-icon { font-size: 24px; margin-right: 10px; }
    .footer { background: #f8f9fa; padding: 20px; text-align: center; color: #65676B; font-size: 12px; border-top: 1px solid #e0e0e0; }
    .footer p { margin: 5px 0; }
    .request-id { background: #e7f3ff; padding: 10px; border-radius: 4px; font-family: monospace; font-size: 14px; color: #0066cc; margin: 20px 0; text-align: center; }
  </style>
</head>
<body>
  <div class="container">
    <div class="header">
      <h1>🔬 New Researcher Access Request</h1>
      <p>A new application requires your review</p>
    </div>
    
    <div class="content">
      <p style="font-size: 16px; color: #333;">Hello Admin,</p>
      <p style="font-size: 14px; color: #666;">A new researcher has submitted an application to access analytics data on the Project ECHO platform.</p>
      
      <div class="info-box">
        <div class="info-row">
          <div class="info-label">👤 Applicant Name</div>
          <div class="info-value">$fullName</div>
        </div>
        
        <div class="info-row">
          <div class="info-label">📧 Email Address</div>
          <div class="info-value">$email</div>
        </div>
        
        <div class="info-row">
          <div class="info-label">🏥 Institution</div>
          <div class="info-value">$centerName</div>
        </div>
        
        <div class="info-row">
          <div class="info-label">🆔 User ID</div>
          <div class="info-value">$userId</div>
        </div>
      </div>
      
      <div class="attachment-notice">
        <p><span class="attachment-icon">📎</span><strong>Research Proposal Attached</strong></p>
        <p style="margin-top: 8px; font-size: 13px;">Please review the attached PDF document to evaluate the applicant's research objectives and intended use of data.</p>
      </div>
      
      <div class="request-id">
        <strong>Request ID:</strong> $requestId
      </div>
      
      <p style="font-size: 14px; color: #666; margin-top: 30px;">Please log in to the Project ECHO admin panel to approve or reject this application.</p>
    </div>
    
    <div class="footer">
      <p><strong>Project ECHO</strong> - Healthcare Analytics Platform</p>
      <p>This is an automated notification. To respond, please reply to $email</p>
      <p style="margin-top: 10px; font-size: 11px;">This email was sent on behalf of a researcher application.</p>
    </div>
  </div>
</body>
</html>
          ''',
          'attachments': [
            {
              'filename': pdfFileName,
              'content': pdfBase64,
              'encoding': 'base64',
              'contentType': 'application/pdf',
            },
          ],
        },
        'createdAt': FieldValue.serverTimestamp(),
      });

      print('✅ Email with PDF attachment queued');
    } catch (e) {
      print('⚠️ Error sending email: $e');
    }
  }

  Future<Map<String, dynamic>?> getPendingRequest() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return null;

      final uid = user.uid;

      final query =
          await _firestore
              .collection('requests')
              .where('userId', isEqualTo: uid)
              .where('status', isEqualTo: 'pending')
              .limit(1)
              .get();

      if (query.docs.isNotEmpty) {
        return query.docs.first.data();
      }
      return null;
    } catch (e) {
      print('❌ Error checking pending request: $e');
      return null;
    }
  }

  Future<bool> approveResearcherRequest(String requestId, String userId) async {
    try {
      await _firestore.collection('requests').doc(requestId).update({
        'status': 'approved',
        'reviewedAt': FieldValue.serverTimestamp(),
        'reviewedBy': _auth.currentUser?.uid,
      });

      await _firestore.collection('user').doc(userId).update({
        'role': 'researcher',
        'researcherApprovedAt': FieldValue.serverTimestamp(),
      });

      print('✅ Researcher request approved');
      return true;
    } catch (e) {
      print('❌ Error approving request: $e');
      return false;
    }
  }

  Future<bool> rejectResearcherRequest(
    String requestId,
    String rejectionReason,
  ) async {
    try {
      await _firestore.collection('requests').doc(requestId).update({
        'status': 'rejected',
        'reviewedAt': FieldValue.serverTimestamp(),
        'reviewedBy': _auth.currentUser?.uid,
        'reviewNotes': rejectionReason,
      });

      print('✅ Researcher request rejected');
      return true;
    } catch (e) {
      print('❌ Error rejecting request: $e');
      return false;
    }
  }

  void _setGuestState() {
    _currentRole = 'infoSeeker';
    _isAuthenticated = false;
    _userData = null;
    _isInitialized = true;
    print('👤 Guest state set');
  }

  void logout() {
    print('🚪 Logout called');
    _setGuestState();
    _isLoading = false;
    notifyListeners();
  }

  void reset() {
    print('🔄 Reset called - clearing all state');
    _isLoading = false;
    _currentRole = 'infoSeeker';
    _isAuthenticated = false;
    _userData = null;
    _isInitialized = false; // This is the key - allows re-initialization
    notifyListeners();
  }
}
