import 'package:flutter/material.dart';
import 'package:need_mobile_app/providers/business_provider.dart';
import 'package:provider/provider.dart';
import '../../models/business_booking.dart';
import '../../models/enums.dart';
import '../../models/review.dart';
import '../../providers/review_provider.dart';
import '../../widgets/booking_status_pill.dart';
import '../../widgets/error_banner.dart';
import '../../widgets/primary_button.dart';

class BookingDetailScreen extends StatefulWidget {
  final BusinessBooking booking;
  final bool canReview;
  const BookingDetailScreen({super.key, required this.booking, this.canReview = false});

  @override
  State<BookingDetailScreen> createState() => _BookingDetailScreenState();
}

class _BookingDetailScreenState extends State<BookingDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if(widget.canReview) {
        context.read<ReviewProvider>().loadMyReviews();
      } else {
        context.read<ReviewProvider>().loadReviewsByBusiness(widget.booking.businessId);
      }
    });
  }

  Future<void> _openReviewSheet(Review? existing) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => _ReviewFormSheet(bookingId: widget.booking.id, existingReview: existing),
    );

    if (!mounted) return;

    final businessProvider = context.read<BusinessProvider>();
    businessProvider.loadTopRatedBusinesses();
    businessProvider.loadNewestBusinesses();
    businessProvider.loadBusinessById(widget.booking.businessId);
  }

  String _formatDate(DateTime date) => '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';

  @override
  Widget build(BuildContext context) {
    final booking = widget.booking;
    final reviewProvider = context.watch<ReviewProvider>();
    final myReview = widget.canReview ? reviewProvider.reviewForBooking(booking.id) : null;
    final businessReview = !widget.canReview? reviewProvider.reviewInBusinessAsync(booking.id) : null;
    final hasAnyReview = myReview != null ||businessReview != null;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        foregroundColor: Colors.black87,
        title: const Text('Booking Details', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        bottom: PreferredSize(preferredSize: const Size.fromHeight(1), child: Container(color: Colors.grey.shade200, height: 1)),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              BookingStatusPill(status: booking.status),
              const SizedBox(height: 16),
              _DetailRow(icon: Icons.storefront_outlined, label: 'Business', value: booking.businessName),
              _DetailRow(icon: Icons.badge_outlined, label: 'Employee', value: booking.employeeName),
              _DetailRow(icon: Icons.person_outline, label: 'Customer', value: booking.customerName),
              _DetailRow(icon: Icons.calendar_today_outlined, label: 'Date', value: _formatDate(booking.termDate)),
              _DetailRow(
                icon: Icons.access_time,
                label: 'Time',
                value: '${booking.termStartTime.format(context)} - ${booking.termEndTime.format(context)}',
              ),
              if (booking.notes != null && booking.notes!.isNotEmpty)
                _DetailRow(icon: Icons.notes_outlined, label: 'Notes', value: booking.notes!),
              _DetailRow(icon: Icons.event_available_outlined, label: 'Booked on', value: _formatDate(booking.bookedAt)),

              if (booking.status == BookingStatus.completed && (widget.canReview || hasAnyReview)) ...[
                const SizedBox(height: 28),
                Divider(color: Colors.grey.shade200),
                const SizedBox(height: 16),
                const Text('Review', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                if (widget.canReview)
                  (myReview == null
                    ? SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () => _openReviewSheet(null),
                        icon: const Icon(Icons.star_outline),
                        label: const Text('Leave a Review'),
                      ),
                    )
                  : _ExistingReviewCard(rating: myReview.rating, comment: myReview.comment, onEdit: () => _openReviewSheet(myReview)))
                else if (businessReview != null)
                  _ExistingReviewCard(rating: businessReview.rating, comment: businessReview.comment, onEdit: null),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _DetailRow({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Colors.grey.shade600),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
                const SizedBox(height: 2),
                Text(value, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ExistingReviewCard extends StatelessWidget {
  final int rating;
  final String? comment;
  final VoidCallback? onEdit;
  const _ExistingReviewCard({required this.rating, this.comment, this.onEdit});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(14), border: Border.all(color: Colors.grey.shade200)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Row(children: List.generate(5, (i) => Icon(i < rating ? Icons.star : Icons.star_border, color: Colors.amber, size: 18))),
              const Spacer(),
              if (onEdit != null) TextButton(onPressed: onEdit, child: const Text('Edit')),
            ],
          ),
          if (comment != null && comment!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(comment!, style: TextStyle(color: Colors.grey.shade700)),
          ],
        ],
      ),
    );
  }
}

class _ReviewFormSheet extends StatefulWidget {
  final String bookingId;
  final Review? existingReview;
  const _ReviewFormSheet({required this.bookingId, this.existingReview});

  @override
  State<_ReviewFormSheet> createState() => _ReviewFormSheetState();
}

class _ReviewFormSheetState extends State<_ReviewFormSheet> {
  late int _rating;
  late final TextEditingController _commentController;
  bool _isSubmitting = false;
  String? _errorMessage;

  bool get _isEditing => widget.existingReview != null;

  @override
  void initState() {
    super.initState();
    _rating = widget.existingReview?.rating ?? 0;
    _commentController = TextEditingController(text: widget.existingReview?.comment ?? '');
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _onSubmit() async {
    if (_rating == 0) {
      setState(() => _errorMessage = 'Please select a rating');
      return;
    }

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    final provider = context.read<ReviewProvider>();
    final comment = _commentController.text.trim().isEmpty ? null : _commentController.text.trim();

    final success = _isEditing
        ? await provider.updateReview(widget.existingReview!.id, rating: _rating, comment: comment)
        : await provider.createReview(bookingId: widget.bookingId, rating: _rating, comment: comment);

    if (!mounted) return;

    if (success) {
      Navigator.of(context).pop();
    } else {
      setState(() {
        _errorMessage = provider.errorMessage ?? 'Something went wrong.';
        _isSubmitting = false;
      });
    }
  }

  Future<void> _onDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete review?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(dialogContext).pop(false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    setState(() => _isSubmitting = true);
    final success = await context.read<ReviewProvider>().deleteReview(widget.existingReview!.id);

    if (!mounted) return;
    if (success) {
      Navigator.of(context).pop();
    } else {
      setState(() {
        _isSubmitting = false;
        _errorMessage = context.read<ReviewProvider>().errorMessage ?? 'Failed to delete review.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(context).viewInsets.bottom + 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(_isEditing ? 'Edit Review' : 'Leave a Review',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
          const SizedBox(height: 16),
          if (_errorMessage != null) ...[
            ErrorBanner(message: _errorMessage!),
            const SizedBox(height: 12),
          ],
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (index) {
              final starValue = index + 1;
              return IconButton(
                onPressed: _isSubmitting ? null : () => setState(() => _rating = starValue),
                icon: Icon(starValue <= _rating ? Icons.star : Icons.star_border, color: Colors.amber, size: 32),
              );
            }),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _commentController,
            maxLines: 3,
            enabled: !_isSubmitting,
            decoration: InputDecoration(
              hintText: 'Share your experience (optional)',
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: Colors.grey.shade300)),
            ),
          ),
          const SizedBox(height: 16),
          PrimaryButton(label: _isEditing ? 'Save Changes' : 'Submit Review', isLoading: _isSubmitting, onPressed: _onSubmit),
          if (_isEditing) ...[
            const SizedBox(height: 8),
            TextButton(onPressed: _isSubmitting ? null : _onDelete, style: TextButton.styleFrom(foregroundColor: Colors.red), child: const Text('Delete Review')),
          ],
        ],
      ),
    );
  }
}