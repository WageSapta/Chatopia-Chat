import 'package:chatopia/utils/extensions.dart';
import 'package:chatopia/utils/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:intl/intl.dart';
import 'package:linkify/linkify.dart';
import 'package:url_launcher/url_launcher.dart';

class MyMessageCard extends StatefulWidget {
  final int? index;
  final List<DocumentSnapshot<Object?>> messages;
  const MyMessageCard({
    Key? key,
    required this.index,
    required this.messages,
  }) : super(key: key);

  @override
  State<MyMessageCard> createState() => _MyMessageCardState();
}

class _MyMessageCardState extends State<MyMessageCard> {
  bool visible = false;

  Future<void> _onOpen(LinkableElement link) async {
    if (!await launchUrl(
      Uri.parse(link.url),
      mode: LaunchMode.externalApplication,
    )) {
      throw Exception('Could not launch ${link.url}');
    }
  }

  @override
  Widget build(BuildContext context) {
    var message = widget.messages[widget.index!].get("message");
    var time = DateFormat.Hm()
        .format((widget.messages[widget.index!].get("timestamp")).toDate());
    var senderId = widget.messages[widget.index!].get("senderId");
    bool isRead = widget.messages[widget.index!].get("isRead");
    return Column(
      key: ValueKey(widget.index),
      children: [
        Visibility(
          visible: gap(),
          child: const SizedBox(height: 10),
        ),
        Row(
          mainAxisAlignment: senderId == Get.user!.id
              ? MainAxisAlignment.end
              : MainAxisAlignment.start,
          children: [
            Visibility(
              visible: senderId == Get.user!.id,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 5),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          time,
                          style: const TextStyle(
                            fontSize: 10,
                          ),
                        ),
                        const SizedBox(width: 5),
                        Visibility(
                          visible: isRead,
                          child: const Icon(
                            Icons.done_all_rounded,
                            color: Colors.deepPurple,
                            size: 18,
                          ),
                        )
                      ],
                    ),
                  ),
                  Container(
                    constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width * 0.65),
                    margin: const EdgeInsets.only(
                        top: 2, bottom: 2, left: 5, right: 10),
                    padding:
                        const EdgeInsets.symmetric(vertical: 7, horizontal: 10),
                    decoration: const BoxDecoration(
                      color: Colors.deepPurple,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                        bottomLeft: Radius.circular(20),
                        bottomRight: Radius.zero,
                      ),
                    ),
                    child: Linkify(
                      linkStyle: const TextStyle(
                        decoration: TextDecoration.none,
                      ),
                      textAlign: TextAlign.left,
                      style: const TextStyle(color: Colors.white),
                      text: message,
                      onOpen: _onOpen,
                      options: const LinkifyOptions(humanize: false),
                      linkifiers: const [
                        UrlLinkifier(),
                        EmailLinkifier(),
                        PhoneNumberLinkifier(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Visibility(
              visible: !(senderId == Get.user!.id),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width * 0.65),
                    margin: const EdgeInsets.only(
                        top: 2, bottom: 2, left: 10, right: 5),
                    padding:
                        const EdgeInsets.symmetric(vertical: 7, horizontal: 10),
                    decoration: BoxDecoration(
                      color: context.isDarkMode
                          ? Colors.deepPurple[200]!.withOpacity(.1)
                          : Colors.deepPurple[100]!.withOpacity(.3),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                        bottomLeft: Radius.zero,
                        bottomRight: Radius.circular(20),
                      ),
                    ),
                    child: Linkify(
                      linkStyle: const TextStyle(
                        decoration: TextDecoration.none,
                      ),
                      text: message,
                      textAlign: TextAlign.left,
                      onOpen: _onOpen,
                      options: const LinkifyOptions(humanize: false),
                      linkifiers: const [
                        UrlLinkifier(),
                        EmailLinkifier(),
                        PhoneNumberLinkifier(),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 5),
                    child: Text(
                      time,
                      style: const TextStyle(
                        fontSize: 10,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  String convert(Timestamp timestamp) {
    return DateFormat("dd/MM/yy").format(timestamp.toDate());
  }

  bool gap() {
    if (widget.index! + 1 != widget.messages.length && !isDifferentDay()) {
      var senderCurrentItem = widget.messages[widget.index!].get("senderId");
      var senderItemNext = widget.messages[widget.index! + 1]['senderId'];
      if ((senderCurrentItem == Get.user!.id &&
              senderItemNext != Get.user!.id) ||
          (senderCurrentItem != Get.user!.id &&
              senderItemNext == Get.user!.id)) {
        return true;
      }
    }
    return false;
  }

  bool isDifferentDay() {
    if (widget.index! == widget.messages.length - 1) {
      visible = true;
    } else {
      var currentItem = widget.messages[widget.index!];
      var itemNext = widget.messages[widget.index! + 1];
      if (convert(currentItem.get("timestamp")) !=
          convert(itemNext.get("timestamp"))) {
        visible = true;
      }
    }
    setState(() {});
    return visible;
  }
}
