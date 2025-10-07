import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import './components/providers/enhanced_analytics_provider.dart';
import 'package:projecho/screens/analytics/components/providers/user_role_provider.dart';
import './researcher_request_screen.dart';

class GeneralBasicDashboard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF0F2F5),
      body: SafeArea(
        child: Consumer2<EnhancedAnalyticsProvider, UserRoleProvider>(
          builder: (context, analyticsProvider, roleProvider, child) {
            final insights = analyticsProvider.generalInsights;

            if (analyticsProvider.isLoading) {
              return _buildLoadingState();
            }

            if (insights == null) {
              return _buildEmptyState(context, analyticsProvider);
            }

            return CustomScrollView(
              slivers: [
                // App Bar with role-specific title
                _buildAppBar(context, roleProvider, analyticsProvider),

                // Content
                SliverPadding(
                  padding: EdgeInsets.all(16),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      // Show upgrade card for infoSeeker users
                      if (roleProvider.isInfoSeeker) ...[
                        _buildUpgradeToResearcherCard(context),
                        SizedBox(height: 16),
                      ],

                      _buildSupportiveMessageCard(
                        insights.supportiveMessage,
                        roleProvider,
                      ),
                      SizedBox(height: 16),
                      _buildCommunityOverviewCard(insights),
                      SizedBox(height: 16),
                      _buildPopularTreatmentHubsCard(
                        insights.popularTreatmentHubs,
                      ),
                      SizedBox(height: 16),
                      _buildHealthTipsCard(insights.generalHealthTips),
                      SizedBox(height: 16),
                      // _buildResourcesGrid(context, insights.availableResources),
                      // SizedBox(height: 80), // Space for bottom navigation
                    ]),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildAppBar(
    BuildContext context,
    UserRoleProvider roleProvider,
    EnhancedAnalyticsProvider analyticsProvider,
  ) {
    return SliverAppBar(
      floating: true,
      backgroundColor: Colors.white,
      elevation: 0,
      automaticallyImplyLeading: false,
      expandedHeight: 120,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF1877F2).withOpacity(0.1), Colors.white],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getTitle(roleProvider),
                  style: GoogleFonts.workSans(
                    color: Color(0xFF1C1E21),
                    fontWeight: FontWeight.w600,
                    fontSize: 28,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  _getSubtitle(roleProvider),
                  style: GoogleFonts.workSans(
                    color: Color(0xFF65676B),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.refresh, color: Color(0xFF65676B)),
          onPressed: () => analyticsProvider.fetchData(),
        ),
      ],
    );
  }

  String _getTitle(UserRoleProvider roleProvider) {
    if (roleProvider.isPLHIV) {
      return 'Your Community';
    } else {
      return 'Community Insights';
    }
  }

  String _getSubtitle(UserRoleProvider roleProvider) {
    if (roleProvider.isPLHIV) {
      return 'You\'re part of something bigger';
    } else {
      return 'Together, we are stronger';
    }
  }

  Widget _buildUpgradeToResearcherCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF9C27B0), Color(0xFFAB47BC)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Color(0xFF9C27B0).withOpacity(0.3),
            blurRadius: 12,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  FontAwesomeIcons.userDoctor,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              Spacer(),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Icon(Icons.trending_up, color: Colors.white, size: 16),
                    SizedBox(width: 4),
                    Text(
                      'Upgrade',
                      style: GoogleFonts.workSans(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          Text(
            'Are you a healthcare professional?',
            style: GoogleFonts.workSans(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
              height: 1.3,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Access advanced analytics and contribute to research by becoming a verified researcher.',
            style: GoogleFonts.workSans(
              color: Colors.white.withOpacity(0.9),
              fontSize: 14,
              height: 1.4,
            ),
          ),
          SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ResearcherRequestScreen(),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Color(0xFF9C27B0),
                padding: EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.verified_user_outlined, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Become a Researcher',
                    style: GoogleFonts.workSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF1877F2)),
          ),
          SizedBox(height: 20),
          Text(
            'Loading community insights...',
            style: GoogleFonts.workSans(fontSize: 16, color: Color(0xFF65676B)),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(
    BuildContext context,
    EnhancedAnalyticsProvider provider,
  ) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.insights_outlined, size: 80, color: Color(0xFFDADDE1)),
          SizedBox(height: 20),
          Text(
            'No insights available',
            style: GoogleFonts.workSans(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1C1E21),
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Check back later for community updates',
            style: GoogleFonts.workSans(fontSize: 14, color: Color(0xFF65676B)),
          ),
          SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => provider.fetchData(),
            icon: Icon(Icons.refresh),
            label: Text('Refresh'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF1877F2),
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSupportiveMessageCard(
    String message,
    UserRoleProvider roleProvider,
  ) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF1877F2), Color(0xFF42A5F5)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Color(0xFF1877F2).withOpacity(0.3),
            blurRadius: 12,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  FontAwesomeIcons.heartPulse,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              Spacer(),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Icon(Icons.auto_awesome, color: Colors.white, size: 16),
                    SizedBox(width: 4),
                    Text(
                      roleProvider.isPLHIV ? 'Just for You' : 'Message of Hope',
                      style: GoogleFonts.workSans(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          Text(
            message,
            style: GoogleFonts.workSans(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w500,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommunityOverviewCard(GeneralInsights insights) {
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
              Icon(Icons.groups, color: Color(0xFF1877F2), size: 24),
              SizedBox(width: 8),
              Text(
                'Our Community',
                style: GoogleFonts.workSans(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1C1E21),
                ),
              ),
            ],
          ),
          SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  icon: Icons.people,
                  value: insights.totalCommunityMembers.toString(),
                  label: 'Community Members',
                  color: Color(0xFF1877F2),
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  icon: Icons.trending_up,
                  value: '+${insights.communityGrowth.toStringAsFixed(1)}%',
                  label: 'Monthly Growth',
                  color: Color(0xFF42B883),
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Color(0xFF42B883).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: Color(0xFF42B883), size: 20),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Our community continues to grow, providing support and resources for everyone.',
                    style: GoogleFonts.workSans(
                      fontSize: 12,
                      color: Color(0xFF1C1E21),
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.roboto(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.workSans(fontSize: 12, color: Color(0xFF65676B)),
          ),
        ],
      ),
    );
  }

  Widget _buildPopularTreatmentHubsCard(List<String> hubs) {
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
              Icon(Icons.local_hospital, color: Color(0xFF9C27B0), size: 24),
              SizedBox(width: 8),
              Text(
                'Popular Treatment Centers',
                style: GoogleFonts.workSans(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1C1E21),
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          ...hubs.asMap().entries.map((entry) {
            int index = entry.key;
            String hub = entry.value;
            return Container(
              margin: EdgeInsets.only(bottom: 12),
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFF9C27B0).withOpacity(0.1),
                    Color(0xFF9C27B0).withOpacity(0.05),
                  ],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Color(0xFF9C27B0).withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: Color(0xFF9C27B0).withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '${index + 1}',
                        style: GoogleFonts.roboto(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF9C27B0),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      hub,
                      style: GoogleFonts.workSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF1C1E21),
                      ),
                    ),
                  ),
                  Icon(Icons.star, color: Color(0xFFFFA726), size: 20),
                ],
              ),
            );
          }).toList(),
          SizedBox(height: 8),
          Text(
            'These centers are frequently chosen by our community members',
            style: GoogleFonts.workSans(
              fontSize: 12,
              color: Color(0xFF65676B),
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHealthTipsCard(List<String> tips) {
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
              Icon(
                FontAwesomeIcons.lightbulb,
                color: Color(0xFFFFA726),
                size: 20,
              ),
              SizedBox(width: 8),
              Text(
                'Health & Wellness Tips',
                style: GoogleFonts.workSans(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1C1E21),
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          ...tips
              .map(
                (tip) => Container(
                  margin: EdgeInsets.only(bottom: 12),
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Color(0xFFF0F2F5),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Color(0xFFDADDE1), width: 1),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        margin: EdgeInsets.only(top: 4),
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: Color(0xFF42B883),
                          shape: BoxShape.circle,
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          tip,
                          style: GoogleFonts.workSans(
                            fontSize: 14,
                            color: Color(0xFF1C1E21),
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              )
              .toList(),
        ],
      ),
    );
  }

  // Widget _buildResourcesGrid(
  //   BuildContext context,
  //   List<Map<String, String>> resources,
  // ) {
  // return Column(
  //   crossAxisAlignment: CrossAxisAlignment.start,
  //   children: [
  //     Padding(
  //       padding: EdgeInsets.only(bottom: 12),
  //       child: Text(
  //         'Available Resources',
  //         style: GoogleFonts.workSans(
  //           fontSize: 20,
  //           fontWeight: FontWeight.w600,
  //           color: Color(0xFF1C1E21),
  //         ),
  //       ),
  //     ),
  //     // GridView.builder(
  //     //   shrinkWrap: true,
  //     //   physics: NeverScrollableScrollPhysics(),
  //     //   gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
  //     //     crossAxisCount: 2,
  //     //     crossAxisSpacing: 10,
  //     //     mainAxisSpacing: 12,
  //     //     childAspectRatio: 1.2,
  //     //   ),
  //     //   itemCount: resources.length,
  //     //   itemBuilder: (context, index) {
  //     //     final resource = resources[index];
  //     //     return _buildResourceCard(
  //     //       context,
  //     //       title: resource['title'] ?? '',
  //     //       description: resource['description'] ?? '',
  //     //       iconName: resource['icon'] ?? 'help',
  //     //     );
  //     //   },
  //     // ),
  //   ],
  // );
}

Widget _buildResourceCard(
  BuildContext context, {
  required String title,
  required String description,
  required String iconName,
}) {
  IconData icon = _getIconFromName(iconName);
  Color color = _getColorForIcon(iconName);

  return InkWell(
    onTap: () {
      _showResourceDetails(context, title, description);
    },
    borderRadius: BorderRadius.circular(16),
    child: Container(
      padding: EdgeInsets.all(16),
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
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.workSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1C1E21),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 4),
              Text(
                description,
                style: GoogleFonts.workSans(
                  fontSize: 11,
                  color: Color(0xFF65676B),
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ],
      ),
    ),
  );
}

IconData _getIconFromName(String name) {
  switch (name) {
    case 'hospital':
      return Icons.local_hospital;
    case 'group':
      return Icons.groups;
    case 'book':
      return Icons.menu_book;
    case 'phone':
      return Icons.phone_in_talk;
    default:
      return Icons.help_outline;
  }
}

Color _getColorForIcon(String name) {
  switch (name) {
    case 'hospital':
      return Color(0xFF1877F2);
    case 'group':
      return Color(0xFF42B883);
    case 'book':
      return Color(0xFF9C27B0);
    case 'phone':
      return Color(0xFFFFA726);
    default:
      return Color(0xFF65676B);
  }
}

void _showResourceDetails(
  BuildContext context,
  String title,
  String description,
) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    builder:
        (context) => Container(
          padding: EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: Color(0xFFDADDE1),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Text(
                title,
                style: GoogleFonts.workSans(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1C1E21),
                ),
              ),
              SizedBox(height: 12),
              Text(
                description,
                style: GoogleFonts.workSans(
                  fontSize: 14,
                  color: Color(0xFF65676B),
                  height: 1.5,
                ),
              ),
              SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        // Add navigation or action here
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF1877F2),
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text('Learn More'),
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Color(0xFF65676B),
                        padding: EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        side: BorderSide(color: Color(0xFFDADDE1)),
                      ),
                      child: Text('Close'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
  );
}
