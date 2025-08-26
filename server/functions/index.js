require('dotenv').config(); // .env の読み込み

// 下記自作関数
const { postMessage, postGroupMessage } = require('./modules/post_message');
const { deleteInvitation } = require('./modules/delete_invitation');
const { makeInvitation } = require('./modules/make_invitation');
const { deleteAccount } = require('./modules/delete_account');

// ポストを追加する関数
exports.postMessage = postMessage;

// グループのポストを追加する
exports.postGroupMessage = postGroupMessage;

// 招待を削除
exports.deleteInvitation = deleteInvitation;

// 招待を作成
exports.makeInvitation = makeInvitation;

// アカウント削除
exports.deleteAccount = deleteAccount;