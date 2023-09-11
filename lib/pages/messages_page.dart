import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chatopia/utils/extensions.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../core.dart';

class MessagesPage extends StatefulWidget {
  const MessagesPage({
    Key? key,
  }) : super(key: key);

  @override
  State<MessagesPage> createState() => _MessagesPageState();
}

class _MessagesPageState extends State<MessagesPage> {
  final firestore = FirebaseFirestore.instance;
  ScrollController scrollController = ScrollController();
  MessageProvider? _msgProvider;
  String roomId = "";
  String friendId = "";
  bool friendIsOnline = false;

  @override
  Widget build(BuildContext context) {
    final arguments =
        (ModalRoute.of(context)!.settings.arguments) as Map<String, dynamic>;
    return Consumer<MessageProvider>(
      builder: (context, value, child) {
        return Scaffold(
          key: ValueKey(roomId),
          appBar: AppBar(
            leadingWidth: 85,
            leading: Row(
              children: [
                const SizedBox(width: 10),
                InkWell(
                  customBorder: const StadiumBorder(),
                  onTap: () => Screen.back(),
                  child: Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Row(
                      children: [
                        const Icon(Icons.arrow_back),
                        const SizedBox(width: 5),
                        CircleAvatar(
                          radius: 18,
                          child: arguments['profile'].isEmpty
                              ? LayoutBuilder(
                                  builder: (context, constraints) {
                                    return Icon(
                                      Icons.person_rounded,
                                      size: constraints.maxWidth / 2,
                                    );
                                  },
                                )
                              : CachedNetworkImage(
                                  imageUrl: arguments['profile'],
                                  imageBuilder: (context, imageProvider) =>
                                      Container(
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      image: DecorationImage(
                                        image: imageProvider,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                  errorWidget: (context, url, error) =>
                                      const Icon(Icons.error),
                                ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            title: StreamBuilder(
              stream: firestore
                  .collection("users")
                  .doc(arguments['friend_id'])
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  if (snapshot.data == null) {
                    if (arguments['name'] == null) {
                      return const Column(
                        children: [
                          ShimmerFriends(
                            justSubtitle: true,
                            widthSubtitle: 90,
                            heightSubtitle: 16,
                          ),
                          SizedBox(height: 10),
                          ShimmerFriends(
                            justSubtitle: true,
                            widthSubtitle: 50,
                            heightSubtitle: 12,
                          ),
                        ],
                      );
                    }
                    return H4(arguments['name'], fontWeight: FontWeight.w600);
                  }
                }
                return snapshot.data == null
                    ? H4(arguments['name'], fontWeight: FontWeight.w600)
                    : Column(
                        children: [
                          H4(snapshot.data!.get("name"),
                              fontWeight: FontWeight.w600),
                          H7(value.friendIsOnline
                              ? "online"
                              : "last seen ${Get.timeAgo((snapshot.data!.get("last_seen") as Timestamp).toDate())}")
                        ],
                      );
              },
            ),
            actions: [
              IconButton(
                onPressed: () {
                  toDown();
                },
                icon: const Icon(Icons.keyboard_double_arrow_down_rounded),
              ),
            ],
          ),
          body: Column(
            children: [
              if (value.isLoading)
                const Expanded(
                  child: Center(
                    child: CircularProgressIndicator.adaptive(),
                  ),
                )
              else
                Expanded(
                  child: ListView.builder(
                    itemCount: value.messages.length + (value.hasMore ? 1 : 0),
                    reverse: true,
                    controller: scrollController,
                    itemBuilder: (context, i) {
                      if (value.messages.length > i) {
                        String convert(Timestamp timestamp) {
                          return DateFormat("dd/MM/y")
                              .format(timestamp.toDate());
                        }

                        bool visible = false;
                        if (i == value.messages.length - 1) {
                          visible = true;
                        } else {
                          var currentItem = value.messages[i];
                          var itemBefore = value.messages[i + 1];
                          if (convert(currentItem.get("timestamp")) !=
                              convert(itemBefore.get("timestamp"))) {
                            visible = true;
                          }
                        }
                        var data =
                            value.messages[i].data() as Map<String, dynamic>;
                        return Column(
                          children: [
                            if (visible)
                              Container(
                                padding: const EdgeInsets.all(8),
                                margin:
                                    const EdgeInsets.only(bottom: 10, top: 10),
                                decoration: ShapeDecoration(
                                  color: context.isDarkMode
                                      ? Colors.black26
                                      : Colors.black12,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10)),
                                ),
                                child: Text(
                                  Get.setTime(
                                    timestamp: data['timestamp'],
                                    isMsg: true,
                                  ),
                                  style: const TextStyle(fontSize: 10),
                                ),
                              ),
                            MyMessageCard(messages: value.messages, index: i),
                          ],
                        );
                      } else if (value.hasMore) {
                        return const Padding(
                          padding: EdgeInsets.all(8),
                          child: Center(
                            child: SizedBox(
                              height: 30,
                              width: 30,
                              child: CircularProgressIndicator.adaptive(),
                            ),
                          ),
                        );
                      }
                      return null;
                    },
                  ),
                ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Flexible(
                      child: Container(
                        constraints:
                            BoxConstraints(maxHeight: Get.height * 0.20),
                        child: MyTextField(
                          hintText: "message",
                          maxLines: null,
                          controller: value.textController,
                          keyboardType: TextInputType.multiline,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton.filled(
                      padding: const EdgeInsets.all(15.0),
                      icon: Icon(
                        value.loadingMsg ? Icons.sync : Icons.send_rounded,
                      ),
                      onPressed: () async {
                        if (!(await InternetConnection().hasInternetAccess)) {
                          Get.fToastShow("No internet");
                        } else {
                          if (value.textController.text.isNotEmpty &&
                              !value.loadingMsg) {
                            toDown();
                            String msg = value.textController.text;
                            await value.sendMessage(
                              arguments['room_id'],
                              arguments['friend_id'],
                            );
                            await FcmService.pushNotification(
                              token: arguments['push_token'],
                              data: {
                                'screen': Routes.messages,
                                'title': Get.user!.name,
                                'body': msg,
                                "room_id": arguments['room_id'],
                                "friend_id": Get.user!.id,
                                "profile": Get.user!.profile,
                                "push_token": Get.user!.pushToken,
                              },
                            );
                          }
                        }
                      },
                    ),
                  ],
                ),
              )
            ],
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    super.dispose();
    log("DISPOSE");
    scrollController.removeListener(_scrollListener);
    scrollController.dispose();
    _msgProvider!.subscriptionChats?.cancel();
    _msgProvider!.messages.clear();
    _msgProvider!.textController.clear();
    _msgProvider!.unreadMessages.clear();
    _msgProvider!.setInChat(roomId: roomId, inChat: false);
  }

  @override
  void initState() {
    log("INITSTATE");
    Get.fToast.init(context);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final arguments =
          ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>;
      _msgProvider = context.read<MessageProvider>();
      roomId = arguments['room_id'];
      friendId = arguments['friend_id'];
      if (_msgProvider!.isLoading ||
          _msgProvider!.hasMore ||
          scrollController.hasClients) {
        _msgProvider!.isLoading = false;
        _msgProvider!.hasMore = false;
        scrollController.dispose();
        _msgProvider!.messages.clear();
        _msgProvider!.textController.clear();
        _msgProvider!.unreadMessages.clear();
        scrollController = ScrollController();
      }
      setState(() {});
      if (_msgProvider!.subscriptionChats != null) {
        _msgProvider!.subscriptionChats?.cancel();
      }
      scrollController.addListener(_scrollListener);
      // _deleteNotification(arguments['friend_id']);
      _msgProvider!.streamOnlineFriend(arguments['friend_id']);
      _msgProvider!.setInChat(roomId: arguments['room_id'], inChat: true);
      _msgProvider!.subscribeToChatMessages(
          arguments['room_id'], arguments['friend_id'], scrollController);
      await _msgProvider!.updateReadMessagesForReceiverId(
          arguments['room_id'], arguments['friend_id']);
      await _msgProvider!
          .getMoreMessages(arguments['room_id'], arguments['friend_id']);
    });
    super.initState();
  }

  toDown() {
    scrollController.jumpTo(scrollController.position.minScrollExtent);
  }

  _scrollListener() async {
    if (scrollController.position.pixels ==
        scrollController.position.maxScrollExtent) {
      await _msgProvider!.getMoreMessages(roomId, friendId);
    }
  }
}
