import 'package:flutter/material.dart';
import 'package:need_mobile_app/models/business_review.dart';
import 'package:need_mobile_app/providers/review_provider.dart';
import 'package:provider/provider.dart';

class BusinessReviewsScreen extends StatefulWidget{
  final String businessId;
  final String businessName;

  const BusinessReviewsScreen({
    super.key,
    required this.businessId,
    required this.businessName
  });

  @override
  State<BusinessReviewsScreen> createState() => _BusinessReviewsScreenState();
}

class _BusinessReviewsScreenState extends State<BusinessReviewsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ReviewProvider>().loadReviewsByBusiness(widget.businessId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ReviewProvider>();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        foregroundColor: Colors.black87,
        title: Text('${widget.businessName} Reviews', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        bottom: PreferredSize(preferredSize: const Size.fromHeight(1), child: Container(color: Colors.grey.shade200, height: 1)),
      ),
      body: SafeArea(child: _buildBody(provider)),
    );
  }

  Widget _buildBody(ReviewProvider provider){
    if (provider.isLoading && provider.businessReviews.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (provider.errorMessage != null && provider.businessReviews.isEmpty) {
      return Center(child: Padding(padding: const EdgeInsets.all(24), child: Text(provider.errorMessage!, textAlign: TextAlign.center)));
    }
    if (provider.businessReviews.isEmpty) {
      return Center(child: Text('No reviews yet.', style: TextStyle(color: Colors.grey.shade600)));
    }

    return RefreshIndicator(
        onRefresh: () => provider.loadReviewsByBusiness(widget.businessId),
        child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: provider.businessReviews.length,
            itemBuilder: (context, index) => _ReviewCard(review: provider.businessReviews[index]),
        ),
    );
  }
}

class _ReviewCard extends StatelessWidget {
  final BusinessReview review;

  const _ReviewCard({required this.review});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: Colors.grey.shade200)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(review.customerName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            ],
          ),
          const SizedBox(height: 6),
          Row(children: List.generate(5, (i) => Icon(i < review.rating ? Icons.star : Icons.star_border, color: Colors.amber, size: 16))),
          if (review.comment != null && review.comment!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(review.comment!, style: TextStyle(color: Colors.grey.shade700)),
          ],
        ],
      ),
    );
  }
}