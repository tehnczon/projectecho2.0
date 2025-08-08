// lib/models/contact_info.dart - ENHANCED VERSION
class ContactInfo {
  final String? phone;
  final String? email;
  final String? facebook;
  final String? website;
  final String address;

  const ContactInfo({
    this.phone,
    this.email,
    this.facebook,
    this.website,
    required this.address,
  });

  factory ContactInfo.fromMap(Map<String, dynamic> map) {
    return ContactInfo(
      phone: map['phone'] as String?,
      email: map['email'] as String?,
      facebook: map['facebook'] as String?,
      website: map['website'] as String?,
      address: map['address'] as String? ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'phone': phone,
      'email': email,
      'facebook': facebook,
      'website': website,
      'address': address,
    };
  }

  // Check if has any contact method
  bool get hasAnyContact => phone != null || email != null || facebook != null;

  // Check specific contact types
  bool get hasPhone => phone != null && phone!.isNotEmpty;
  bool get hasEmail => email != null && email!.isNotEmpty;
  bool get hasFacebook => facebook != null && facebook!.isNotEmpty;
  bool get hasWebsite => website != null && website!.isNotEmpty;
}
