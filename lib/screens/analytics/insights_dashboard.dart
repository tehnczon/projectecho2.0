// lib/screens/analytics/insights_dashboard.dart
class InsightsDashboard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<UserRoleProvider>(
      builder: (context, roleProvider, child) {
        // Initialize analytics on first build
        Provider.of<EnhancedAnalyticsProvider>(
          context,
          listen: false,
        ).initialize();

        // Route based on role
        if (roleProvider.isResearcher || roleProvider.isAdmin) {
          return ResearcherDashboard();
        } else {
          return GeneralBasicDashboard();
        }
      },
    );
  }
}
