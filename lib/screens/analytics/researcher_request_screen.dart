// lib/screens/settings/upgrade_request_screen.dart
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:io';

class UpgradeRequestScreen extends StatefulWidget {
  @override
  _UpgradeRequestScreenState createState() => _UpgradeRequestScreenState();
}

class _UpgradeRequestScreenState extends State<UpgradeRequestScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;
  final _storage = FirebaseStorage.instance;

  // Form controllers
  final _fullNameController = TextEditingController();
  final _licenseNumberController = TextEditingController();
  final _institutionController = TextEditingController();
  final _positionController = TextEditingController();
  final _specialtyController = TextEditingController();
  final _reasonController = TextEditingController();

  // File uploads
  File? _licenseImage;
  File? _idImage;
  File? _certificateImage;

  bool _isLoading = false;
  String? _existingRequestId;
  Map<String, dynamic>? _existingRequest;

  @override
  void initState() {
    super.initState();
    _checkExistingRequest();
  }

  Future<void> _checkExistingRequest() async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      final query =
          await _firestore
              .collection('researcher_requests')
              .where('phoneNumber', isEqualTo: user.phoneNumber)
              .limit(1)
              .get();

      if (query.docs.isNotEmpty) {
        setState(() {
          _existingRequestId = query.docs.first.id;
          _existingRequest = query.docs.first.data();
        });
      }
    } catch (e) {
      print('Error checking existing request: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    // If there's an existing request, show status
    if (_existingRequest != null) {
      return _buildExistingRequestView();
    }

    return Scaffold(
      backgroundColor: Color(0xFFF8F9FC),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: Text(
          'Healthcare Provider Verification',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Color(0xFF2D3436),
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Color(0xFF2D3436)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Hero Section
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.verified_user, color: Colors.white, size: 48),
                  SizedBox(height: 16),
                  Text(
                    'Become a Verified Researcher',
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Access advanced analytics and contribute to research',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),

            // Form Section
            Padding(
              padding: EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Personal Information Section
                    _buildSectionHeader('Personal Information'),
                    _buildTextField(
                      controller: _fullNameController,
                      label: 'Full Name',
                      hint: 'As it appears on your license',
                      icon: Icons.person,
                      validator: (value) {
                        if (value?.isEmpty ?? true) {
                          return 'Please enter your full name';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16),

                    // Professional Information Section
                    _buildSectionHeader('Professional Information'),
                    _buildTextField(
                      controller: _licenseNumberController,
                      label: 'Professional License Number',
                      hint: 'PRC/DOH License Number',
                      icon: Icons.badge,
                      validator: (value) {
                        if (value?.isEmpty ?? true) {
                          return 'Please enter your license number';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16),
                    _buildTextField(
                      controller: _institutionController,
                      label: 'Institution/Hospital',
                      hint: 'Current workplace',
                      icon: Icons.local_hospital,
                      validator: (value) {
                        if (value?.isEmpty ?? true) {
                          return 'Please enter your institution';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16),
                    _buildTextField(
                      controller: _positionController,
                      label: 'Position/Title',
                      hint: 'e.g., Senior Nurse, Medical Officer',
                      icon: Icons.work,
                    ),
                    SizedBox(height: 16),
                    _buildDropdownField(),
                    SizedBox(height: 16),

                    // Reason for Access
                    _buildSectionHeader('Purpose of Access'),
                    _buildTextField(
                      controller: _reasonController,
                      label: 'Reason for Requesting Access',
                      hint: 'Describe how you will use the analytics data',
                      icon: Icons.description,
                      maxLines: 4,
                      validator: (value) {
                        if (value?.isEmpty ?? true) {
                          return 'Please provide a reason';
                        }
                        if (value!.length < 50) {
                          return 'Please provide more detail (min 50 characters)';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 24),

                    // Document Upload Section
                    _buildSectionHeader('Required Documents'),
                    _buildUploadCard(
                      title: 'Professional License',
                      subtitle: 'Upload clear photo of your PRC/DOH license',
                      file: _licenseImage,
                      onTap: () => _pickImage('license'),
                      isRequired: true,
                    ),
                    SizedBox(height: 12),
                    _buildUploadCard(
                      title: 'Valid ID',
                      subtitle: 'Government-issued ID',
                      file: _idImage,
                      onTap: () => _pickImage('id'),
                      isRequired: true,
                    ),
                    SizedBox(height: 12),
                    _buildUploadCard(
                      title: 'Certificate/Credential',
                      subtitle: 'Additional certification (optional)',
                      file: _certificateImage,
                      onTap: () => _pickImage('certificate'),
                      isRequired: false,
                    ),

                    // Terms and Conditions
                    SizedBox(height: 24),
                    _buildTermsSection(),

                    // Submit Button
                    SizedBox(height: 32),
                    _buildSubmitButton(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16, top: 8),
      child: Text(
        title,
        style: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Color(0xFF2D3436),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: Color(0xFF667EEA)),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Color(0xFF667EEA), width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.red[300]!),
        ),
      ),
    );
  }

  Widget _buildDropdownField() {
    String? _selectedSpecialty;
    final specialties = [
      'HIV/AIDS Specialist',
      'Infectious Disease',
      'Public Health',
      'Epidemiology',
      'Nursing',
      'Laboratory',
      'Counseling',
      'Other',
    ];

    return DropdownButtonFormField<String>(
      value: _selectedSpecialty,
      decoration: InputDecoration(
        labelText: 'Specialty/Field',
        prefixIcon: Icon(Icons.medical_services, color: Color(0xFF667EEA)),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
      ),
      items:
          specialties.map((specialty) {
            return DropdownMenuItem(value: specialty, child: Text(specialty));
          }).toList(),
      onChanged: (value) {
        setState(() {
          _selectedSpecialty = value;
          _specialtyController.text = value ?? '';
        });
      },
      validator: (value) {
        if (value == null) {
          return 'Please select your specialty';
        }
        return null;
      },
    );
  }

  Widget _buildUploadCard({
    required String title,
    required String subtitle,
    required File? file,
    required VoidCallback onTap,
    required bool isRequired,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: file != null ? Color(0xFF667EEA) : Colors.grey[300]!,
            width: file != null ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color:
                    file != null
                        ? Color(0xFF667EEA).withOpacity(0.1)
                        : Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child:
                  file != null
                      ? ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.file(file, fit: BoxFit.cover),
                      )
                      : Icon(
                        Icons.upload_file,
                        color:
                            file != null ? Color(0xFF667EEA) : Colors.grey[400],
                        size: 28,
                      ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF2D3436),
                        ),
                      ),
                      if (isRequired) ...[
                        SizedBox(width: 4),
                        Text('*', style: TextStyle(color: Colors.red)),
                      ],
                    ],
                  ),
                  SizedBox(height: 4),
                  Text(
                    file != null ? 'File selected' : subtitle,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color:
                          file != null ? Color(0xFF667EEA) : Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            if (file != null)
              Icon(Icons.check_circle, color: Color(0xFF667EEA), size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildTermsSection() {
    bool _agreedToTerms = false;

    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Color(0xFFF8F9FC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Data Privacy Agreement',
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF2D3436),
            ),
          ),
          SizedBox(height: 8),
          Text(
            'By submitting this request, you agree to:',
            style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[600]),
          ),
          SizedBox(height: 8),
          _buildTermItem(
            'Use data only for legitimate research and healthcare purposes',
          ),
          _buildTermItem(
            'Maintain strict confidentiality of all patient information',
          ),
          _buildTermItem(
            'Not share or distribute analytics data without authorization',
          ),
          _buildTermItem(
            'Comply with all applicable data privacy laws and regulations',
          ),
          SizedBox(height: 12),
          Row(
            children: [
              StatefulBuilder(
                builder: (context, setState) {
                  return Checkbox(
                    value: _agreedToTerms,
                    onChanged: (value) {
                      setState(() {
                        _agreedToTerms = value ?? false;
                      });
                    },
                    activeColor: Color(0xFF667EEA),
                  );
                },
              ),
              Expanded(
                child: Text(
                  'I agree to the terms and conditions',
                  style: GoogleFonts.poppins(fontSize: 12),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTermItem(String text) {
    return Padding(
      padding: EdgeInsets.only(left: 16, bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('• ', style: TextStyle(color: Color(0xFF667EEA))),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey[700]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton() {
    return Container(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _submitRequest,
        style: ElevatedButton.styleFrom(
          backgroundColor: Color(0xFF667EEA),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        child:
            _isLoading
                ? CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                )
                : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.send, color: Colors.white),
                    SizedBox(width: 8),
                    Text(
                      'Submit Verification Request',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
      ),
    );
  }

  Widget _buildExistingRequestView() {
    final status = _existingRequest!['status'] ?? 'pending';
    final statusColors = {
      'pending': Colors.orange,
      'approved': Colors.green,
      'rejected': Colors.red,
      'review': Colors.blue,
    };

    return Scaffold(
      backgroundColor: Color(0xFFF8F9FC),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: Text(
          'Verification Status',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Color(0xFF2D3436),
          ),
        ),
      ),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: statusColors[status]!.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  status == 'approved'
                      ? Icons.check_circle
                      : status == 'rejected'
                      ? Icons.cancel
                      : status == 'review'
                      ? Icons.rate_review
                      : Icons.hourglass_empty,
                  size: 60,
                  color: statusColors[status],
                ),
              ),
              SizedBox(height: 24),
              Text(
                status == 'approved'
                    ? 'Verification Approved!'
                    : status == 'rejected'
                    ? 'Verification Rejected'
                    : status == 'review'
                    ? 'Under Review'
                    : 'Verification Pending',
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF2D3436),
                ),
              ),
              SizedBox(height: 12),
              Text(
                status == 'approved'
                    ? 'You now have access to researcher analytics'
                    : status == 'rejected'
                    ? _existingRequest!['rejectionReason'] ??
                        'Please contact support for details'
                    : status == 'review'
                    ? 'An admin is reviewing your documents'
                    : 'Your request has been submitted',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
              if (_existingRequest!['submittedAt'] != null) ...[
                SizedBox(height: 24),
                Text(
                  'Submitted: ${_formatDate(_existingRequest!['submittedAt'])}',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.grey[500],
                  ),
                ),
              ],
              if (status == 'rejected') ...[
                SizedBox(height: 32),
                ElevatedButton(
                  onPressed: _clearRequest,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF667EEA),
                    padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                  child: Text(
                    'Submit New Request',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickImage(String type) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 85,
    );

    if (pickedFile != null) {
      setState(() {
        switch (type) {
          case 'license':
            _licenseImage = File(pickedFile.path);
            break;
          case 'id':
            _idImage = File(pickedFile.path);
            break;
          case 'certificate':
            _certificateImage = File(pickedFile.path);
            break;
        }
      });
    }
  }

  Future<void> _submitRequest() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_licenseImage == null || _idImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please upload required documents'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      // Upload documents to Firebase Storage
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final userId = user.phoneNumber!.replaceAll(RegExp(r'[^\d]'), '');

      String? licenseUrl = await _uploadFile(
        _licenseImage!,
        'verification_docs/$userId/license_$timestamp.jpg',
      );

      String? idUrl = await _uploadFile(
        _idImage!,
        'verification_docs/$userId/id_$timestamp.jpg',
      );

      String? certificateUrl;
      if (_certificateImage != null) {
        certificateUrl = await _uploadFile(
          _certificateImage!,
          'verification_docs/$userId/certificate_$timestamp.jpg',
        );
      }

      // Create request document
      final requestData = {
        'userId': user.uid,
        'phoneNumber': user.phoneNumber,
        'fullName': _fullNameController.text,
        'licenseNumber': _licenseNumberController.text,
        'institution': _institutionController.text,
        'position': _positionController.text,
        'specialty': _specialtyController.text,
        'reason': _reasonController.text,
        'documents': {
          'license': licenseUrl,
          'id': idUrl,
          'certificate': certificateUrl,
        },
        'status': 'pending',
        'submittedAt': FieldValue.serverTimestamp(),
        'lastUpdated': FieldValue.serverTimestamp(),
      };

      // Save to Firestore
      await _firestore.collection('researcher_requests').add(requestData);

      // Show success
      showDialog(
        context: context,
        barrierDismissible: false,
        builder:
            (context) => AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.green, size: 28),
                  SizedBox(width: 12),
                  Text('Request Submitted'),
                ],
              ),
              content: Text(
                'Your verification request has been submitted successfully. You will be notified once it has been reviewed.',
                style: GoogleFonts.poppins(fontSize: 14),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pop(context);
                  },
                  child: Text('OK'),
                ),
              ],
            ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error submitting request: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<String?> _uploadFile(File file, String path) async {
    try {
      final ref = _storage.ref().child(path);
      final uploadTask = await ref.putFile(file);
      return await uploadTask.ref.getDownloadURL();
    } catch (e) {
      print('Error uploading file: $e');
      return null;
    }
  }

  void _clearRequest() {
    setState(() {
      _existingRequest = null;
      _existingRequestId = null;
    });
  }

  String _formatDate(dynamic timestamp) {
    if (timestamp == null) return 'Unknown';
    if (timestamp is Timestamp) {
      final date = timestamp.toDate();
      return '${date.day}/${date.month}/${date.year}';
    }
    return 'Unknown';
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _licenseNumberController.dispose();
    _institutionController.dispose();
    _positionController.dispose();
    _specialtyController.dispose();
    _reasonController.dispose();
    super.dispose();
  }
}
