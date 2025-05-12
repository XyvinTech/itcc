import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:itcc/src/data/api_routes/events_api/events_api.dart';
import 'package:itcc/src/data/api_routes/folder_api/folder_api.dart';
import 'package:itcc/src/data/constants/color_constants.dart';
import 'package:itcc/src/data/globals.dart';
import 'package:itcc/src/data/models/events_model.dart';
import 'package:itcc/src/data/models/folder_model.dart';
import 'package:itcc/src/data/notifiers/user_notifier.dart';
import 'package:itcc/src/data/services/launch_url.dart';
import 'package:itcc/src/data/services/navgitor_service.dart';
import 'package:itcc/src/interface/components/Dialogs/premium_dialog.dart';
import 'package:itcc/src/interface/components/loading_indicator/loading_indicator.dart';
import 'package:itcc/src/interface/screens/main_pages/event/qr_scanner_page.dart';
import 'package:itcc/src/interface/screens/main_pages/event/media_upload_page.dart';
import 'package:itcc/src/interface/screens/main_pages/event/folder_view_page.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';

import '../../../components/Buttons/primary_button.dart';

class ViewMoreEventPage extends ConsumerStatefulWidget {
  final Event event;
  const ViewMoreEventPage({super.key, required this.event});

  @override
  ConsumerState<ViewMoreEventPage> createState() => _ViewMoreEventPageState();
}

class _ViewMoreEventPageState extends ConsumerState<ViewMoreEventPage>
    with SingleTickerProviderStateMixin {
  bool registered = false;
  bool isRegistering = false;
  late TabController _tabController;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    registered = widget.event.rsvp?.contains(id) ?? false;
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  String _getRegistrationButtonLabel() {
    if (widget.event.status == 'cancelled') return 'CANCELLED';
    if (registered) return 'REGISTERED';

    final int limit = widget.event.limit ?? 0;
    final int registeredCount = widget.event.rsvp?.length ?? 0;

    if (limit > 0) {
      final spotsLeft = limit - registeredCount;
      if (spotsLeft <= 0) return 'REGISTRATION FULL';

      if (spotsLeft == 1) {
        return 'REGISTER (Last seat!)';
      } else if (spotsLeft <= 5) {
        return 'REGISTER (Only $spotsLeft seats left!)';
      }
      return 'REGISTER ($spotsLeft seats left)';
    }

    return 'REGISTER EVENT';
  }

  bool _canRegister() {
    if (registered || widget.event.status == 'cancelled') return false;

    final int limit = widget.event.limit ?? 0;
    if (limit == 0) return true;

    final int registeredCount = widget.event.rsvp?.length ?? 0;
    return registeredCount < limit;
  }

  String _getRegistrationCountText() {
    final registered = widget.event.rsvp?.length ?? 0;
    final limit = widget.event.limit!;
    final remaining = limit - registered;

    if (remaining == 0) {
      return 'All seats taken ($registered/$limit)';
    } else if (remaining == 1) {
      return 'Last seat remaining ($registered/$limit)';
    } else if (remaining <= 10) {
      return 'Only $remaining seats left ($registered/$limit)';
    }
    return '$registered/$limit registered';
  }

  @override
  Widget build(BuildContext context) {
    DateTime dateTime =
        DateTime.parse(widget.event.eventDate.toString()).toLocal();
    String formattedDate = DateFormat('dd MMM yyyy').format(dateTime);

    return Scaffold(
      backgroundColor: Colors.white,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              scrolledUnderElevation: 0,
              expandedHeight: widget.event.image != null ? 300.0 : 0.0,
              floating: false,
              pinned: true,
              backgroundColor: Colors.white,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.pop(context),
              ),
              flexibleSpace: FlexibleSpaceBar(
                background: widget.event.image != null
                    ? Stack(
                        fit: StackFit.expand,
                        children: [
                          Image.network(
                            widget.event.image!,
                            fit: BoxFit.contain,
                          ),
                          if (widget.event.status != null)
                            Positioned(
                              top: 60,
                              right: 16,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE4483E),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      widget.event.status!.toUpperCase(),
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    const Icon(Icons.circle,
                                        color: Colors.white, size: 8),
                                  ],
                                ),
                              ),
                            ),
                        ],
                      )
                    : null,
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.event.eventName ?? '',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.calendar_today,
                            size: 12, color: Color(0xFF700F0F)),
                        const SizedBox(width: 8),
                        Text(
                          formattedDate,
                          style: const TextStyle(
                            fontSize: 10,
                            color: Color(0xFF700F0F),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      widget.event.description ?? 'No description available',
                      style: const TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),
            SliverPersistentHeader(
              pinned: true,
              delegate: _SliverAppBarDelegate(
                Container(
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: kGreyLight.withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                  ),
                  child: TabBar(
                    labelPadding: EdgeInsets.symmetric(horizontal: 30),
                    dividerColor: kGreyLight.withOpacity(.2),
                    padding: EdgeInsets.only(left: 10),
                    indicatorWeight: 4,
                    controller: _tabController,
                    isScrollable: true,
                    labelColor: kPrimaryColor,
                    unselectedLabelColor: Colors.grey,
                    indicatorColor: kPrimaryColor,
                    indicatorSize: TabBarIndicatorSize.tab,
                    labelStyle: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                    unselectedLabelStyle: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                    ),
                    tabAlignment: TabAlignment.start,
                    tabs: const [
                      Tab(text: 'Info'),
                      Tab(text: 'Media'),
                    ],
                  ),
                ),
              ),
            ),
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: [
            CustomScrollView(
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.all(16.0),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      if (widget.event.venue != null)
                        _buildLoactionInfo(
                            'Venue & Location', widget.event.venue ?? ''),
                      const SizedBox(height: 24),
                      _buildInfoSection(
                          'Organizer', widget.event.organiserName ?? ''),
                      const SizedBox(height: 24),

                      _buildEventCoordinator(),
                      const SizedBox(height: 24),
                      _buildSpeakersSection(),
                      const SizedBox(height: 14),
                      if (widget.event.limit != null)
                        _buildInfoSection(
                            'Registration', _getRegistrationCountText()),
                      const SizedBox(
                          height: 80), // Bottom padding for the register button
                    ]),
                  ),
                ),
              ],
            ),

            // Media Tab
            ref.watch(getFoldersProvider(eventId: widget.event.id!)).when(
                  loading: () => const Center(child: LoadingAnimation()),
                  error: (error, stackTrace) =>
                      Center(child: Text('No Folders yet')),
                  data: (folders) {
                    return Column(
                      children: [
                        Expanded(
                          child: ListView.separated(
                            padding: const EdgeInsets.all(16),
                            itemCount: folders.length,
                            separatorBuilder: (context, index) =>
                                const Divider(height: 1),
                            itemBuilder: (context, index) {
                              final folder = folders[index];
                              return InkWell(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => FolderViewPage(eventId: widget.event.id??'',
                                        folderId: folder.id!,
                                        folderName: folder.name,
                                      ),
                                    ),
                                  );
                                },
                                child: Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 12),
                                  child: Row(
                                    children: [
                                      SvgPicture.asset(
                                          'assets/svg/icons/folder_icon.svg'),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              folder.name,
                                              style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              '${folder.videoCount ?? 0} Videos, ${folder.imageCount ?? 0} Photos',
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: Colors.grey[600],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const Icon(
                                        Icons.chevron_right,
                                        color: Colors.grey,
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        if (widget.event.status == 'completed')
                          Padding(
                              padding: const EdgeInsets.all(16),
                              child: customButton(
                                label: 'Add Media',
                                onPressed: () async {
                                  final result = await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => MediaUploadPage(
                                        eventId: widget.event.id!,
                                      ),
                                    ),
                                  );
                                  if (result == true) {
                                    ref.invalidate(getFoldersProvider(
                                        eventId: widget.event.id!));
                                  }
                                },
                              )),
                      ],
                    );
                  },
                ),
          ],
        ),
      ),
      bottomNavigationBar: widget.event.status != 'completed'
          ? Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: customButton(
                onPressed: _canRegister()
                    ? () async {
                        setState(() => isRegistering = true);
                        try {
                          await markEventAsRSVP(widget.event.id!);
                          setState(() {
                            widget.event.rsvp?.add(id);
                            registered = true;
                          });
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(e.toString())),
                          );
                        } finally {
                          setState(() => isRegistering = false);
                        }
                      }
                    : null,
                label: _getRegistrationButtonLabel(),
                isLoading: isRegistering,
                buttonColor: registered
                    ? Colors.green
                    : _canRegister()
                        ? kPrimaryColor
                        : Colors.grey[400]!,
                sideColor: registered
                    ? Colors.green
                    : _canRegister()
                        ? kPrimaryColor
                        : Colors.grey[400]!,
                fontSize: 16,
              ),
            )
          : null,
    );
  }

  Widget _buildInfoSection(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          content,
          style: const TextStyle(fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildLoactionInfo(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          content,
          style: const TextStyle(fontSize: 12),
        ),
        if (content != '') const SizedBox(height: 8),
        if (content != '')
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: GestureDetector(
              onTap: () {
                openGoogleMaps(widget.event.venue ?? '');
              },
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset(
                  'assets/pngs/eventlocation.png',
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildEventCoordinator() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Event Coordinator',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: ListTile(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            leading: const CircleAvatar(
              child: Icon(
                Icons.person,
                size: 25,
              ),
            ),
            title: Text(
              widget.event.organiserName ?? 'TBA',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            ),
          ),
        )
      ],
    );
  }

  Widget _buildSpeakersSection() {
    if (widget.event.speakers == null || widget.event.speakers!.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Speakers',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: widget.event.speakers!.length,
          itemBuilder: (context, index) {
            final speaker = widget.event.speakers![index];
            return Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                ),
                leading: Container(
                  width: 45,
                  height: 45,
                  child: ClipRRect(
                      borderRadius: BorderRadius.circular(30),
                      child: Image.network(
                        speaker.image ?? '',
                      )),
                ),
                title: Text(
                  widget.event.organiserName ?? 'TBA',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  speaker.role ?? '',
                  style: TextStyle(fontSize: 12),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;

  _SliverAppBarDelegate(this.child);

  @override
  double get minExtent => 48.0; // Standard tab bar height
  @override
  double get maxExtent => 48.0;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Colors.white,
      child: child,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}
