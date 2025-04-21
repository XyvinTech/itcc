import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:itcc/src/data/notifiers/user_notifier.dart';
import 'package:itcc/src/data/constants/color_constants.dart';
import 'package:itcc/src/interface/components/Dialogs/premium_dialog.dart';
import 'package:itcc/src/interface/screens/main_pages/bussiness_products/business_view.dart';
import 'package:itcc/src/interface/screens/main_pages/bussiness_products/product_view.dart';
import 'package:itcc/src/interface/screens/main_pages/chat_page.dart';

class BusinessPage extends ConsumerWidget {
  const BusinessPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(userProvider);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      userAsync.whenOrNull(data: (user) {
        if (user.status == 'trial') {
          showDialog(
            context: context,
            builder: (_) => const PremiumDialog(),
          );
        }
      });
    });
    return DefaultTabController(
        length: 2, // Number of tabs
        child: Scaffold(
            backgroundColor: Colors.white,
            body: SafeArea(
              child: Column(
                children: [
                  PreferredSize(
                    preferredSize: const Size.fromHeight(20),
                    child: Container(
                      margin: const EdgeInsets.only(top: 0),
                      child: const SizedBox(
                        height: 50,
                        child: TabBar(
                          enableFeedback: true,
                          isScrollable: false,
                          indicatorColor: kPrimaryColor,
                          indicatorWeight: 3.0,
                          indicatorSize: TabBarIndicatorSize.tab,
                          labelColor: kPrimaryColor,
                          unselectedLabelColor: Colors.grey,
                          labelStyle: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                          tabs: [
                            Tab(
                              text: "Business Posts",
                            ),
                            Tab(
                              text: "Ecommerce",
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                   Expanded(
                    child: TabBarView(
                      children: [
                        BusinessView(),
                        ProductView(),
                      ],
                    ),
                  ),
                ],
              ),
            )));
  }
}

