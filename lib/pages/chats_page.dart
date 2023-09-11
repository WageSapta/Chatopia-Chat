import 'dart:async';
import 'dart:developer';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:chatopia/core.dart';
import 'package:chatopia/utils/extensions.dart';
import 'package:chatopia/widgets/profile_view.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:provider/provider.dart';

class ChatsPage extends StatefulWidget {
  const ChatsPage({Key? key}) : super(key: key);

  @override
  State<ChatsPage> createState() => _ChatsPageState();
}

class _ChatsPageState extends State<ChatsPage> {
  InternetStatus? internetStatus;
  StreamSubscription<InternetStatus>? listener;

  @override
  void initState() {
    super.initState();
    listener =
        InternetConnection().onStatusChange.listen((InternetStatus status) {
      setState(() {
        internetStatus = status;
      });
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Map<String, dynamic>? arguments =
          (ModalRoute.of(context)?.settings.arguments) as Map<String, dynamic>?;
      if (arguments != null) {
        log("NAVIGATE TO ${arguments['name']} CHAT");
        Screen.toNamed(
          Routes.messages,
          arguments: {
            "room_id": arguments['room_id'],
            "friend_id": arguments['friend_id'],
            "name": arguments['name'],
            "profile": arguments['profile'],
            "push_token": arguments['push_token'],
          },
        );
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    listener!.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ChatsProvider>(
      builder: (context, chats, child) {
        return Scaffold(
          appBar: AppBar(
            title: H2("Chatopia"),
            actions: [
              IconButton(
                onPressed: () async {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    builder: (context) => Padding(
                      padding: EdgeInsets.only(
                          bottom: Get.mediaQuery.viewInsets.bottom),
                      child: const AddBottomSheet(),
                    ),
                  );
                },
                icon: const Icon(Icons.person_add),
              ),
              const SizedBox(width: 5),
            ],
          ),
          drawer: const MyDrawer(),
          body: internetStatus == InternetStatus.disconnected
              ? Center(
                  child: H5("no internet"),
                )
              : StreamBuilder(
                  stream: FirebaseFirestore.instance
                      .collection('chat_rooms')
                      .where('is_friend', isEqualTo: true)
                      .where('users', arrayContains: Get.user!.id)
                      .orderBy('last_message_time', descending: true)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) return Center(child: H3("Error"));
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      if (snapshot.data == null) {
                        return const Center(child: CircularProgressIndicator.adaptive());
                      }
                    }
                    List<QueryDocumentSnapshot<Map<String, dynamic>>> friends =
                        snapshot.data!.docs
                            .where((e) =>
                                e.get("last_message") != null &&
                                e.get("last_message_time") != null)
                            .toList();

                    if (snapshot.data!.docs.isEmpty || friends.isEmpty) {
                      return Center(child: H5("Chat not available"));
                    }
                    return ListView.separated(
                      padding: const EdgeInsets.all(20.0),
                      shrinkWrap: true,
                      itemCount: friends.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 10),
                      itemBuilder: (BuildContext context, int i) {
                        var friendId = (friends[i]["users"] as List)
                            .where((e) => e != Get.user!.id)
                            .first;
                        return StreamBuilder<DocumentSnapshot>(
                          stream: FirebaseFirestore.instance
                              .collection("users")
                              .doc(friendId)
                              .snapshots(),
                          builder: (context, snap) {
                            if (snap.connectionState ==
                                ConnectionState.waiting) {
                              if (snap.data == null) {
                                return const ShimmerFriends();
                              }
                            }

                            List unRead = (snap.data!['unread_messages']
                                    as List)
                                .where((e) => e['receiverId'] == Get.user!.id)
                                .toList();

                            return ListTile(
                              key: ValueKey(friends[i].id),
                              onTap: () async {
                                Screen.toNamed(
                                  Routes.messages,
                                  arguments: {
                                    "room_id": friends[i].id,
                                    "friend_id": snap.data!.id,
                                    "name": snap.data!['name'],
                                    "profile": snap.data!['profile'] ?? "",
                                    "push_token": snap.data!['push_token'],
                                  },
                                );
                              },
                              tileColor: context.isDarkMode
                                  ? Colors.deepPurple[200]!.withOpacity(.1)
                                  : Colors.deepPurple[50]!.withOpacity(.5),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 15,
                                vertical: 5,
                              ),
                              leading: ProfileView(
                                child: CircleAvatar(
                                  radius: 30,
                                  child: snap.data!['profile'].isEmpty
                                      ? LayoutBuilder(
                                          builder: (context, constraints) {
                                            return Icon(
                                              Icons.person_rounded,
                                              size: constraints.maxWidth / 2.5,
                                            );
                                          },
                                        )
                                      : CachedNetworkImage(
                                          imageUrl: snap.data!['profile'],
                                          fadeInCurve: Curves.easeIn,
                                          fadeOutCurve: Curves.easeOut,
                                          imageBuilder:
                                              (context, imageProvider) =>
                                                  Container(
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              image: DecorationImage(
                                                image: imageProvider,
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                          ),
                                          placeholderFadeInDuration:
                                              const Duration(milliseconds: 100),
                                          errorWidget: (context, url, error) =>
                                              const Icon(Icons.error),
                                        ),
                                ),
                              ),
                              title: H5(snap.data!['name'],
                                  fontWeight: FontWeight.w600),
                              subtitle: StreamBuilder(
                                stream: friends[i]
                                    .reference
                                    .collection("messages")
                                    .orderBy("timestamp", descending: true)
                                    .limit(1)
                                    .snapshots(),
                                builder: (context, shot) {
                                  if (shot.connectionState ==
                                      ConnectionState.waiting) {
                                    if (shot.data == null) {
                                      return const ShimmerFriends(
                                          justSubtitle: true);
                                    }
                                  }

                                  return shot.data == null
                                      ? const ShimmerFriends(justSubtitle: true)
                                      : Row(
                                          children: [
                                            Visibility(
                                              visible: shot.data!.docs.first
                                                      .data()["isRead"] &&
                                                  shot.data!.docs.first
                                                          .data()['senderId'] ==
                                                      Get.user!.id,
                                              child: const Row(
                                                children: [
                                                  Icon(
                                                    Icons.done_all_rounded,
                                                    size: 18,
                                                    color: Colors.deepPurple,
                                                  ),
                                                  SizedBox(width: 5),
                                                ],
                                              ),
                                            ),
                                            Expanded(
                                                child: H6(shot.data!.docs.first
                                                    .get("message"))),
                                          ],
                                        );
                                },
                              ),
                              trailing: Container(
                                margin: const EdgeInsets.symmetric(vertical: 7),
                                child: Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(Get.setTime(
                                        timestamp: friends[i]
                                            ['last_message_time'])),
                                    if (unRead.isEmpty)
                                      const SizedBox()
                                    else
                                      Container(
                                        height: 23,
                                        width: 23,
                                        padding: const EdgeInsets.all(3.0),
                                        decoration: const ShapeDecoration(
                                          color: Colors.deepPurple,
                                          shape: CircleBorder(),
                                        ),
                                        child: FittedBox(
                                          fit: BoxFit.scaleDown,
                                          child: Text(
                                            "${unRead.length}",
                                            maxLines: 1,
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 13,
                                            ),
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            );
                          },
                        );
                      },
                    );
                  },
                ),
        );
      },
    );
  }
}
