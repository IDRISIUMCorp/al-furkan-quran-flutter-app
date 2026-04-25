import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

/// Shimmer loading skeleton for the content feed.
/// تأثير تحميل نظيف ومتناسق مع تصميم الكروت
class ContentFeedShimmer extends StatelessWidget {
  const ContentFeedShimmer({super.key, this.itemCount = 4});

  final int itemCount;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = isDark ? const Color(0xFF2A2A2A) : const Color(0xFFEEEEEE);
    final highlightColor = isDark ? const Color(0xFF333333) : const Color(0xFFF8F8F8);

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (_, index) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
          child: Shimmer.fromColors(
            baseColor: baseColor,
            highlightColor: highlightColor,
            child: Container(
              decoration: BoxDecoration(
                color: baseColor,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Thumbnail placeholder
                  if (index.isEven)
                    Container(
                      height: 180,
                      decoration: BoxDecoration(
                        color: baseColor,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(16),
                          topRight: Radius.circular(16),
                        ),
                      ),
                    ),

                  // Text placeholders
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        // Title line
                        Container(
                          height: 14,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: baseColor,
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                        const SizedBox(height: 10),
                        // Body line 1
                        Container(
                          height: 12,
                          width: MediaQuery.of(context).size.width * 0.7,
                          decoration: BoxDecoration(
                            color: baseColor,
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                        const SizedBox(height: 8),
                        // Body line 2
                        Container(
                          height: 12,
                          width: MediaQuery.of(context).size.width * 0.5,
                          decoration: BoxDecoration(
                            color: baseColor,
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Interaction row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              height: 10,
                              width: 60,
                              decoration: BoxDecoration(
                                color: baseColor,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                            Row(
                              children: [
                                Container(
                                  height: 20,
                                  width: 20,
                                  decoration: BoxDecoration(
                                    color: baseColor,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Container(
                                  height: 20,
                                  width: 20,
                                  decoration: BoxDecoration(
                                    color: baseColor,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        childCount: itemCount,
      ),
    );
  }
}

/// Shimmer for the category filter chips.
class CategoryChipsShimmer extends StatelessWidget {
  const CategoryChipsShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = isDark ? const Color(0xFF2A2A2A) : const Color(0xFFEEEEEE);
    final highlightColor = isDark ? const Color(0xFF333333) : const Color(0xFFF8F8F8);

    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: 5,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, index) => Shimmer.fromColors(
          baseColor: baseColor,
          highlightColor: highlightColor,
          child: Container(
            width: 75 + (index % 3) * 10.0,
            decoration: BoxDecoration(
              color: baseColor,
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
    );
  }
}
