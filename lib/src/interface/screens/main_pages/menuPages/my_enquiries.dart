import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:itcc/src/data/api_routes/enquiries_api/get_enquiries.dart';
import 'package:itcc/src/data/constants/color_constants.dart';
import 'package:itcc/src/data/constants/style_constants.dart';
import 'package:itcc/src/data/models/enquiries_model.dart';
import 'package:intl/intl.dart';
import 'package:itcc/src/interface/components/loading_indicator/loading_indicator.dart';
import 'package:itcc/src/data/services/launch_url.dart';

class MyEnquiriesPage extends ConsumerStatefulWidget {
  const MyEnquiriesPage({Key? key}) : super(key: key);

  @override
  ConsumerState<MyEnquiriesPage> createState() => _MyEnquiriesPageState();
}

class _MyEnquiriesPageState extends ConsumerState<MyEnquiriesPage> {
  String formatDate(String? dateString) {
    if (dateString == null) return '';
    final DateTime date = DateTime.parse(dateString);
    return DateFormat('dd MMM yyyy').format(date);
  }

  String getInitial(String? name) {
    if (name == null || name.isEmpty) return 'A';
    return name[0].toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final enquiriesAsync = ref.watch(getEnquiriesProvider);

    return Scaffold(
      backgroundColor: kWhite,
      appBar: AppBar(
        title: Text(
          "My Enquiries",
          style: TextStyle(fontSize: 17),
        ),
        backgroundColor: Colors.white,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: enquiriesAsync.when(
        loading: () => const Center(child: LoadingAnimation()),
        error: (error, stackTrace) => Center(
          child: Text(
            'Error loading enquiries',
            style: kBodyTitleR.copyWith(color: kRedDark),
          ),
        ),
        data: (enquiries) {
          if (enquiries.isEmpty) {
            return Center(
              child: Text(
                'No enquiries found',
                style: kBodyTitleR,
              ),
            );
          }

          return ListView.builder(
            itemCount: enquiries.length,
            itemBuilder: (context, index) {
              final enquiry = enquiries[index];
              return Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Container(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ListTile(
                        leading: CircleAvatar(
                          backgroundColor: kPrimaryColor,
                          child: Text(
                            getInitial(enquiry.name),
                            style: kBodyTitleB.copyWith(color: kWhite),
                          ),
                        ),
                        title: Text(enquiry.name ?? 'Unknown',
                            style: kBodyTitleSB),
                        subtitle: Text(
                          formatDate(enquiry.createdAt),
                          style: kSmallerTitleR.copyWith(color: kGreyDark),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (enquiry.email != null &&
                                enquiry.email!.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 8.0),
                                child: GestureDetector(
                                  onTap: () => launchEmail(enquiry.email!),
                                  child: Row(
                                    children: [
                                      Icon(Icons.email_outlined,
                                          size: 18, color: kGreyDark),
                                      SizedBox(width: 8),
                                      Text(
                                        enquiry.email!,
                                        style: kSmallTitleR.copyWith(
                                          color: kPrimaryColor,
                                          decoration: TextDecoration.underline,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            if (enquiry.phone != null &&
                                enquiry.phone!.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 8.0),
                                child: GestureDetector(
                                  onTap: () => launchPhone(enquiry.phone!),
                                  child: Row(
                                    children: [
                                      Icon(Icons.phone_outlined,
                                          size: 18, color: kGreyDark),
                                      SizedBox(width: 8),
                                      Text(
                                        enquiry.phone!,
                                        style: kSmallTitleR.copyWith(
                                          color: kPrimaryColor,
                                          decoration: TextDecoration.underline,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            Text(
                              'Description:',
                              style: kSmallTitleSB.copyWith(color: kGreyDark),
                            ),
                            SizedBox(height: 4),
                            Text(
                              enquiry.description ?? '',
                              style: kSmallTitleR,
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            Divider(
                              color: kGreyLight,
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
