import 'package:flutter/material.dart';
import 'package:cordial/widgets/timeline_widget.dart';
import 'package:cordial/enums/ranking_type.dart';

// 投稿のタイムラインを表示する画面
class RankingPage extends StatefulWidget {
  const RankingPage({super.key});

  @override
  State<RankingPage> createState() => RankingPageState();
}

class RankingPageState extends State<RankingPage>
    with SingleTickerProviderStateMixin {
  // タブ切り替え用のコントローラー
  late TabController _tabController;
  final ScrollController _weeklyScrollController = ScrollController();
  final ScrollController _totalScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _weeklyScrollController.dispose();
    _totalScrollController.dispose();
    super.dispose();
  }

  // 画面をリロード
  int _weeklyKey = 0;
  int _totalKey = 0;

  Future<void> _reloadWeekly() async {
    setState(() => _weeklyKey++);
  }

  Future<void> _reloadTotal() async {
    setState(() => _totalKey++);
  }

  // 親から呼ぶ(下部バーアイコンを再度タップしたらスクロールを戻すため)
  void scrollToTop() {
    switch(_tabController.index){
      case 0:
        _weeklyScrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      case 1:
        _totalScrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('「いいね！」ランキング'),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Theme.of(context).colorScheme.tertiaryContainer,
          labelColor: Theme.of(context).colorScheme.tertiaryContainer,
          tabs: const [
            Tab(text: '週間ランキング'),
            Tab(text: '総合ランキング'),
          ],
          onTap: (index) {
            // すでに選択中のタブがタップされた場合のみスクロールを一番上に戻す
            if (_tabController.index == index) {
              switch (index) {
                case 0:
                  _weeklyScrollController.animateTo(
                    0.0,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOut,
                  );
                  break;
                case 1:
                  _totalScrollController.animateTo(
                    0.0,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOut,
                  );
                  break;
              }
            }
          },
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // 週間ランキング
          RefreshIndicator(
            color: Theme.of(context).colorScheme.tertiary,
            onRefresh: _reloadWeekly,
            child: CustomScrollView(
              controller: _weeklyScrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                TimelineWidget(
                    key: ValueKey(_weeklyKey),
                    parentScrollController: _weeklyScrollController,
                    rankingType: RankingType.weekly),
                const SliverToBoxAdapter(child: SafeArea(child: SizedBox())),
              ],
            ),
          ),

          // 総合ランキング
          RefreshIndicator(
            color: Theme.of(context).colorScheme.tertiary,
            onRefresh: _reloadTotal,
            child: CustomScrollView(
              controller: _totalScrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                TimelineWidget(
                    key: ValueKey(_totalKey),
                    parentScrollController: _totalScrollController,
                    rankingType: RankingType.total),
                const SliverToBoxAdapter(child: SafeArea(child: SizedBox())),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
