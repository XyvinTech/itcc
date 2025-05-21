import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:itcc/src/data/constants/color_constants.dart';
import 'package:itcc/src/data/constants/style_constants.dart';
import 'package:itcc/src/data/globals.dart';
import 'package:itcc/src/data/models/subscription_model.dart';
import 'package:itcc/src/data/services/razorpay.dart';
import 'package:itcc/src/data/utils/secure_storage.dart';
import 'package:itcc/src/interface/components/Buttons/primary_button.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:itcc/src/data/api_routes/subscription_api/subscription_api.dart';

import '../../../components/loading_indicator/loading_indicator.dart';

class MySubscriptionPage extends ConsumerStatefulWidget {
  const MySubscriptionPage({super.key});
  @override
  ConsumerState<MySubscriptionPage> createState() =>
      _PremiumSubscriptionFlowState();
}

class _PremiumSubscriptionFlowState extends ConsumerState<MySubscriptionPage> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final subscriptionsAsync = ref.watch(fetchSubscriptionsProvider);

    return Scaffold(
      backgroundColor: kPrimaryLightColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 32),
                Text(
                  'Get ITCC Premium for Your Business',
                  style: kDisplayTitleM.copyWith(fontSize: 27),
                ),
                const SizedBox(height: 32),
                subscriptionsAsync.when(
                  data: (subscriptions) {
                    if (subscriptions.isEmpty) {
                      return const Center(
                        child: Text('No subscriptions available'),
                      );
                    }
                    return Column(
                      children: [
                        CarouselSlider(
                          options: CarouselOptions(
                            height: 400,
                            viewportFraction: 1.0,
                            enableInfiniteScroll: false,
                            onPageChanged: (index, reason) {
                              setState(() {
                                _currentIndex = index;
                              });
                            },
                          ),
                          items: subscriptions.map((subscription) {
                            return _SubscriptionCard(
                              subscription: subscription,
                              // onComplete: widget.onComplete,
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: subscriptions.asMap().entries.map((entry) {
                            return Container(
                              width: 8.0,
                              height: 8.0,
                              margin:
                                  const EdgeInsets.symmetric(horizontal: 4.0),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: kPrimaryColor.withOpacity(
                                  _currentIndex == entry.key ? 0.9 : 0.4,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    );
                  },
                  loading: () =>
                      const Center(child: LoadingAnimation()),
                  error: (error, stack) => Center(
                    child: Text('Error: ${error.toString()}'),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Discover the right subscription to boost your business visibility and network.',
                  style: kBodyTextStyle.copyWith(fontSize: 12),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SubscriptionCard extends StatelessWidget {
  final SubscriptionModel subscription;

  const _SubscriptionCard({
    Key? key,
    required this.subscription,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        border: Border.all(color: kPrimaryColor, width: 1),
        borderRadius: BorderRadius.circular(20),
        color: kWhite,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Align(
            alignment: Alignment.topLeft,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: kPrimaryColor,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text('BEST PLAN',
                  style: kSmallTitleR.copyWith(color: kWhite)),
            ),
          ),
          const SizedBox(height: 16),
          Text(subscription.name,
              style: kDisplayTitleSB.copyWith(fontSize: 20)),
          const SizedBox(height: 8),
          Text(subscription.description, style: kSmallTitleR),
          const SizedBox(height: 18),
          Row(
            children: [
              Text('₹${subscription.price}',
                  style: kDisplayTitleSB.copyWith(fontSize: 24)),
              Text('/${subscription.days} days',
                  style: kBodyTextStyle.copyWith(fontSize: 18)),
            ],
          ),
          const SizedBox(height: 18),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: (subscription.benefits).map((benefit) {
              return _PlanBenefit(text: benefit);
            }).toList(),
          ),
          
          customButton(
            label: 'Select This Plan',
            onPressed: () async {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => RazorpayScreen(parentSubId: subscription.id,
                          amount: subscription.price.toDouble(),
                          category: 'membership')));
            },
            buttonColor: kPrimaryColor,
            fontSize: 16,
          ),
        ],
      ),
    );
  }
}

class _PlanBenefit extends StatelessWidget {
  final String text;
  const _PlanBenefit({required this.text});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Icon(Icons.check_circle, color: kPrimaryColor, size: 15),
          const SizedBox(width: 10),
          Text(text, style: kBodyTextStyle.copyWith(fontSize: 12)),
        ],
      ),
    );
  }
}

const kBodyTextStyle = TextStyle(fontSize: 15, color: kGreyDark, height: 1.5);
