import 'package:flutter/material.dart';
import 'package:cordial/navigation/page_transitions.dart';
import 'package:cordial/data_models/group.dart';
import 'package:cordial/screens/group_page/group_chat_page.dart';

// グループのタイトルウィジェットを返すクラス
class GroupBarWidget extends StatefulWidget {

  final Group groupInfo;

  // 画面遷移のon,off
  final bool translation;

  const GroupBarWidget({super.key, required this.groupInfo,this.translation = true});

  @override
  State<GroupBarWidget> createState() => GroupBarWidgetState();
}

class GroupBarWidgetState extends State<GroupBarWidget> with AutomaticKeepAliveClientMixin {
  @override // スクロールしても状態を保持
  bool get wantKeepAlive => true;

  late final Group _groupInfo;

  @override
  void initState() {
    super.initState();

    _groupInfo = widget.groupInfo;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); //スクロールしても状態を保持

    const double size = 60;

    return Padding(
      padding: const EdgeInsets.only(top: 5, bottom: 5),
      child: SizedBox(
        height: size,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: _groupInfo.backgroundColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            padding: EdgeInsets.zero,
          ),
          onPressed: () {
            if(!widget.translation)return;

            // タップされたらチャットページへ遷移
            PageTransitions.fromRight(onUnderBar: true,targetWidget: GroupChatPage(groupInfo: _groupInfo,), context: context);
          },
          child: Row(
            children: [
              const SizedBox(
                width: 10,
              ),
              Icon(
                _groupInfo.icon,
                color: Colors.white,
                size: size,
              ),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  _groupInfo.name,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
              ),
              const Spacer(), // 余白を埋める
              Text(
                '(${_groupInfo.numPeople})',
                style: const TextStyle(
                    fontSize: 13,
                    //color: Theme.of(context).colorScheme.onPrimary,
                    color: Colors.white
                ),
              ),
              const SizedBox(
                width: 10,
              ),
            ],
          ),
        ),
      ),
    );
  }

}
