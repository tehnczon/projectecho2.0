// lib/screens/analytics/researcher_request_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import './components/providers/user_role_provider.dart';

class ResearcherRequestScreen extends StatefulWidget {
  @override
  _ResearcherRequestScreenState createState() =>
      _ResearcherRequestScreenState();
}

class _ResearcherRequestScreenState extends State<ResearcherRequestScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _licenseNumberController = TextEditingController();
  final _institutionController = TextEditingController();
  final _reasonController = TextEditingController();

  bool _isLoading = false;
  Map<String, dynamic>? _pendingRequest;

  @override
  void initState() {
    super.initState();
    _checkPendingRequest();
  }

  Future<void> _checkPendingRequest() async {
    final roleProvider = Provider.of<UserRoleProvider>(context, listen: false);
    final pending = await roleProvider.getPendingRequest();
    setState(() {
      _pendingRequest = pending;
    });
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
            hint: 'As it appears on your license',
            icon: Icons.person_outline,
            validator:
                (value) =>
                    value?.isEmpty ?? true
                        ? 'Please enter your full name'
                        : null,
          ),
          SizedBox(height: 16),
          _buildTextField(
            controller: _licenseNumberController,
            label: 'License Number',
            hint: 'PRC/DOH License Number',
            icon: Icons.badge_outlined,
            validator:
                (value) =>
                    value?.isEmpty ?? true
                        ? 'Please enter your license number'
                        : null,
          ),
          SizedBox(height: 16),
          _buildTextField(
            controller: _institutionController,
            label: 'Institution/Hospital',
            hint: 'Your current workplace',
            icon: Icons.local_hospital_outlined,
            validator:
                (value) =>
                    value?.isEmpty ?? true
                        ? 'Please enter your institution'
                        : null,
          ),
          SizedBox(height: 16),
          _buildTextField(
            controller: _reasonController,
            label: 'Purpose of Access',
            hint: 'Describe how you will use the analytics data',
            icon: Icons.description_outlined,
            maxLines: 3,
            validator: (value) {
              if (value?.isEmpty ?? true) return 'Please provide a reason';
              if (value!.length < 30)
                return 'Please provide more detail (min 30 characters)';
              return null;
            },
          ),
        ],
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
          _buildRequirementItem('Valid healthcare professional license'),
          _buildRequirementItem('Institutional affiliation'),
          _buildRequirementItem('Clear purpose for data access'),
          _buildRequirementItem('Commitment to data privacy'),
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

  Widget _buildSubmitButton() {
    return Container(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _submitRequest,
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

    setState(() => _isLoading = true);

    try {
      final roleProvider = Provider.of<UserRoleProvider>(
        context,
        listen: false,
      );

      final success = await roleProvider.requestResearcherUpgrade(
        fullName: _fullNameController.text,
        licenseNumber: _licenseNumberController.text,
        institution: _institutionController.text,
        reason: _reasonController.text,
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
              'Your researcher request has been submitted successfully. You will be notified once reviewed.',
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
    _licenseNumberController.dispose();
    _institutionController.dispose();
    _reasonController.dispose();
    super.dispose();
  }
}
