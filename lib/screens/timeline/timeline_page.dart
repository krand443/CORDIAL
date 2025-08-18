import 'package:flutter/material.dart';
import 'package:cordial/widgets/timeline_widget.dart';
import 'package:cordial/widgets/custom_appbar.dart';
import 'package:cordial/screens/timeline/timeline_menu.dart';
import 'package:cordial/navigation/page_transitions.dart';

// 投稿のタイムラインを表示する画面
class TimelinePage extends StatefulWidget {
  const TimelinePage({super.key});

  @override
  TimelinePageState createState() => TimelinePageState();
}

class TimelinePageState extends State<TimelinePage> {
  // 最後までスクロールをしたときに投稿を追加するためのコントローラー
  final ScrollController _scrollController = ScrollController();

  // 親から呼ぶ(下部バーアイコンを再度タップしたらスクロールを戻すため)
  void scrollToTop() {
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  // 画面をリロード
  int _screenKey = 0;

  // 画面をリロード
  Future _reload() async {
    setState(() => _screenKey++);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 投稿一覧
      body: RefreshIndicator(
        color: Theme.of(context).colorScheme.tertiary,
        onRefresh: _reload,
        child: CustomScrollView(
          controller: _scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            CustomAppbar(
              onTap: () {
                _scrollController.animateTo(
                  0.0,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOut,
                );
              },
              titleText: 'タイムライン',
              leading: IconButton(
                icon: Icon(Icons.menu,
                    color: Theme.of(context).colorScheme.onSurface),
                onPressed: () {
                  PageTransitions.fromLeft(
                      onUnderBar: true,
                      targetWidget: const TimelineMenu(),
                      context: context);
                },
              ),
            ),

            // タイムラインをリストで取得する
            TimelineWidget(
                key: ValueKey(_screenKey),
                parentScrollController: _scrollController),

            const SliverToBoxAdapter(
              child: SafeArea(child: SizedBox()),
            ),
          ],
        ),
      ),
    );
  }
}
