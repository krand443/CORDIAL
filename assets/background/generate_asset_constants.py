import os

# カレントディレクトリを取得
current_dir = os.getcwd()

# .jpg ファイルを列挙
jpg_files = [f for f in os.listdir(current_dir) if f.lower().endswith('.jpg')]

# 出力
for file in jpg_files:
    print("'" + file + "',")
