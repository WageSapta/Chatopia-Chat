import 'package:chatopia/utils/extensions.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../utils/get.dart';

class ShimmerFriends extends StatelessWidget {
  final int? length;
  final bool? withSubtitle;
  final bool? justSubtitle;
  final double? heightTitle;
  final double? heightSubtitle;
  final double? widthTitle;
  final double? widthSubtitle;
  const ShimmerFriends({
    Key? key,
    this.length,
    this.withSubtitle = true,
    this.justSubtitle = false,
    this.heightTitle = 16,
    this.heightSubtitle = 16,
    this.widthTitle = 32,
    this.widthSubtitle = 13,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return justSubtitle!
        ? Shimmer.fromColors(
            baseColor: context.isDarkMode
                ? Colors.deepPurple[300]!.withOpacity(.3)
                : Colors.deepPurple[50]!,
            highlightColor:  Colors.deepPurple[100]!,
            child: Container(
              decoration: BoxDecoration(
                  color: context.isDarkMode
                      ? Colors.deepPurple[300]!.withOpacity(.3)
                      : Colors.deepPurple[100]!,
                  borderRadius: BorderRadius.circular(5)),
              height: heightSubtitle,
              width: widthSubtitle,
            ),
          )
        : Shimmer.fromColors(
            baseColor: context.isDarkMode
                ? Colors.deepPurple[300]!.withOpacity(.3)
                : Colors.deepPurple[50]!,
            highlightColor:  Colors.deepPurple[100]!,
            child: ListTile(
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
              leading: CircleAvatar(
                radius: 30,
                backgroundColor: context.isDarkMode
                    ? Colors.deepPurple[300]!.withOpacity(.3)
                    : Colors.deepPurple[100],
              ),
              title: Container(
                margin: EdgeInsets.only(right: Get.width * 0.4),
                decoration: BoxDecoration(
                    color: context.isDarkMode
                        ? Colors.deepPurple[300]!.withOpacity(.3)
                        : Colors.deepPurple[100],
                    borderRadius: BorderRadius.circular(5)),
                height: heightTitle,
                width: widthTitle,
              ),
              subtitle: !withSubtitle!
                  ? null
                  : Container(
                      margin: EdgeInsets.only(right: Get.width * 0.2),
                      decoration: BoxDecoration(
                          color: context.isDarkMode
                              ? Colors.deepPurple[300]!.withOpacity(.3)
                              : Colors.deepPurple[100],
                          borderRadius: BorderRadius.circular(5)),
                      height: heightSubtitle,
                      width: widthSubtitle,
                    ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
  }
}
