import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:itcc/src/data/constants/color_constants.dart';
import 'package:itcc/src/data/notifiers/user_notifier.dart';
import 'package:itcc/src/interface/components/Dialogs/premium_dialog.dart';
import 'package:itcc/src/interface/screens/main_pages/chat/chat_dash.dart';
import 'package:itcc/src/interface/screens/main_pages/chat/groupchat.dart';
import 'package:itcc/src/interface/screens/main_pages/chat/members.dart';

class PeoplePage extends ConsumerWidget {
  const PeoplePage({super.key});

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
        length: 2,
        child: Scaffold(
            backgroundColor: kWhite,
            body: SafeArea(
              child: Column(
                children: [
                  PreferredSize(
                    preferredSize: Size.fromHeight(20),
                    child: Container(
                      margin: EdgeInsets.only(top: 0),
                      child: const SizedBox(
                        height: 40,
                        child: TabBar(
                          enableFeedback: true,
                          isScrollable: false,
                          indicatorColor: kPrimaryColor,
                          indicatorWeight: 3.0,
                          indicatorSize: TabBarIndicatorSize.tab,
                          labelColor: kPrimaryColor,
                          unselectedLabelColor: Colors.grey,
                          labelStyle: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                          tabs: [
                            Tab(text: "MEMBERS"),
                            Tab(text: "CHAT LIST"),
                            // Tab(text: "GROUP CHAT"),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: TabBarView(
                      children: [
                        const MembersPage(),
                        ChatDash(),
                        // GroupChatPage()
                      ],
                    ),
                  ),
                ],
              ),
            )));
  }
}
