import 'package:cached_network_image/cached_network_image.dart';
import 'package:chatopia/utils/extensions.dart';
import 'package:chatopia/utils/get.dart';
import 'package:chatopia/widgets/heading.dart';
import 'package:chatopia/widgets/profile_view.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import '../widgets/shimmer_friends.dart';

class ActivityPage extends StatefulWidget {
  const ActivityPage({Key? key}) : super(key: key);

  @override
  State<ActivityPage> createState() => ActivityPageState();
}

class ActivityPageState extends State<ActivityPage> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Activity"),
          actions: const [
            Padding(
              padding: EdgeInsets.all(8.0),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "slide for opsi",
                    style: TextStyle(fontSize: 10),
                  ),
                  SizedBox(width: 5),
                  Icon(Icons.info_outline_rounded, size: 13),
                ],
              ),
            )
          ],
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Request'),
              Tab(text: 'Waiting'),
              Tab(text: 'Accepted'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            listActivity(),
            listWaiting(),
            listAccepted(),
          ],
        ),
      ),
    );
  }

  StreamBuilder listAccepted() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('chat_rooms')
          .where('is_friend', isEqualTo: true)
          .where('users', arrayContains: Get.user!.id)
          .orderBy("time_created", descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) return Center(child: H5("Error"));
        if (snapshot.connectionState == ConnectionState.waiting) {
          if (snapshot.data == null) {
            return const Center(child: CircularProgressIndicator());
          }
        }
        if (snapshot.data!.docs.isEmpty) {
          return Center(child: H5("no accepted available"));
        }
        return ListView.builder(
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (BuildContext context, int index) {
            QueryDocumentSnapshot<Object?> item = snapshot.data!.docs[index];
            String friendId = (item.get('users') as List)
                .where((e) => e != Get.user!.id)
                .first;
            return StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .doc(friendId)
                  .snapshots(),
              builder: (context, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  if (snap.data == null) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 5.0),
                      child: ShimmerFriends(withSubtitle: false),
                    );
                  }
                }

                return ListTile(
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
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
                              placeholderFadeInDuration:
                                  const Duration(milliseconds: 100),
                              errorWidget: (context, url, error) =>
                                  const Icon(Icons.error),
                            ),
                    ),
                  ),
                  title: H5(snap.data!['name']),
                  trailing: Container(
                    decoration: ShapeDecoration(
                      color: context.isDarkMode
                          ? Colors.green[300]
                          : Colors.green[50],
                      shape: const StadiumBorder(),
                    ),
                    padding:
                        const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "Accepted",
                          style: TextStyle(color: Colors.black),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  StreamBuilder listActivity() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('chat_rooms')
          .where('is_friend', isEqualTo: false)
          .where('users', arrayContains: Get.user!.id)
          .where("request_id", isNotEqualTo: Get.user!.id)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) return Center(child: H5("Error"));
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.data!.docs.isEmpty) {
          return Center(child: H5("no requests available"));
        }
        return ListView.builder(
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (BuildContext context, int index) {
            QueryDocumentSnapshot<Object?> item = snapshot.data!.docs[index];
            String friendId = (item.get('users') as List)
                .where((e) => e != Get.user!.id)
                .first;
            return StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .doc(friendId)
                  .snapshots(),
              builder: (context, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  if (snap.data == null) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 5.0),
                      child: ShimmerFriends(withSubtitle: false),
                    );
                  }
                }
                return Slidable(
                  key: ValueKey(snap.data!.id),
                  endActionPane: ActionPane(
                    motion: const DrawerMotion(),
                    children: [
                      SlidableAction(
                        onPressed: (context) async {
                          await FirebaseFirestore.instance
                              .collection('chat_rooms')
                              .doc(item.id)
                              .update({
                            "is_friend": true,
                            "time_created": FieldValue.serverTimestamp()
                          });
                        },
                        backgroundColor: Colors.deepPurple,
                        foregroundColor: Colors.white,
                        label: 'Accept',
                        padding: const EdgeInsets.all(1.0),
                      ),
                      SlidableAction(
                        onPressed: (context) async {
                          await FirebaseFirestore.instance
                              .collection('chat_rooms')
                              .doc(item.id)
                              .delete();
                        },
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        label: 'Reject',
                      ),
                    ],
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 15),
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
                                placeholderFadeInDuration:
                                    const Duration(milliseconds: 100),
                                errorWidget: (context, url, error) =>
                                    const Icon(Icons.error),
                              ),
                      ),
                    ),
                    title: H5(snap.data!['name']),
                    trailing: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          decoration: ShapeDecoration(
                            color: context.isDarkMode
                                ? Colors.deepPurple[100]
                                : Colors.deepPurple[50],
                            shape: const StadiumBorder(),
                          ),
                          padding: const EdgeInsets.symmetric(
                            vertical: 5,
                            horizontal: 10,
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                "Request",
                                style: TextStyle(color: Colors.black),
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.arrow_back),
                        const Text("•••"),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  StreamBuilder listWaiting() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('chat_rooms')
          .where('is_friend', isEqualTo: false)
          .where('users', arrayContains: Get.user!.id)
          .where("request_id", isEqualTo: Get.user!.id)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) return Center(child: H5("Error"));
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.data!.docs.isEmpty) {
          return Center(child: H5("no waiting available"));
        }
        return ListView.builder(
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (BuildContext context, int index) {
            QueryDocumentSnapshot<Object?> item = snapshot.data!.docs[index];
            String friendId = (item.get('users') as List)
                .where((e) => e != Get.user!.id)
                .first;
            return StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .doc(friendId)
                  .snapshots(),
              builder: (context, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  if (snap.data == null) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 5.0),
                      child: ShimmerFriends(withSubtitle: false),
                    );
                  }
                }
                return Slidable(
                  key: ValueKey(snap.data!.id),
                  endActionPane: ActionPane(
                    motion: const ScrollMotion(),
                    children: [
                      SlidableAction(
                        onPressed: (context) async {
                          await FirebaseFirestore.instance
                              .collection('chat_rooms')
                              .doc(item.id)
                              .delete();
                        },
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        label: 'Cancel',
                      ),
                    ],
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 15),
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
                                placeholderFadeInDuration:
                                    const Duration(milliseconds: 100),
                                errorWidget: (context, url, error) =>
                                    const Icon(Icons.error),
                              ),
                      ),
                    ),
                    title: H5(snap.data!['name']),
                    trailing: SizedBox(
                      height: 50,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            decoration: ShapeDecoration(
                              color: context.isDarkMode
                                  ? Colors.yellow[300]
                                  : Colors.yellow[50],
                              shape: const StadiumBorder(),
                            ),
                            padding: const EdgeInsets.symmetric(
                              vertical: 5,
                              horizontal: 10,
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  "Waiting",
                                  style: TextStyle(color: Colors.black),
                                ),
                              ],
                            ),
                          ),
                          const Icon(Icons.arrow_back),
                          const Text("•••"),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}
