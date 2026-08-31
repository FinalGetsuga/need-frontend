import 'package:flutter/material.dart';
import 'package:need_mobile_app/screens/business/business_reviews_screen.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/business_image.dart';
import '../../models/category.dart';
import '../../models/enums.dart';
import '../../models/work_schedule.dart';
import '../../providers/auth_provider.dart';
import '../../providers/business_provider.dart';
import '../../providers/category_provider.dart';
import '../../providers/work_schedule_provider.dart';
import '../../utils/app_colors.dart';
import '../../utils/business_hours.dart';
import '../../widgets/category_pill.dart';
import '../../widgets/primary_button.dart';
import '../auth/login_screen.dart';
import '../booking/booking_create_screen.dart';

class BusinessDetailScreen extends StatefulWidget {
  final String businessId;
  const BusinessDetailScreen({super.key, required this.businessId});

  @override
  State<BusinessDetailScreen> createState() => _BusinessDetailScreenState();
}

class _BusinessDetailScreenState extends State<BusinessDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BusinessProvider>().loadBusinessById(widget.businessId);
      context.read<WorkScheduleProvider>().loadScheduleForViewing(widget.businessId);
    });
  }

  void _onBookPressed() {
    final loggedIn = context.read<AuthProvider>().isSignedIn;
    if (!loggedIn) {
      Navigator.of(context).push(MaterialPageRoute(builder: (_) => const LoginScreen()));
      return;
    }
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => BookingCreateScreen(businessId: widget.businessId)));
  }

  void _showLaunchError(String what) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Could not open $what')));
  }

  Future<void> _openMap(String address) async {
    final uri = Uri.parse('https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(address)}');
    try {
      final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!launched) _showLaunchError('maps');
    } catch (_) {
      _showLaunchError('maps');
    }
  }

  Future<void> _openWebsite(String url) async {
    final uri = Uri.parse(url.startsWith('http') ? url : 'https://$url');
    try {
      final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!launched) _showLaunchError('website');
    } catch (_) {
      _showLaunchError('website');
    }
  }

  @override
  Widget build(BuildContext context) {
    final businessProvider = context.watch<BusinessProvider>();
    final business = businessProvider.selectedBusiness;
    final stillLoading = businessProvider.isLoading && business?.id != widget.businessId;

    if (stillLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (business == null || business.id != widget.businessId) {
      return Scaffold(
        appBar: AppBar(backgroundColor: Colors.white, elevation: 0, foregroundColor: Colors.black87),
        body: Center(child: Text(businessProvider.errorMessage ?? 'Business not found.')),
      );
    }

    final schedule = context.watch<WorkScheduleProvider>().viewedSchedule;
    final openStatus = schedule != null ? computeOpenStatus(schedule, context) : null;

    final categories = context.watch<CategoryProvider>().categories;
    Category? category;
    for (final c in categories) {
      if (c.id == business.categoryId) {
        category = c;
        break;
      }
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(backgroundColor: Colors.white, surfaceTintColor: Colors.transparent, elevation: 0, foregroundColor: Colors.black87),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _ImageCarousel(images: business.images),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _LogoAvatar(logoUrl: business.logoUrl),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(business.name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
                            const SizedBox(height: 8),
                            if (openStatus != null) ...[
                              Row(
                                children: [
                                  _OpenStatusPill(isOpen: openStatus.isOpen),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(openStatus.label, style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                            ],
                            Row(
                              children: [
                                const Icon(Icons.star, color: Colors.amber, size: 18),
                                const SizedBox(width: 4),
                                if (business.rating != null) ...[
                                  Text(business.rating!.toStringAsFixed(1), style: const TextStyle(fontWeight: FontWeight.bold)),
                                  const SizedBox(width: 4),
                                  Text('· ${business.reviewCount} review${business.reviewCount == 1 ? '' : 's'}',
                                      style: TextStyle(color: Colors.grey.shade600)),
                                ] else
                                  Text('No ratings yet', style: TextStyle(color: Colors.grey.shade600)),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  if (business.reviewCount > 0)
                    Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: GestureDetector(
                          onTap: () => Navigator.of(context).push(MaterialPageRoute(
                              builder: (_) => BusinessReviewsScreen(businessId: business.id, businessName: business.name),
                          )),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text('See Reviews', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600, fontSize: 13)),
                              Icon(Icons.chevron_right, color: AppColors.primary, size: 16),
                            ],
                          ),
                        ),
                    ),
                  const SizedBox(height: 20),
                  Divider(color: Colors.grey.shade200),
                  _InfoRow(
                    icon: Icons.location_on_outlined,
                    label: 'Address',
                    value: business.address,
                    actionLabel: 'Get Directions',
                    onTap: () => _openMap(business.address),
                  ),
                  if (business.websiteUrl != null && business.websiteUrl!.isNotEmpty) ...[
                    Divider(color: Colors.grey.shade200),
                    _InfoRow(
                      icon: Icons.language,
                      label: 'Website',
                      value: business.websiteUrl!.replaceFirst(RegExp(r'^https?://'), ''),
                      actionLabel: 'Visit Website',
                      onTap: () => _openWebsite(business.websiteUrl!),
                    ),
                  ],
                  Divider(color: Colors.grey.shade200),
                  const SizedBox(height: 20),
                  const Text('About', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(business.description, style: TextStyle(color: Colors.grey.shade700, height: 1.4)),
                  const SizedBox(height: 24),
                  const Text('Category', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  if (category != null) CategoryPill(category: category),
                  if (schedule != null) ...[
                    const SizedBox(height: 24),
                    const Text('Business Hours', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    _BusinessHoursSection(schedule: schedule),
                  ],
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: PrimaryButton(label: 'Book Now', icon: Icons.calendar_today_outlined, onPressed: _onBookPressed),
        ),
      ),
    );
  }
}

class _ImageCarousel extends StatefulWidget {
  final List<BusinessImage> images;
  const _ImageCarousel({required this.images});

  @override
  State<_ImageCarousel> createState() => _ImageCarouselState();
}

class _ImageCarouselState extends State<_ImageCarousel> {
  final _controller = PageController();
  int _currentIndex = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _goToNext() {
    final nextIndex = (_currentIndex + 1) % widget.images.length;
    _controller.animateToPage(nextIndex, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
  }

  @override
  Widget build(BuildContext context) {
    const height = 260.0;

    if (widget.images.isEmpty) {
      return Container(
        height: height,
        width: double.infinity,
        color: Colors.grey.shade200,
        child: Icon(Icons.storefront, size: 64, color: Colors.grey.shade400),
      );
    }

    return SizedBox(
      height: height,
      child: Stack(
        fit: StackFit.expand,
        children: [
          PageView.builder(
            controller: _controller,
            itemCount: widget.images.length,
            onPageChanged: (index) => setState(() => _currentIndex = index),
            itemBuilder: (context, index) => Image.network(
              widget.images[index].imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) =>
                  Container(color: Colors.grey.shade200, child: Icon(Icons.broken_image, size: 64, color: Colors.grey.shade400)),
            ),
          ),
          if (widget.images.length > 1) ...[
            Positioned(
              right: 12,
              top: 0,
              bottom: 0,
              child: Center(
                child: GestureDetector(
                  onTap: _goToNext,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(color: Colors.black45, shape: BoxShape.circle),
                    child: const Icon(Icons.chevron_right, color: Colors.white, size: 24),
                  ),
                ),
              ),
            ),
            Positioned(
              right: 12,
              bottom: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(12)),
                child: Text('${_currentIndex + 1}/${widget.images.length}', style: const TextStyle(color: Colors.white, fontSize: 12)),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _LogoAvatar extends StatelessWidget {
  final String? logoUrl;
  const _LogoAvatar({required this.logoUrl});

  @override
  Widget build(BuildContext context) {
    const size = 64.0;
    if (logoUrl == null || logoUrl!.isEmpty) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(14)),
        child: Icon(Icons.storefront, color: Colors.grey.shade400),
      );
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: Image.network(
        logoUrl!,
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) =>
            Container(width: size, height: size, color: Colors.grey.shade200, child: Icon(Icons.broken_image, color: Colors.grey.shade400)),
      ),
    );
  }
}

class _OpenStatusPill extends StatelessWidget {
  final bool isOpen;
  const _OpenStatusPill({required this.isOpen});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isOpen ? Colors.green.shade50 : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isOpen ? Colors.green.shade200 : Colors.grey.shade300),
      ),
      child: Text(isOpen ? 'Open' : 'Closed',
          style: TextStyle(color: isOpen ? Colors.green.shade700 : Colors.grey.shade600, fontSize: 12, fontWeight: FontWeight.w600)),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final String actionLabel;
  final VoidCallback onTap;

  const _InfoRow({required this.icon, required this.label, required this.value, required this.actionLabel, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Icon(icon, color: AppColors.primary, size: 22),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                  const SizedBox(height: 2),
                  Text(value, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(actionLabel, style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600, fontSize: 13)),
            Icon(Icons.chevron_right, color: Colors.grey.shade400, size: 20),
          ],
        ),
      ),
    );
  }
}

class _BusinessHoursSection extends StatelessWidget {
  final WorkSchedule schedule;
  const _BusinessHoursSection({required this.schedule});

  static const _order = [
    AppDayOfWeek.monday, AppDayOfWeek.tuesday, AppDayOfWeek.wednesday,
    AppDayOfWeek.thursday, AppDayOfWeek.friday, AppDayOfWeek.saturday, AppDayOfWeek.sunday,
  ];

  String _hoursTextFor(AppDayOfWeek day, BuildContext context) {
    for (final wd in schedule.workingDays) {
      if (wd.dayOfWeek == day) {
        return '${wd.startTime.format(context)} - ${wd.endTime.format(context)}';
      }
    }
    return 'Closed';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (final day in _order)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(weekdayName(day), style: TextStyle(color: Colors.grey.shade700)),
                Text(_hoursTextFor(day, context), style: const TextStyle(fontWeight: FontWeight.w600)),
              ],
            ),
          ),
      ],
    );
  }
}