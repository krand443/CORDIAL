import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

// グループ一つの情報を扱うデータ構造
class Group
{
  // グループid
  final String id;

  // グループ名
  String name;

  // リーダーのid
  String leaderId;

  // アイコン(flutterのIconを使用する)
  IconData icon;

  // 背景色
  Color backgroundColor;

  // グループ内人数
  int numPeople;

  // ラストアクション時間
  Timestamp? lastAction;

  Group({
    required this.id,
    required this.name,
    required this.leaderId,
    required this.icon,
    required this.backgroundColor,
    required this.numPeople,
    required this.lastAction,
  });
}