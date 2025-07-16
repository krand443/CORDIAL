import 'package:flutter/material.dart';
import 'package:cordial/navigation/page_transitions.dart';
import '../screens/make_post_page.dart';

class UnderBar extends StatelessWidget {
  final int currentIndex;
  final void Function(int) onTap;

  const UnderBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.surface.withOpacity(0.7),
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              IconButton(
                padding: const EdgeInsets.only(left: 30, right: 30),
                tooltip: 'HOME',
                icon: Icon(
                  Icons.home,
                  size: 40,
                  color: currentIndex == 0
                      ? Theme.of(context).colorScheme.tertiaryContainer
                      : Theme.of(context).colorScheme.onSurface,
                ),
                onPressed: () => onTap(0),
              ),
              const SizedBox(width: 10.0), // 中央余白
              IconButton(
                padding: const EdgeInsets.only(left: 30, right: 30),
                tooltip: 'PROFILE',
                icon: Icon(
                  Icons.person,
                  size: 40,
                  color: currentIndex == 1
                      ? Theme.of(context).colorScheme.tertiaryContainer
                      : Theme.of(context).colorScheme.onSurface,
                ),
                onPressed: () => onTap(1),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 0),
            child: FloatingActionButton(
              backgroundColor: Theme.of(context).colorScheme.tertiary,
              tooltip: '投稿を作成',
              onPressed: () {
                // 下から投稿画面を表示
                PageTransitions.fromBottom(
                    targetWidget: const MakePostPage(), context: context);
              },
              child: const Icon(Icons.add),
            ),
          ),
        ],
      ),
    );
  }
}
