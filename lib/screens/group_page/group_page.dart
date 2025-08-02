import 'package:cordial/services/database_read.dart';
import 'package:flutter/material.dart';
import 'package:cordial/data_models/group.dart';
import 'package:cordial/widgets/custom_appbar.dart';
import 'package:cordial/screens/group_page/widget/group_bar_widget.dart';
import 'package:cordial/screens/group_page/make_group_page.dart';
import 'package:cordial/navigation/page_transitions.dart';

// グループ一覧を表示する関数
class GroupPage extends StatefulWidget {
  const GroupPage({super.key});

  @override
  State<GroupPage> createState() => GroupPageState();
}

class GroupPageState extends State<GroupPage> {

  @override
  void initState() {
    super.initState();

    // グループを取得
    fetchGroups();
  }

  // 所属グループ一覧を入れておく変数
  List<Group>? _groups;

  // 所属グループを取得
  Future<void> fetchGroups() async {
    // 非同期でグループ取得
    final groups = await DatabaseRead.joinedGroups();

    setState(() {
      _groups = groups;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 10, right: 10),
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          CustomAppbar(
            titleText: "グループ",
            leading: IconButton(
              icon: Icon(Icons.menu,
                  color: Theme.of(context).colorScheme.onSurface),
              onPressed: () {},
            ),
            actions: [
              IconButton(
                icon: Icon(
                  Icons.add,
                  color: Theme.of(context).colorScheme.onSurface,
                  size: 27,
                ),
                onPressed: () async{
                  await PageTransitions.fromBottom(
                      targetWidget: const MakeGroupPage(), context: context);

                  // グループを作成したのちは再読込
                  fetchGroups();
                },
              ),
            ],
          ),

          SliverToBoxAdapter(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 400),
              switchInCurve: Curves.easeOut,
              switchOutCurve: Curves.easeIn,
              transitionBuilder: (child, animation) {
                return FadeTransition(
                  opacity: animation,
                  child: child,
                );
              },
              child: _groupListWidget(),
            ),
          ),

          const SliverToBoxAdapter(
            child: SafeArea(child: SizedBox()),
          ),
        ],
      ),
    );
  }

  Widget _groupListWidget() {
    if (_groups != null) {
      return Column(
        key: ValueKey(_groups!.length), // 👈違うときにアニメが発動！
        children: List.generate(
          _groups!.length,
              (index) => GroupBarWidget(groupInfo: _groups![index]),
        ),
      );
    } else {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }
  }
}
