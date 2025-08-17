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
      color: Colors.transparent,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          Row(
            children: [
              // 左側のHOMEボタン
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly ,
                  children: [
                    IconButton(
                      padding: const EdgeInsets.symmetric(horizontal: 17),
                      tooltip: 'HOME',
                      icon: Icon(
                        Icons.home,
                        size: 35,
                        color: currentIndex == 0
                            ? Theme.of(context).colorScheme.tertiaryContainer
                            : Theme.of(context).colorScheme.onSurface,
                      ),
                      onPressed: () => onTap(0),
                    ),
                    IconButton(
                      padding: const EdgeInsets.symmetric(horizontal: 17),
                      tooltip: 'GROUP',
                      icon: Icon(
                        Icons.emoji_events,
                        size: 35,
                        color: currentIndex == 1
                            ? Theme.of(context).colorScheme.tertiaryContainer
                            : Theme.of(context).colorScheme.onSurface,
                      ),
                      onPressed: () => onTap(1),
                    ),
                  ],
                ),
              ),

              // 中央のスペース
              const SizedBox(width: 60),

              // 右側のGROUPとPROFILEボタン
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly ,
                  children: [
                    IconButton(
                      padding: const EdgeInsets.symmetric(horizontal: 17),
                      tooltip: 'GROUP',
                      icon: Icon(
                        Icons.group,
                        size: 35,
                        color: currentIndex == 2
                            ? Theme.of(context).colorScheme.tertiaryContainer
                            : Theme.of(context).colorScheme.onSurface,
                      ),
                      onPressed: () => onTap(2),
                    ),
                    IconButton(
                      padding: const EdgeInsets.symmetric(horizontal: 17),
                      tooltip: 'PROFILE',
                      icon: Icon(
                        Icons.person,
                        size: 35,
                        color: currentIndex == 3
                            ? Theme.of(context).colorScheme.tertiaryContainer
                            : Theme.of(context).colorScheme.onSurface,
                      ),
                      onPressed: () => onTap(3),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 0),
            child: FloatingActionButton(
              backgroundColor: Theme.of(context).colorScheme.tertiary,
              tooltip: 'POST',
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
