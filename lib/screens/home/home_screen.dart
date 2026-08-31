import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/business.dart';
import '../../models/category.dart';
import '../../providers/auth_provider.dart';
import '../../providers/booking_provider.dart';
import '../../providers/business_provider.dart';
import '../../providers/category_provider.dart';
import '../../providers/user_provider.dart';
import '../../utils/app_colors.dart';
import '../../utils/category_colors.dart';
import '../business/business_detail_screen.dart';
import '../business/business_list_screen.dart';

class HomeScreen extends StatefulWidget {
  final VoidCallback onExplorePressed;
  final VoidCallback onViewBookingsPressed;

  const HomeScreen({super.key, required this.onExplorePressed, required this.onViewBookingsPressed});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CategoryProvider>().loadCategories();
      context.read<BusinessProvider>().loadTopRatedBusinesses();
      context.read<BusinessProvider>().loadNewestBusinesses();
    });
  }

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final userProvider = context.watch<UserProvider>();
    final firstName = authProvider.isSignedIn ? userProvider.currentUser?.firstName : null;

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.only(bottom: 24),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    firstName != null ? '👋 ${_greeting()}, $firstName' : '👋 ${_greeting()}',
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 4),
                  Text('Find your next appointment', style: TextStyle(color: Colors.grey.shade600, fontSize: 14)),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _SearchBarButton(onTap: widget.onExplorePressed),
            ),
            const SizedBox(height: 24),
            const _CategoriesSection(),
            const SizedBox(height: 28),
            const _BusinessCarouselSection(title: 'Top Rated', listSelector: _topRatedSelector),
            const SizedBox(height: 28),
            const _BusinessCarouselSection(title: 'New Businesses', listSelector: _newBusinessesSelector),
            const SizedBox(height: 28),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _UpcomingBookingSection(
                onExplorePressed: widget.onExplorePressed,
                onViewBookingsPressed: widget.onViewBookingsPressed,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

List<Business> _topRatedSelector(BusinessProvider p) => p.topRatedBusinesses;
List<Business> _newBusinessesSelector(BusinessProvider p) => p.newBusinesses;

class _SearchBarButton extends StatelessWidget {
  final VoidCallback onTap;
  const _SearchBarButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Row(
          children: [
            Icon(Icons.search, color: Colors.grey.shade500),
            const SizedBox(width: 10),
            Text('Search businesses...', style: TextStyle(color: Colors.grey.shade500, fontSize: 15)),
          ],
        ),
      ),
    );
  }
}

class _CategoriesSection extends StatelessWidget {
  const _CategoriesSection();

  @override
  Widget build(BuildContext context) {
    final categories = context.watch<CategoryProvider>().activeCategories;
    if (categories.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          final colors = CategoryColors.forId(category.id);
          return Padding(
            padding: const EdgeInsets.only(right: 10),
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => BusinessListScreen(initialCategoryId: category.id)),
              ),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(color: colors.background, borderRadius: BorderRadius.circular(20)),
                alignment: Alignment.center,
                child: Text(category.name, style: TextStyle(color: colors.text, fontWeight: FontWeight.w600, fontSize: 13)),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _BusinessCarouselSection extends StatelessWidget {
  final String title;
  final List<Business> Function(BusinessProvider) listSelector;

  const _BusinessCarouselSection({required this.title, required this.listSelector});

  @override
  Widget build(BuildContext context) {
    final businesses = listSelector(context.watch<BusinessProvider>());
    if (businesses.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 190,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: businesses.length,
            itemBuilder: (context, index) {
              final business = businesses[index];
              return _BusinessHomeCard(
                business: business,
                onTap: () => Navigator.of(context)
                    .push(MaterialPageRoute(builder: (_) => BusinessDetailScreen(businessId: business.id))),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _BusinessHomeCard extends StatelessWidget {
  final Business business;
  final VoidCallback onTap;

  const _BusinessHomeCard({required this.business, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final categories = context.watch<CategoryProvider>().categories;
    Category? category;
    for (final c in categories) {
      if (c.id == business.categoryId) {
        category = c;
        break;
      }
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 160,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _CardImage(imageUrl: business.logoUrl),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(business.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    const SizedBox(height: 4),
                    if (business.rating != null)
                      Row(children: [
                        const Icon(Icons.star, color: Colors.amber, size: 14),
                        const SizedBox(width: 2),
                        Text(business.rating!.toStringAsFixed(1),
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                      ])
                    else
                      Text('No ratings yet', style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
                    const SizedBox(height: 2),
                    if (category != null)
                      Text(category.name,
                          maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CardImage extends StatelessWidget {
  final String? imageUrl;
  const _CardImage({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    const height = 90.0;
    if (imageUrl == null || imageUrl!.isEmpty) {
      return Container(height: height, width: double.infinity, color: Colors.grey.shade200, child: Icon(Icons.storefront, color: Colors.grey.shade400));
    }
    return Image.network(
      imageUrl!,
      height: height,
      width: double.infinity,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) =>
          Container(height: height, color: Colors.grey.shade200, child: Icon(Icons.broken_image, color: Colors.grey.shade400)),
    );
  }
}

class _UpcomingBookingSection extends StatelessWidget {
  final VoidCallback onExplorePressed;
  final VoidCallback onViewBookingsPressed;

  const _UpcomingBookingSection({required this.onExplorePressed, required this.onViewBookingsPressed});

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(date.year, date.month, date.day);
    final diff = target.difference(today).inDays;
    if (diff == 0) return 'Today';
    if (diff == 1) return 'Tomorrow';
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  String _formatTime(TimeOfDay time) =>
      '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    if (!context.watch<AuthProvider>().isSignedIn) return const SizedBox.shrink();

    final summary = context.watch<BookingProvider>().upcomingBookingSummary;

    if (summary == null) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey.shade200)),
        child: Column(
          children: [
            Icon(Icons.calendar_today_outlined, size: 32, color: Colors.grey.shade400),
            const SizedBox(height: 10),
            Text("You don't have any bookings.", style: TextStyle(color: Colors.grey.shade600)),
            const SizedBox(height: 14),
            ElevatedButton(
                onPressed: onExplorePressed,
                child: const Text('Explore Businesses'),
                style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF6C40DD),
                    foregroundColor: Colors.white)
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(18)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Upcoming', style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w600, fontSize: 13)),
          const SizedBox(height: 6),
          Text('${_formatDate(summary.termDate)} · ${_formatTime(summary.termStartTime)}',
              style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800)),
          const SizedBox(height: 4),
          Text(summary.businessName, style: const TextStyle(color: Colors.white, fontSize: 15)),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: onViewBookingsPressed,
              style: OutlinedButton.styleFrom(foregroundColor: Colors.white, side: const BorderSide(color: Colors.white)),
              child: const Text('View Booking'),
            ),
          ),
        ],
      ),
    );
  }
}