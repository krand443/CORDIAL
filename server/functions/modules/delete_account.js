const { onRequest } = require("firebase-functions/v2/https");
const { getFirestore, FieldValue } = require("firebase-admin/firestore");
const { getAuth } = require("firebase-admin/auth");
const { getStorage } = require("firebase-admin/storage");
const { certification } = require("./certification");

const db = getFirestore();
const auth = getAuth();
const storage = getStorage();

exports.deleteAccount = onRequest(
  { region: "asia-northeast1" },
  async (req, res) => {
    res.set("Access-Control-Allow-Origin", "https://ruten-studio.sakura.ne.jp");
    res.set("Access-Control-Allow-Methods", "POST, OPTIONS");
    res.set("Access-Control-Allow-Headers", "Content-Type, Authorization");

    if (req.method === "OPTIONS") {
      return res.status(204).send();
    }

    // 認証
    const decodedToken = await certification(req, res);
    if (!decodedToken) {
      return res.status(401).json({ error: "Unauthorized: Invalid token" });
    }
    const uid = decodedToken.uid;

    try {
      // 投稿削除
      await deleteAllPostsByUserId(uid);

      // フォロー関係削除
      await deleteAllFollowRelations(uid);

      // グループ削除・退出
      await deleteAllGroupRelations(uid);

      // プロフィール削除
      await deleteUserProfile(uid);

      // 画像ファイル削除
      await deleteAllUserImages(uid);

      // ユーザー本体削除
      await deleteUserDocument(uid);

      // Refresh Token をすべて失効させる
      await auth.revokeRefreshTokens(uid);

      // Firestoreの削除が成功したらAuth削除
      await auth.deleteUser(uid);

      console.log(`✅ ユーザー ${uid} と関連データを完全削除しました`);
      res.status(200).json({ message: "Account deleted successfully" });
    } catch (error) {
      console.error("❌ ユーザー削除中にエラー:", error);
      res.status(500).json({ error: "Internal server error" });
    }
  },
);

//ユーザーの投稿を500件ずつバッチで削除
async function deleteAllPostsByUserId(uid) {
  let lastDoc = null;
  let hasMore = true;

  while (hasMore) {
    const batch = db.batch();
    let query = db.collection("posts").where("userid", "==", uid).limit(500);

    if (lastDoc) {
      query = query.startAfter(lastDoc);
    }

    const snapshot = await query.get();

    if (snapshot.empty) {
      hasMore = false;
      break;
    }

    snapshot.docs.forEach((doc) => {
      batch.delete(doc.ref);
    });

    await batch.commit();
    console.log(`${snapshot.size} 件の投稿を削除しました`);

    if (snapshot.size < 500) {
      hasMore = false;
    } else {
      lastDoc = snapshot.docs[snapshot.docs.length - 1];
    }
  }
}

//フォロー関係を500件ずつバッチで削除
async function deleteAllFollowRelations(uid) {
  // フォローしている相手のfollowersから自分を削除
  await deleteCollectionInBatches(
    db.collection("users").doc(uid).collection("follows"),
    async (followDoc) => {
      const followeeId = followDoc.id;
      const batch = db.batch();

      // 相手のfollowersから自分を削除
      batch.delete(
        db.collection("users").doc(followeeId).collection("followers").doc(uid),
      );
      // 自分のfollowsから削除
      batch.delete(followDoc.ref);

      await batch.commit();
    },
  );

  // 自分をフォローしている相手のfollowsから自分を削除
  await deleteCollectionInBatches(
    db.collection("users").doc(uid).collection("followers"),
    async (followerDoc) => {
      const followerId = followerDoc.id;
      const batch = db.batch();

      // 相手のfollowsから自分を削除
      batch.delete(
        db.collection("users").doc(followerId).collection("follows").doc(uid),
      );
      // 自分のfollowersから削除
      batch.delete(followerDoc.ref);

      await batch.commit();
    },
  );
}

//グループ関係を500件ずつバッチで削除
async function deleteAllGroupRelations(uid) {
  await deleteCollectionInBatches(
    db.collection("users").doc(uid).collection("groups"),
    async (groupDoc) => {
      const groupId = groupDoc.id;
      const groupRef = db.collection("groups").doc(groupId);

      const membersSnap = await groupRef.collection("members").get();

      if (membersSnap.size === 1) {
        // 自分しかいない場合はグループ削除
        const batch = db.batch();
        membersSnap.forEach((m) => batch.delete(m.ref));
        batch.delete(groupRef);
        await batch.commit();
      } else {
        // メンバー削除・numPeople減算
        const batch = db.batch();
        batch.update(groupRef, { numPeople: FieldValue.increment(-1) });
        batch.delete(groupRef.collection("members").doc(uid));
        await batch.commit();
      }

      // ユーザー→groupsから削除
      await db
        .collection("users")
        .doc(uid)
        .collection("groups")
        .doc(groupId)
        .delete();
    },
  );
}

//ユーザープロフィールを削除
async function deleteUserProfile(uid) {
  const profileRef = db
    .collection("users")
    .doc(uid)
    .collection("profile")
    .doc("profile");
  await profileRef.delete();
}

//ユーザードキュメントを削除
async function deleteUserDocument(uid) {
  await db.collection("users").doc(uid).delete();
}

//コレクションを500件ずつバッチで処理する汎用関数
async function deleteCollectionInBatches(collectionRef, processDoc) {
  let lastDoc = null;
  let hasMore = true;

  while (hasMore) {
    let query = collectionRef.limit(500);

    if (lastDoc) {
      query = query.startAfter(lastDoc);
    }

    const snapshot = await query.get();

    if (snapshot.empty) {
      hasMore = false;
      break;
    }

    if (snapshot.size < 500) {
      hasMore = false;
    } else {
      lastDoc = snapshot.docs[snapshot.docs.length - 1];
    }

    for (const doc of snapshot.docs) {
      await processDoc(doc);
    }
  }
}

//ユーザーがアップロードした画像ファイルを削除
async function deleteAllUserImages(uid) {
  try {
    // ユーザーの投稿から画像ファイル名を取得
    const postsSnapshot = await db
      .collection("posts")
      .where("userid", "==", uid)
      .get();

    const imageFiles = new Set();

    // 投稿の画像ファイル名を収集
    postsSnapshot.forEach((doc) => {
      const data = doc.data();
      if (data.imageUrl) {
        // imageUrlからファイル名を抽出（例: "https://.../uid/filename.png" → "uid/filename.png"）
        const urlParts = data.imageUrl.split("/");
        if (urlParts.length > 0) {
          const fileName = urlParts[urlParts.length - 1];
          if (fileName) {
            imageFiles.add(`${uid}/${fileName}`);
          }
        }
      }
    });

    // プロフィール画像も削除対象に含める
    const profileSnapshot = await db
      .collection("users")
      .doc(uid)
      .collection("profile")
      .doc("profile")
      .get();

    if (profileSnapshot.exists) {
      const profileData = profileSnapshot.data();
      if (profileData.profileImageUrl) {
        const urlParts = profileData.profileImageUrl.split("/");
        if (urlParts.length > 0) {
          const fileName = urlParts[urlParts.length - 1];
          if (fileName) {
            imageFiles.add(`${uid}/${fileName}`);
          }
        }
      }
    }

    // Storageから画像ファイルを削除
    const bucket = storage.bucket();
    let deletedCount = 0;

    for (const imagePath of imageFiles) {
      try {
        const file = bucket.file(imagePath);
        await file.delete();
        deletedCount++;
        console.log(`画像ファイル削除: ${imagePath}`);
      } catch (error) {
        console.warn(`画像ファイル削除失敗: ${imagePath}`, error.message);
        // 個別のファイル削除失敗は続行
      }
    }

    console.log(`✅ ${deletedCount} 件の画像ファイルを削除しました`);
  } catch (error) {
    console.error("❌ 画像ファイル削除中にエラー:", error);
    // 画像削除の失敗はアカウント削除を停止させない
  }
}
