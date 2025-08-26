const { getAuth } = require("firebase-admin/auth");

// Firebaseの管理者機能を有効化
const admin = require('firebase-admin');

//リクエストの認証をしてトークンを返す関数
async function certification(req, res){

  // すでに初期化されていなければ初期化
  if (!admin.apps.length) {
    admin.initializeApp();
  }

  //リクエストがPostでないならエラー
  if (req.method !== "POST") {
    return res.status(405).send("Method Not Allowed");
  }

  //ヘッダーにユーザーIDトークンが含まれているなら
  const authHeader = req.headers.authorization;
  if (!authHeader || !authHeader.startsWith("Bearer:")) {
    return res.status(401).send("Unauthorized: No token provided");
  }
    
  //トークンを取り出す
  const idToken = authHeader.split("Bearer:")[1];

  //トークンでベアラー認証
  let decodedToken;
  try {
    //認証成功でトークンを返す
    decodedToken = await getAuth().verifyIdToken(idToken);
    return decodedToken;
  } catch (error) {
    console.error("Token verification failed", error);
    return null;
  }
  
}

module.exports = { certification };
