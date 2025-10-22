import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class CreateContentScreen extends StatefulWidget {
  const CreateContentScreen({super.key});

  @override
  State<CreateContentScreen> createState() => _CreateContentScreenState();
}

class _CreateContentScreenState extends State<CreateContentScreen> {
  final TextEditingController _contentController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  List<File> _selectedImages = [];
  bool _isLoading = false;

  // Target Audience
  Set<String> _targetUserTypes = {}; // 'infoseeker', 'plhiv', 'both'

  // Demographic Filters
  Set<String> _targetAgeRanges = {};
  Set<String> _targetGenders = {};
  Set<String> _targetCivilStatus = {};
  Set<String> _targetLocations = {};
  Set<String> _targetEducationLevels = {};

  // PLHIV-specific filters
  bool _includeYouth = false;
  bool _includeMSM = false;
  bool _includeMSW = false;
  bool _includeWSW = false;
  bool _includePregnant = false;
  bool _includeOFW = false;

  // Content metadata
  String _contentCategory = 'General';
  List<String> _tags = [];
  final TextEditingController _tagController = TextEditingController();

  @override
  void dispose() {
    _contentController.dispose();
    _titleController.dispose();
    _tagController.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    try {
      final List<XFile> images = await _picker.pickMultiImage(
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (images.isNotEmpty && images.length + _selectedImages.length <= 5) {
        setState(() {
          _selectedImages.addAll(images.map((xfile) => File(xfile.path)));
        });
      } else if (images.length + _selectedImages.length > 5) {
        _showSnackBar('Maximum 5 images allowed', isError: true);
      }
    } catch (e) {
      _showSnackBar('Error picking images: $e', isError: true);
    }
  }

  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  Future<void> _publishContent() async {
    if (_contentController.text.trim().isEmpty) {
      _showSnackBar('Please enter some content', isError: true);
      return;
    }

    if (_targetUserTypes.isEmpty) {
      _showSnackBar('Please select target audience', isError: true);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('User not authenticated');

      // Build targeting criteria
      Map<String, dynamic> targetingCriteria = {
        'userTypes': _targetUserTypes.toList(),
        'ageRanges': _targetAgeRanges.toList(),
        'genderIdentities': _targetGenders.toList(),
        'civilStatuses': _targetCivilStatus.toList(),
        'locations': _targetLocations.toList(),
        'educationLevels': _targetEducationLevels.toList(),
      };

      // Add PLHIV-specific filters if targeting PLHIV users
      if (_targetUserTypes.contains('plhiv') ||
          _targetUserTypes.contains('both')) {
        targetingCriteria['plhivFilters'] = {
          'includeYouth': _includeYouth,
          'includeMSM': _includeMSM,
          'includeMSW': _includeMSW,
          'includeWSW': _includeWSW,
          'includePregnant': _includePregnant,
          'includeOFW': _includeOFW,
        };
      }

      // Create content document
      final contentData = {
        'title': _titleController.text.trim(),
        'content': _contentController.text.trim(),
        'category': _contentCategory,
        'tags': _tags,
        'authorId': user.uid,
        'authorName': user.displayName ?? 'Anonymous',
        'targetingCriteria': targetingCriteria,
        'imageCount': _selectedImages.length,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'likes': 0,
        'comments': 0,
        'shares': 0,
        'views': 0,
        'isActive': true,
      };

      // Save to Firestore
      final docRef = await FirebaseFirestore.instance
          .collection('contents')
          .add(contentData);

      // TODO: Upload images to Firebase Storage and update document with URLs
      // For now, we'll just show success

      _showSnackBar('Content published successfully!');
      Navigator.pop(context);
    } catch (e) {
      _showSnackBar('Error publishing content: $e', isError: true);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Create Content',
          style: GoogleFonts.poppins(
            color: Colors.black87,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _publishContent,
            child:
                _isLoading
                    ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                    : Text(
                      'Publish',
                      style: GoogleFonts.poppins(
                        color: const Color(0xFF6C63FF),
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title Input
            _buildCard(
              child: TextField(
                controller: _titleController,
                decoration: InputDecoration(
                  hintText: 'Enter a catchy title...',
                  hintStyle: GoogleFonts.poppins(color: Colors.grey),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.all(16),
                ),
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
                maxLength: 100,
              ),
            ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1, end: 0),

            const SizedBox(height: 16),

            // Content Input
            _buildCard(
                  child: TextField(
                    controller: _contentController,
                    decoration: InputDecoration(
                      hintText: 'Share your thoughts, tips, or information...',
                      hintStyle: GoogleFonts.poppins(color: Colors.grey),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.all(16),
                    ),
                    style: GoogleFonts.poppins(fontSize: 15),
                    maxLines: 8,
                    maxLength: 5000,
                  ),
                )
                .animate()
                .fadeIn(duration: 400.ms, delay: 100.ms)
                .slideY(begin: 0.1, end: 0),

            const SizedBox(height: 16),

            // Image Picker
            _buildCard(
              child: Column(
                children: [
                  InkWell(
                    onTap: _pickImages,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.add_photo_alternate,
                            color: Color(0xFF6C63FF),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Add Photos (${_selectedImages.length}/5)',
                            style: GoogleFonts.poppins(
                              color: const Color(0xFF6C63FF),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (_selectedImages.isNotEmpty)
                    SizedBox(
                      height: 120,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _selectedImages.length,
                        itemBuilder: (context, index) {
                          return Stack(
                            children: [
                              Container(
                                margin: const EdgeInsets.only(right: 8, top: 8),
                                width: 120,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  image: DecorationImage(
                                    image: FileImage(_selectedImages[index]),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              Positioned(
                                top: 0,
                                right: 0,
                                child: IconButton(
                                  icon: const Icon(
                                    Icons.cancel,
                                    color: Colors.red,
                                  ),
                                  onPressed: () => _removeImage(index),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                ],
              ),
            ).animate().fadeIn(duration: 400.ms, delay: 200.ms),

            const SizedBox(height: 24),

            // Target Audience Section
            _buildSectionTitle('Target Audience'),
            const SizedBox(height: 12),
            _buildCard(
              child: Column(
                children: [
                  _buildCheckboxTile(
                    'Info Seekers',
                    'Share with users seeking HIV information',
                    _targetUserTypes.contains('infoseeker'),
                    (value) {
                      setState(() {
                        if (value!) {
                          _targetUserTypes.add('infoseeker');
                          _targetUserTypes.remove('both');
                        } else {
                          _targetUserTypes.remove('infoseeker');
                        }
                      });
                    },
                  ),
                  const Divider(height: 1),
                  _buildCheckboxTile(
                    'PLHIV Users',
                    'Share with people living with HIV',
                    _targetUserTypes.contains('plhiv'),
                    (value) {
                      setState(() {
                        if (value!) {
                          _targetUserTypes.add('plhiv');
                          _targetUserTypes.remove('both');
                        } else {
                          _targetUserTypes.remove('plhiv');
                        }
                      });
                    },
                  ),
                  const Divider(height: 1),
                  _buildCheckboxTile(
                    'Both',
                    'Share with all users',
                    _targetUserTypes.contains('both'),
                    (value) {
                      setState(() {
                        if (value!) {
                          _targetUserTypes.clear();
                          _targetUserTypes.add('both');
                        } else {
                          _targetUserTypes.remove('both');
                        }
                      });
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Demographic Filters
            _buildSectionTitle('Refine Your Audience (Optional)'),
            const SizedBox(height: 12),

            // Age Range
            _buildFilterCard('Age Range', [
              '18-24',
              '25-34',
              '35-44',
              '45-54',
              '55+',
            ], _targetAgeRanges),

            // Gender Identity
            _buildFilterCard('Gender Identity', [
              'Male',
              'Female',
              'Non-binary',
              'Prefer not to say',
            ], _targetGenders),

            // Civil Status
            _buildFilterCard('Civil Status', [
              'Single',
              'Married',
              'Domestic Partner',
              'Divorced',
              'Widowed',
            ], _targetCivilStatus),

            // Education Level
            _buildFilterCard('Education Level', [
              'Elementary',
              'High School',
              'College',
              'Postgraduate',
            ], _targetEducationLevels),

            // PLHIV-Specific Filters
            if (_targetUserTypes.contains('plhiv') ||
                _targetUserTypes.contains('both'))
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 24),
                  _buildSectionTitle('PLHIV-Specific Filters'),
                  const SizedBox(height: 12),
                  _buildCard(
                    child: Column(
                      children: [
                        _buildSwitchTile(
                          'Youth (15-24 years)',
                          _includeYouth,
                          (v) => setState(() => _includeYouth = v),
                        ),
                        _buildSwitchTile(
                          'Men who have Sex with Men (MSM)',
                          _includeMSM,
                          (v) => setState(() => _includeMSM = v),
                        ),
                        _buildSwitchTile(
                          'Men who have Sex with Women (MSW)',
                          _includeMSW,
                          (v) => setState(() => _includeMSW = v),
                        ),
                        _buildSwitchTile(
                          'Women who have Sex with Women (WSW)',
                          _includeWSW,
                          (v) => setState(() => _includeWSW = v),
                        ),
                        _buildSwitchTile(
                          'Pregnant Individuals',
                          _includePregnant,
                          (v) => setState(() => _includePregnant = v),
                        ),
                        _buildSwitchTile(
                          'Overseas Filipino Workers',
                          _includeOFW,
                          (v) => setState(() => _includeOFW = v),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

            const SizedBox(height: 24),

            // Category & Tags
            _buildSectionTitle('Category & Tags'),
            const SizedBox(height: 12),
            _buildCard(
              child: Column(
                children: [
                  DropdownButtonFormField<String>(
                    value: _contentCategory,
                    decoration: const InputDecoration(
                      labelText: 'Category',
                      border: OutlineInputBorder(),
                    ),
                    items:
                        [
                              'General',
                              'Health Tips',
                              'Mental Health',
                              'Treatment',
                              'Prevention',
                              'Support',
                              'News',
                              'Personal Story',
                            ]
                            .map(
                              (cat) => DropdownMenuItem(
                                value: cat,
                                child: Text(cat),
                              ),
                            )
                            .toList(),
                    onChanged:
                        (value) => setState(() => _contentCategory = value!),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _tagController,
                    decoration: InputDecoration(
                      labelText: 'Add Tags',
                      hintText: 'Press enter to add',
                      border: const OutlineInputBorder(),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.add),
                        onPressed: () {
                          if (_tagController.text.trim().isNotEmpty) {
                            setState(() {
                              _tags.add(_tagController.text.trim());
                              _tagController.clear();
                            });
                          }
                        },
                      ),
                    ),
                    onSubmitted: (value) {
                      if (value.trim().isNotEmpty) {
                        setState(() {
                          _tags.add(value.trim());
                          _tagController.clear();
                        });
                      }
                    },
                  ),
                  if (_tags.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children:
                            _tags.map((tag) {
                              return Chip(
                                label: Text(tag),
                                deleteIcon: const Icon(Icons.close, size: 18),
                                onDeleted:
                                    () => setState(() => _tags.remove(tag)),
                              );
                            }).toList(),
                      ),
                    ),
                ],
              ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildCard({required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.poppins(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: Colors.black87,
      ),
    );
  }

  Widget _buildCheckboxTile(
    String title,
    String subtitle,
    bool value,
    Function(bool?) onChanged,
  ) {
    return CheckboxListTile(
      title: Text(
        title,
        style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
      ),
      subtitle: Text(
        subtitle,
        style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey),
      ),
      value: value,
      onChanged: onChanged,
      activeColor: const Color(0xFF6C63FF),
    );
  }

  Widget _buildSwitchTile(String title, bool value, Function(bool) onChanged) {
    return SwitchListTile(
      title: Text(title, style: GoogleFonts.poppins(fontSize: 14)),
      value: value,
      onChanged: onChanged,
      activeColor: const Color(0xFF6C63FF),
    );
  }

  Widget _buildFilterCard(
    String title,
    List<String> options,
    Set<String> selectedValues,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 12),
        Text(title, style: GoogleFonts.poppins(fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children:
              options.map((option) {
                final isSelected = selectedValues.contains(option);
                return FilterChip(
                  label: Text(option),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        selectedValues.add(option);
                      } else {
                        selectedValues.remove(option);
                      }
                    });
                  },
                  selectedColor: const Color(0xFF6C63FF).withOpacity(0.2),
                  checkmarkColor: const Color(0xFF6C63FF),
                );
              }).toList(),
        ),
      ],
    );
  }
}
