import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import './testing/services/role_management_service.dart';
import './testing/models/user_model.dart';

class RoleManagementScreen extends StatefulWidget {
  @override
  _RoleManagementScreenState createState() => _RoleManagementScreenState();
}

class _RoleManagementScreenState extends State<RoleManagementScreen> {
  final RoleManagementService _roleService = RoleManagementService();
  final TextEditingController _phoneController = TextEditingController();
  String _selectedRole = 'researcher';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF0F2F5),
      appBar: AppBar(
        title: Text(
          'Role Management',
          style: GoogleFonts.workSans(
            color: Color(0xFF1C1E21),
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: Color(0xFF1C1E21)),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildUpgradeUserCard(),
            SizedBox(height: 20),
            _buildResearchersList(),
          ],
        ),
      ),
    );
  }

  Widget _buildUpgradeUserCard() {
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
            'Upgrade User Role',
            style: GoogleFonts.workSans(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1C1E21),
            ),
          ),
          SizedBox(height: 16),
          TextField(
            controller: _phoneController,
            decoration: InputDecoration(
              labelText: 'Phone Number',
              hintText: '+639123456789',
              prefixIcon: Icon(Icons.phone),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            keyboardType: TextInputType.phone,
          ),
          SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: _selectedRole,
            decoration: InputDecoration(
              labelText: 'New Role',
              prefixIcon: Icon(Icons.security),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            items: [
              DropdownMenuItem(value: 'basicUser', child: Text('Basic User')),
              DropdownMenuItem(
                value: 'researcher',
                child: Text('Healthcare Researcher'),
              ),
              DropdownMenuItem(value: 'admin', child: Text('Admin')),
            ],
            onChanged: (value) {
              setState(() {
                _selectedRole = value!;
              });
            },
          ),
          SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _upgradeUserRole,
              icon: Icon(Icons.upgrade),
              label: Text('Upgrade Role'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF1877F2),
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResearchersList() {
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
            'Current Researchers',
            style: GoogleFonts.workSans(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1C1E21),
            ),
          ),
          SizedBox(height: 16),
          StreamBuilder<List<UserModel>>(
            stream: _roleService.getResearchers(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }

              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Center(
                  child: Text(
                    'No researchers found',
                    style: GoogleFonts.workSans(color: Color(0xFF65676B)),
                  ),
                );
              }

              return ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  final user = snapshot.data![index];
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Color(0xFF1877F2).withOpacity(0.1),
                      child: Icon(Icons.person, color: Color(0xFF1877F2)),
                    ),
                    title: Text(
                      user.displayName ?? user.phoneNumber,
                      style: GoogleFonts.workSans(fontWeight: FontWeight.w500),
                    ),
                    subtitle: Text(
                      'Added: ${user.createdAt.toString().split(' ')[0]}',
                      style: GoogleFonts.workSans(
                        fontSize: 12,
                        color: Color(0xFF65676B),
                      ),
                    ),
                    trailing: Chip(
                      label: Text(
                        'Researcher',
                        style: GoogleFonts.workSans(
                          fontSize: 12,
                          color: Colors.white,
                        ),
                      ),
                      backgroundColor: Color(0xFF42B883),
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }

  void _upgradeUserRole() async {
    if (_phoneController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Please enter a phone number')));
      return;
    }

    bool success = await _roleService.upgradeUserRole(
      _phoneController.text,
      _selectedRole,
    );

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Role upgraded successfully'),
          backgroundColor: Color(0xFF42B883),
        ),
      );
      _phoneController.clear();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to upgrade role'),
          backgroundColor: Color(0xFFFA383E),
        ),
      );
    }
  }
}
