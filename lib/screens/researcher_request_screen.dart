// lib/screens/analytics/researcher_request_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:file_picker/file_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';
import 'analytics/components/providers/user_role_provider.dart';
import './researcher_terms.dart';

class ResearcherRequestScreen extends StatefulWidget {
  @override
  _ResearcherRequestScreenState createState() =>
      _ResearcherRequestScreenState();
}

class _ResearcherRequestScreenState extends State<ResearcherRequestScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();

  bool _isLoading = false;
  bool _isFetchingCenters = true;
  Map<String, dynamic>? _pendingRequest;

  List<Map<String, dynamic>> _centers = [];
  String? _selectedCenterId;
  String? _selectedCenterName;

  PlatformFile? _selectedPdfFile;

  @override
  void initState() {
    super.initState();
    _checkPendingRequest();
    _fetchCenters();
  }

  Future<void> _checkPendingRequest() async {
    final roleProvider = Provider.of<UserRoleProvider>(context, listen: false);
    final pending = await roleProvider.getPendingRequest();
    setState(() {
      _pendingRequest = pending;
    });
  }

  Future<void> _fetchCenters() async {
    try {
      final snapshot =
          await FirebaseFirestore.instance
              .collection('centers')
              .orderBy('name')
              .get();

      setState(() {
        _centers =
            snapshot.docs
                .map(
                  (doc) => {
                    'id': doc.id,
                    'name': doc.data()['name'] ?? 'Unnamed Center',
                  },
                )
                .toList();
        _isFetchingCenters = false;
      });
    } catch (e) {
      setState(() => _isFetchingCenters = false);
      _showErrorSnackbar('Failed to load centers');
    }
  }

  Future<void> _pickPdfFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );

      if (result != null) {
        setState(() {
          _selectedPdfFile = result.files.first;
        });
      }
    } catch (e) {
      _showErrorSnackbar('Error picking file');
    }
  }

  @override
  Widget build(BuildContext context) {
    // If there's a pending request, show status
    if (_pendingRequest != null) {
      return _buildPendingRequestView();
    }

    return Scaffold(
      backgroundColor: Color(0xFFF0F2F5),
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        child: Column(children: [_buildHeroSection(), _buildFormSection()]),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: Icon(Icons.arrow_back, color: Color(0xFF1C1E21)),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(
        'Become a Researcher',
        style: GoogleFonts.workSans(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Color(0xFF1C1E21),
        ),
      ),
    );
  }

  Widget _buildHeroSection() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF1877F2).withOpacity(0.1), Colors.white],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Color(0xFF1877F2).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              FontAwesomeIcons.userDoctor,
              size: 40,
              color: Color(0xFF1877F2),
            ),
          ),
          SizedBox(height: 20),
          Text(
            'Join Our Research Community',
            style: GoogleFonts.workSans(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1C1E21),
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Help advance healthcare through data-driven insights',
            style: GoogleFonts.workSans(fontSize: 14, color: Color(0xFF65676B)),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildFormSection() {
    return Padding(
      padding: EdgeInsets.all(20),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildFormCard(),
            SizedBox(height: 20),
            _buildRequirementsCard(),
            SizedBox(height: 20),
            _buildSubmitButton(),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildFormCard() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Application Details',
            style: GoogleFonts.workSans(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1C1E21),
            ),
          ),
          SizedBox(height: 20),
          _buildTextField(
            controller: _fullNameController,
            label: 'Full Name',
            hint: 'Enter your complete name',
            icon: Icons.person_outline,
            validator:
                (value) =>
                    value?.isEmpty ?? true
                        ? 'Please enter your full name'
                        : null,
          ),
          SizedBox(height: 16),
          _buildTextField(
            controller: _emailController,
            label: 'Gmail Address',
            hint: 'your.email@gmail.com',
            icon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value?.isEmpty ?? true) return 'Please enter your Gmail';
              if (!value!.contains('@gmail.com')) {
                return 'Please enter a valid Gmail address';
              }
              return null;
            },
          ),
          SizedBox(height: 16),
          _buildCenterDropdown(),
          SizedBox(height: 16),
          _buildPdfUploadSection(),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      style: GoogleFonts.workSans(fontSize: 14),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: Color(0xFF1877F2)),
        filled: true,
        fillColor: Color(0xFFF0F2F5),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Color(0xFF1877F2), width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.red[300]!, width: 1),
        ),
        labelStyle: GoogleFonts.workSans(
          fontSize: 14,
          color: Color(0xFF65676B),
        ),
        hintStyle: GoogleFonts.workSans(fontSize: 12, color: Color(0xFF65676B)),
      ),
    );
  }

  Widget _buildCenterDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Institution/Center',
          style: GoogleFonts.workSans(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(0xFF65676B),
          ),
        ),
        SizedBox(height: 9),
        _isFetchingCenters
            ? Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Color(0xFFF0F2F5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(child: CircularProgressIndicator()),
            )
            : DropdownButtonFormField<String>(
              isExpanded: true,
              value: _selectedCenterId,
              decoration: InputDecoration(
                prefixIcon: Icon(
                  Icons.local_hospital_outlined,
                  color: Color(0xFF1877F2),
                ),
                filled: true,
                fillColor: Color(0xFFF0F2F5),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Color(0xFF1877F2), width: 2),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.red[300]!, width: 1),
                ),
              ),
              hint: Text(
                'Select your institution',
                style: GoogleFonts.workSans(
                  fontSize: 12,
                  color: Color(0xFF65676B),
                ),
              ),
              items:
                  _centers.map((center) {
                    return DropdownMenuItem<String>(
                      value: center['id'],
                      child: Text(
                        center['name'],
                        style: GoogleFonts.workSans(fontSize: 14),
                      ),
                    );
                  }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedCenterId = value;
                  _selectedCenterName =
                      _centers.firstWhere((c) => c['id'] == value)['name'];
                });
              },
              validator:
                  (value) =>
                      value == null ? 'Please select an institution' : null,
            ),
      ],
    );
  }

  Widget _buildPdfUploadSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Research Proposal (PDF)',
          style: GoogleFonts.workSans(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(0xFF65676B),
          ),
        ),
        SizedBox(height: 8),
        InkWell(
          onTap: _pickPdfFile,
          child: Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Color(0xFFF0F2F5),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color:
                    _selectedPdfFile != null
                        ? Color(0xFF42B883)
                        : Color(0xFFE0E0E0),
                width: 2,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  _selectedPdfFile != null
                      ? Icons.picture_as_pdf
                      : Icons.upload_file,
                  color:
                      _selectedPdfFile != null
                          ? Color(0xFF42B883)
                          : Color(0xFF1877F2),
                  size: 24,
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _selectedPdfFile != null
                            ? _selectedPdfFile!.name
                            : 'Upload your research proposal',
                        style: GoogleFonts.workSans(
                          fontSize: 14,
                          fontWeight:
                              _selectedPdfFile != null
                                  ? FontWeight.w600
                                  : FontWeight.w400,
                          color:
                              _selectedPdfFile != null
                                  ? Color(0xFF1C1E21)
                                  : Color(0xFF65676B),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (_selectedPdfFile != null)
                        Text(
                          '${(_selectedPdfFile!.size / 1024).toStringAsFixed(2)} KB',
                          style: GoogleFonts.workSans(
                            fontSize: 12,
                            color: Color(0xFF65676B),
                          ),
                        ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: Color(0xFF65676B),
                ),
              ],
            ),
          ),
        ),
        if (_selectedPdfFile == null)
          Padding(
            padding: EdgeInsets.only(top: 8, left: 4),
            child: Text(
              'Please upload a PDF explaining why you want researcher access',
              style: GoogleFonts.workSans(fontSize: 12, color: Colors.red[700]),
            ),
          ),
      ],
    );
  }

  Widget _buildRequirementsCard() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, color: Color(0xFF1877F2), size: 20),
              SizedBox(width: 8),
              Text(
                'Requirements',
                style: GoogleFonts.workSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1C1E21),
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          _buildRequirementItem('Complete name and Gmail address'),
          _buildRequirementItem('Institutional affiliation from our centers'),
          _buildRequirementItem('Research proposal in PDF format'),
          _buildRequirementItem('Commitment to data privacy and ethical use'),
        ],
      ),
    );
  }

  Widget _buildRequirementItem(String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: EdgeInsets.only(top: 6),
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: Color(0xFF42B883),
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.workSans(
                fontSize: 14,
                color: Color(0xFF65676B),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showConsentDialog() {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedPdfFile == null) {
      _showErrorSnackbar('Please upload a PDF research proposal');
      return;
    }

    // Show consent dialog
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => ResearcherApplicationConsentDialog(
              onAccept: _submitRequest,
              onDecline: () {
                _showErrorSnackbar(
                  'You must accept the consent to submit your application',
                );
              },
            ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return Container(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _showConsentDialog,
        style: ElevatedButton.styleFrom(
          backgroundColor: Color(0xFF1877F2),
          foregroundColor: Colors.white,
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
                    Icon(Icons.send_outlined, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Submit Request',
                      style: GoogleFonts.workSans(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
      ),
    );
  }

  Widget _buildPendingRequestView() {
    return Scaffold(
      backgroundColor: Color(0xFFF0F2F5),
      appBar: _buildAppBar(),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Container(
            padding: EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.hourglass_empty,
                    size: 40,
                    color: Colors.orange,
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  'Request Pending',
                  style: GoogleFonts.workSans(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1C1E21),
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Your researcher request is being reviewed.\nYou will be notified once approved.',
                  style: GoogleFonts.workSans(
                    fontSize: 14,
                    color: Color(0xFF65676B),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _submitRequest() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedPdfFile == null) {
      _showErrorSnackbar('Please upload a PDF research proposal');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final roleProvider = Provider.of<UserRoleProvider>(
        context,
        listen: false,
      );

      final success = await roleProvider.requestResearcherUpgrade(
        fullName: _fullNameController.text,
        email: _emailController.text,
        centerId: _selectedCenterId!,
        centerName: _selectedCenterName!,
        pdfFile: _selectedPdfFile!,
      );

      if (success) {
        _showSuccessDialog();
      } else {
        _showErrorSnackbar('Failed to submit request. Please try again.');
      }
    } catch (e) {
      _showErrorSnackbar('An error occurred. Please try again.');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showSuccessDialog() {
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
                Icon(Icons.check_circle, color: Color(0xFF42B883), size: 28),
                SizedBox(width: 12),
                Text(
                  'Request Submitted',
                  style: GoogleFonts.workSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            content: Text(
              'Your researcher request has been submitted successfully. You will be notified at ${_emailController.text} once reviewed.',
              style: GoogleFonts.workSans(fontSize: 14),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
                child: Text(
                  'OK',
                  style: GoogleFonts.workSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1877F2),
                  ),
                ),
              ),
            ],
          ),
    );
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    super.dispose();
  }
}
