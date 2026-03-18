import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pariba/data/repositories/subscription_repository.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../core/services/firebase_messaging_service.dart';
import '../../../core/services/payment_service.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/auth/auth_state.dart';
import '../../blocs/group/group_bloc.dart';
import '../../blocs/group/group_event.dart';
import '../../blocs/group/group_state.dart';
import '../groups/groups_list_page.dart';
import '../groups/group_details_page.dart';
import '../groups/create_group_page.dart';
import '../groups/join_group_page.dart';
import '../profile/enhanced_profile_page.dart';
import '../notifications/enhanced_notifications_page.dart';
import '../payments/my_payments_history_page.dart';
import '../payments/upcoming_payments_page.dart';
import '../../blocs/notification/notification_bloc.dart';
import '../../blocs/notification/notification_event.dart';
import '../../blocs/notification/notification_state.dart';
import '../../widgets/home_advertisement_section.dart';
import '../../../data/datasources/remote/advertisement_remote_datasource.dart';
import '../../../di/injection.dart' as di;
import '../premium/premiumscreen.dart';

/// Improved Dashboard Page with Enhanced UI
class ImprovedDashboardPage extends StatefulWidget {
  const ImprovedDashboardPage({super.key});

  @override
  State<ImprovedDashboardPage> createState() => _ImprovedDashboardPageState();
}

class _ImprovedDashboardPageState extends State<ImprovedDashboardPage>
    with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;
  int _pendingPaymentsCount = 0;
  final _paymentService = di.sl<PaymentService>();
  late AnimationController _animationController;
  late List<Animation<double>> _fadeAnimations;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadInitialData();
    _setupNotificationListener();
    _loadPendingPaymentsCount();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnimations = List.generate(5, (index) {
      return Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _animationController,
          curve: Interval(
            index * 0.15,
            0.8 + (index * 0.05),
            curve: Curves.easeOut,
          ),
        ),
      );
    });

    _animationController.forward();
  }

  void _loadInitialData() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<GroupBloc>().add(const LoadGroupsEvent());
      context.read<NotificationBloc>().add(const LoadNotificationsEvent());
    });
  }

  Future<void> _loadPendingPaymentsCount() async {
    final count = await _paymentService.countMyPendingPayments();
    if (mounted) {
      setState(() => _pendingPaymentsCount = count);
    }
  }

  void _setupNotificationListener() {
    final firebaseService = di.sl<FirebaseMessagingService>();
    firebaseService.setOnNewNotificationCallback(() {
      if (mounted) {
        context.read<NotificationBloc>().add(const RefreshNotificationsEvent());
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildBody(),
      bottomNavigationBar: _buildBottomNav(),
      floatingActionButton: _selectedIndex == 1 ? _buildFAB() : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Widget _buildBody() {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      transitionBuilder: (Widget child, Animation<double> animation) {
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position:
                Tween<Offset>(
                  begin: const Offset(0.05, 0),
                  end: Offset.zero,
                ).animate(
                  CurvedAnimation(parent: animation, curve: Curves.easeOut),
                ),
            child: child,
          ),
        );
      },
      child: _getPageForIndex(_selectedIndex),
    );
  }

  Widget _getPageForIndex(int index) {
    switch (index) {
      case 0:
        return _buildDashboard();
      case 1:
        return const GroupsListPage();
      case 2:
        return FutureBuilder<bool>(
          key: const ValueKey('notifications_page'),
          future: _isPremiumUser(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(
                child: CircularProgressIndicator(strokeWidth: 2),
              );
            }
            final isPremium = snapshot.data!;
            return isPremium
                ? const EnhancedNotificationsPage()
                : const PremiumScreen();
          },
        );
      case 3:
        return const EnhancedProfilePage();
      default:
        return _buildDashboard();
    }
  }

  Future<bool> _isPremiumUser() async {
    final repository = di.sl<SubscriptionRepository>();
    final result = await repository.getActiveSubscription();

    return result.fold(
      (failure) => false,
      (subscription) => subscription != null && subscription.status == 'ACTIVE',
    );
  }

  Widget _buildDashboard() {
    return CustomScrollView(
      slivers: [
        _buildEnhancedAppBar(),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              const SizedBox(height: 16),
              _buildWelcomeCard(),
              const SizedBox(height: 24),
              _buildQuickStatsSection(),
              const SizedBox(height: 24),
              _buildQuickActionsSection(),
              const SizedBox(height: 24),
              _buildRecentActivitySection(),
              _buildAdvertisementSection(),
              const SizedBox(height: 100),
            ]),
          ),
        ),
      ],
    );
  }

  Widget _buildEnhancedAppBar() {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        String userName = 'Utilisateur';
        if (state is Authenticated) {
          userName = state.person.prenom;
        }

        return SliverAppBar(
          expandedHeight: 50,
          floating: false,
          pinned: true,
          backgroundColor: AppColors.primary,
          flexibleSpace: FlexibleSpaceBar(
            title: Text(
              'Bonjour, $userName 👋',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            background: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.primary,
                    AppColors.primary.withOpacity(0.8),
                  ],
                ),
              ),
            ),
          ),
          actions: [
            Container(
              margin: const EdgeInsets.only(right: 8),
              child: IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.search,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                onPressed: () => _showSearchDialog(),
              ),
            ),
            BlocBuilder<NotificationBloc, NotificationState>(
              builder: (context, notifState) {
                int unreadCount = 0;
                if (notifState is NotificationLoaded) {
                  unreadCount = notifState.unreadCount;
                }

                return Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(right: 16),
                      child: IconButton(
                        icon: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            unreadCount > 0
                                ? Icons.notifications_active
                                : Icons.notifications_outlined,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const EnhancedNotificationsPage(),
                            ),
                          );
                        },
                      ),
                    ),
                    if (unreadCount > 0)
                      Positioned(
                        right: 12,
                        top: 8,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: AppColors.error,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 20,
                            minHeight: 20,
                          ),
                          child: Text(
                            unreadCount > 9 ? '9+' : '$unreadCount',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildWelcomeCard() {
    return FadeTransition(
      opacity: _fadeAnimations[0],
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.primary, AppColors.secondary],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Gérez vos tontines',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.calendar_today,
                          color: Colors.white,
                          size: 14,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          DateFormatter.formatDate(DateTime.now()),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.account_balance_wallet,
                color: Colors.white,
                size: 40,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickStatsSection() {
    return BlocBuilder<GroupBloc, GroupState>(
      builder: (context, state) {
        int totalGroups = 0;
        int activeGroups = 0;
        double totalAmount = 0;

        if (state is GroupsLoaded) {
          totalGroups = state.groups.length;
          activeGroups = state.groups.length;
          totalAmount = state.groups.fold(0, (sum, g) => sum + g.montant);
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 4, bottom: 2),
              child: Text(
                'Vue d\'ensemble',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.6,
              children: [
                _buildAnimatedStatCard(
                  index: 1,
                  title: 'Groupes',
                  value: totalGroups.toString(),
                  icon: Icons.group,
                  color: AppColors.primary,
                  subtitle: 'Total',
                  onTap: () => _navigateToFirstGroup(state),
                ),
                _buildAnimatedStatCard(
                  index: 2,
                  title: 'Actifs',
                  value: activeGroups.toString(),
                  icon: Icons.check_circle,
                  color: AppColors.success,
                  subtitle: 'En cours',
                ),
                _buildAnimatedStatCard(
                  index: 3,
                  title: 'Montant',
                  value: CurrencyFormatter.formatCompact(totalAmount),
                  icon: Icons.account_balance_wallet,
                  color: AppColors.secondary,
                  subtitle: 'Total cotisations',
                ),
                _buildAnimatedStatCard(
                  index: 4,
                  title: 'À venir',
                  value: _pendingPaymentsCount.toString(),
                  icon: Icons.pending_actions,
                  color: AppColors.warning,
                  subtitle: 'Paiements',
                  onTap: () => _navigateToUpcomingPayments(),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildAnimatedStatCard({
    required int index,
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required String subtitle,
    VoidCallback? onTap,
  }) {
    return FadeTransition(
      opacity: _fadeAnimations[index],
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withOpacity(0.2)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(icon, color: color, size: 16),
                  ),
                  const Spacer(),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActionsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            'Actions rapides',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        Row(
          children: [
            Expanded(
              child: _buildAnimatedActionCard(
                index: 0,
                label: 'Créer',
                icon: Icons.add_circle,
                color: AppColors.primary,
                onTap: () => _navigateToCreateGroup(),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildAnimatedActionCard(
                index: 0,
                label: 'Rejoindre',
                icon: Icons.group_add,
                color: AppColors.secondary,
                onTap: () => _navigateToJoinGroup(),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildAnimatedActionCard(
                index: 0,
                label: 'Paiements',
                icon: Icons.payment,
                color: AppColors.success,
                onTap: () => _navigateToPayments(),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAnimatedActionCard({
    required int index,
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return FadeTransition(
      opacity: _fadeAnimations[index],
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withOpacity(0.2)),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecentActivitySection() {
    return BlocBuilder<GroupBloc, GroupState>(
      builder: (context, state) {
        if (state is GroupsLoaded && state.groups.isNotEmpty) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 4),
                    child: Text(
                      'Mes groupes',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () => setState(() => _selectedIndex = 1),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.primary,
                    ),
                    child: Row(
                      children: const [
                        Text('Voir tout'),
                        SizedBox(width: 4),
                        Icon(Icons.arrow_forward, size: 16),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ...state.groups
                  .take(3)
                  .map(
                    (group) => FadeTransition(
                      opacity: _fadeAnimations[4],
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 12),
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
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(16),
                          leading: Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  AppColors.primary.withOpacity(0.1),
                                  AppColors.secondary.withOpacity(0.1),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(Icons.group, color: AppColors.primary),
                          ),
                          title: Text(
                            group.nom,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              '${CurrencyFormatter.format(group.montant)} • ${group.frequency}',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                          trailing: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.success.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: const BoxDecoration(
                                    color: AppColors.success,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                const Text(
                                  'Actif',
                                  style: TextStyle(
                                    color: AppColors.success,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    GroupDetailsPage(group: group),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
            ],
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildAdvertisementSection() {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is Authenticated && state.person.role == 'USER') {
          final hasActiveSubscription = false;
          final adDataSource = di.sl<AdvertisementRemoteDataSource>();

          return Padding(
            padding: const EdgeInsets.only(top: 24),
            child: HomeAdvertisementSection(
              hasActiveSubscription: hasActiveSubscription,
              advertisementDataSource: adDataSource,
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textSecondary,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            activeIcon: Icon(Icons.dashboard),
            label: 'Accueil',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.group_outlined),
            activeIcon: Icon(Icons.group),
            label: 'Groupes',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              _selectedIndex == 2
                  ? Icons.diamond_outlined
                  : Icons.notifications_outlined,
            ),
            activeIcon: Icon(
              _selectedIndex == 2 ? Icons.diamond : Icons.notifications,
            ),
            label: 'Premium',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
      ),
    );
  }

  Widget _buildFAB() {
    return FloatingActionButton.extended(
      onPressed: () => _navigateToCreateGroup(),
      icon: const Icon(Icons.add),
      label: const Text('Nouveau groupe'),
      backgroundColor: AppColors.primary,
      elevation: 4,
    );
  }

  // Navigation methods
  void _navigateToFirstGroup(GroupState state) {
    if (state is GroupsLoaded && state.groups.isNotEmpty) {
      final firstGroup = state.groups.first;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => GroupDetailsPage(group: firstGroup),
        ),
      );
    } else {
      _showNoGroupSnackBar();
    }
  }

  void _navigateToUpcomingPayments() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const UpcomingPaymentsPage()),
    );
  }

  void _navigateToCreateGroup() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CreateGroupPage()),
    );
  }

  void _navigateToJoinGroup() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const JoinGroupPage()),
    );
  }

  void _navigateToPayments() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const MyPaymentsHistoryPage()),
    );
  }

  void _showSearchDialog() {
    showSearch(context: context, delegate: CustomSearchDelegate());
  }

  void _showNoGroupSnackBar() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Aucun groupe disponible'),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}

/// Custom Search Delegate for enhanced search functionality
class CustomSearchDelegate extends SearchDelegate {
  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    // Implement search results
    return Center(child: Text('Résultats pour : $query'));
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    // Implement search suggestions
    return Center(child: Text('Rechercher : $query'));
  }
}
