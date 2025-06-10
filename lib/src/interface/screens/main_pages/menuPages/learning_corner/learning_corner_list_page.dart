import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:itcc/src/data/api_routes/folder_api/folder_api.dart';
import 'package:itcc/src/data/constants/color_constants.dart';
import 'package:itcc/src/data/constants/style_constants.dart';
import 'package:itcc/src/data/models/learning_corner_model.dart';
import 'package:itcc/src/interface/components/custom_widgets/learning_corner_card.dart';
import 'package:itcc/src/interface/components/loading_indicator/loading_indicator.dart';
import 'package:itcc/src/interface/screens/main_pages/menuPages/learning_corner/learning_corner_detail_page.dart';

class LearningCornerListPage extends ConsumerWidget {
  const LearningCornerListPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncLearningCorners = ref.watch(fetchLearningCornerFoldersProvider);
    return Scaffold(
      backgroundColor: kWhite,
      appBar: AppBar(
        backgroundColor: kWhite,
        title: const Text(
          'Learning Corner',
          style: kBodyTitleR,
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          children: [
            Expanded(
              child: asyncLearningCorners.when(
                data: (folders) {
                  if (folders.isEmpty) {
                    return const Center(
                        child: Text('No Learning Corner content.'));
                  }
                  return ListView.builder(
                    itemCount: folders.length,
                    itemBuilder: (context, index) {
                      final folder = folders[index];
                      return LearningCornerCard(
                        folder: folder,
                        onLearnMorePressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => LearningCornerDetailPage(
                                  learningCorner: folder),
                            ),
                          );
                        },
                      );
                    },
                  );
                },
                loading: () => const Center(child: LoadingAnimation()),
                error: (e, st) => Center(child: Text('Error: $e')),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
