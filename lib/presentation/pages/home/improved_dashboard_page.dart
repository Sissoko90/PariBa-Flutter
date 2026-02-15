import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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

/// Improved Dashboard Page
class ImprovedDashboardPage extends StatefulWidget {
  const ImprovedDashboardPage({super.key});

  @override
  State<ImprovedDashboardPage> createState() => _ImprovedDashboardPageState();
}

class _ImprovedDashboardPageState extends State<ImprovedDashboardPage> {
  int _selectedIndex = 0;
  int _pendingPaymentsCount = 0;
  final _paymentService = di.sl<PaymentService>();

  @override
  void initState() {
    super.initState();
    // Charger les données après la construction du widget
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<GroupBloc>().add(const LoadGroupsEvent());
      context.read<NotificationBloc>().add(const LoadNotificationsEvent());
    });
    _setupNotificationListener();
    _loadPendingPaymentsCount();
  }

  Future<void> _loadPendingPaymentsCount() async {
    final count = await _paymentService.countMyPendingPayments();
    if (mounted) {
      setState(() => _pendingPaymentsCount = count);
    }
  }

  /// Configurer l'écoute des nouvelles notifications
  void _setupNotificationListener() {
    final firebaseService = di.sl<FirebaseMessagingService>();
    firebaseService.setOnNewNotificationCallback(() {
      if (mounted) {
        context.read<NotificationBloc>().add(const RefreshNotificationsEvent());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildBody(),
      bottomNavigationBar: _buildBottomNav(),
      floatingActionButton: _selectedIndex == 1 ? _buildFAB() : null,
    );
  }

  Widget _buildBody() {
    switch (_selectedIndex) {
      case 0:
        return _buildDashboard();
      case 1:
        return const GroupsListPage();
      case 2:
        return const EnhancedNotificationsPage();
      case 3:
        return const EnhancedProfilePage();
      default:
        return _buildDashboard();
    }
  }

  Widget _buildDashboard() {
    return CustomScrollView(
      slivers: [
        _buildAppBar(),
        SliverToBoxAdapter(
          child: Column(
            children: [
              _buildWelcomeSection(),
              _buildAdvertisementSection(),
              _buildQuickStats(),
              _buildQuickActions(),
              _buildRecentActivity(),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAdvertisementSection() {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is Authenticated && state.person.role == 'USER') {
          // TODO: Vérifier si l'utilisateur a un abonnement actif
          // Pour l'instant, on considère qu'il n'a pas d'abonnement
          final hasActiveSubscription = false;

          final adDataSource = di.sl<AdvertisementRemoteDataSource>();

          return HomeAdvertisementSection(
            hasActiveSubscription: hasActiveSubscription,
            advertisementDataSource: adDataSource,
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildAppBar() {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        String userName = 'Utilisateur';
        if (state is Authenticated) {
          userName = state.person.prenom;
        }

        return SliverAppBar(
          expandedHeight: 120,
          floating: false,
          pinned: true,
          backgroundColor: AppColors.primary,
          flexibleSpace: FlexibleSpaceBar(
            title: Text(
              'Bonjour, $userName 👋',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: () {
                // TODO: Implement search
              },
            ),
            BlocBuilder<NotificationBloc, NotificationState>(
              builder: (context, notifState) {
                int unreadCount = 0;
                if (notifState is NotificationLoaded) {
                  unreadCount = notifState.unreadCount;
                }

                return Stack(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.notifications_outlined),
                      onPressed: () {
                        setState(() => _selectedIndex = 2);
                      },
                    ),
                    if (unreadCount > 0)
                      Positioned(
                        right: 8,
                        top: 8,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: AppColors.error,
                            shape: BoxShape.circle,
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 18,
                            minHeight: 18,
                          ),
                          child: Text(
                            unreadCount > 99 ? '99+' : '$unreadCount',
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

  Widget _buildWelcomeSection() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.secondary, AppColors.secondary.withOpacity(0.7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.secondary.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
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
                    color: AppColors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  DateFormatter.formatDate(DateTime.now()),
                  style: const TextStyle(color: AppColors.white, fontSize: 14),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.account_balance_wallet,
              color: AppColors.white,
              size: 40,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStats() {
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

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Vue d\'ensemble',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        if (state is GroupsLoaded && state.groups.isNotEmpty) {
                          final firstGroup = state.groups.first;
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  GroupDetailsPage(group: firstGroup),
                            ),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Aucun groupe disponible'),
                              backgroundColor: AppColors.error,
                            ),
                          );
                        }
                      },
                      child: _buildStatCard(
                        'Groupes',
                        totalGroups.toString(),
                        Icons.group,
                        AppColors.primary,
                        'Total',
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      'Actifs',
                      activeGroups.toString(),
                      Icons.check_circle,
                      AppColors.success,
                      'En cours',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      'Montant',
                      CurrencyFormatter.formatCompact(totalAmount),
                      Icons.account_balance_wallet,
                      AppColors.secondary,
                      'Total cotisations',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const UpcomingPaymentsPage(),
                          ),
                        );
                      },
                      child: _buildStatCard(
                        'À venir',
                        _pendingPaymentsCount.toString(),
                        Icons.pending_actions,
                        AppColors.warning,
                        'Paiements',
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
    String subtitle,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(width: 8), // Espace entre l'icône et le texte
              Expanded(
                // WRAP LE TEXTE DANS UN EXPANDED
                child: Text(
                  value,
                  style: TextStyle(
                    fontSize: 20, // Légèrement plus petit
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                  overflow:
                      TextOverflow.ellipsis, // Ajouter ellipsis si trop long
                  maxLines: 1, // Garder sur une ligne
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Container(
      margin: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Actions Rapides',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildActionCard(
                  'Créer un\nGroupe',
                  Icons.add_circle_outline,
                  AppColors.primary,
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CreateGroupPage(),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildActionCard(
                  'Rejoindre\nun Groupe',
                  Icons.group_add,
                  AppColors.secondary,
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const JoinGroupPage(),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildActionCard(
                  'Mes\nPaiements',
                  Icons.payment,
                  AppColors.success,
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const MyPaymentsHistoryPage(),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard(
    String label,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: color,
                height: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentActivity() {
    return BlocBuilder<GroupBloc, GroupState>(
      builder: (context, state) {
        if (state is GroupsLoaded && state.groups.isNotEmpty) {
          return Container(
            margin: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Mes Groupes',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton(
                      onPressed: () => setState(() => _selectedIndex = 1),
                      child: const Text('Voir tout'),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ...state.groups
                    .take(3)
                    .map(
                      (group) => Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: AppColors.primary.withOpacity(0.1),
                            child: const Icon(
                              Icons.group,
                              color: AppColors.primary,
                            ),
                          ),
                          title: Text(
                            group.nom,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            '${CurrencyFormatter.format(group.montant)} • ${group.frequency}',
                          ),
                          trailing: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.success.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text(
                              'Actif',
                              style: TextStyle(
                                color: AppColors.success,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          onTap: () {
                            // TODO: Navigate to group details
                          },
                        ),
                      ),
                    ),
              ],
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildBottomNav() {
    return BottomNavigationBar(
      currentIndex: _selectedIndex,
      onTap: (index) => setState(() => _selectedIndex = index),
      type: BottomNavigationBarType.fixed,
      selectedItemColor: AppColors.primary,
      unselectedItemColor: AppColors.textSecondary,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.dashboard_outlined),
          activeIcon: Icon(Icons.dashboard),
          label: 'Accueil',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.group_outlined),
          activeIcon: Icon(Icons.group),
          label: 'Groupes',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.notifications_outlined),
          activeIcon: Icon(Icons.notifications),
          label: 'Notifications',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_outline),
          activeIcon: Icon(Icons.person),
          label: 'Profil',
        ),
      ],
    );
  }

  Widget _buildFAB() {
    return FloatingActionButton.extended(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const CreateGroupPage()),
        );
      },
      icon: const Icon(Icons.add),
      label: const Text('Nouveau'),
    );
  }
}
