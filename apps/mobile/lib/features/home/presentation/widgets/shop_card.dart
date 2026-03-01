import 'package:flutter/material.dart';

class ShopCard extends StatelessWidget {
  const ShopCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      // カードの角の丸み。数字が大きいほど丸くなります。
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2, // 影の濃さ。浮かんでいるように見せる効果です。
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,

          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            // --- 1. ヘッダー部分 (店名とアイコン) ---
            Row(
              // Row（横並び）の中で、パーツの間を「目一杯広げて配置」します。
              // これにより、左に店名、右にアイコンが分かれて配置されます。
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'shopname',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                Row(
                  children: [
                    // アイコンボタン
                    IconButton(
                      icon: const Icon(Icons.bookmark_border),
                      onPressed: () {}, // ここに保存ボタンを押した時の動きを書きます
                      constraints: const BoxConstraints(), // 余計な余白を消すためのおまじない
                      padding: EdgeInsets.zero, // アイコン周りの余白をゼロにする
                    ),
                    const SizedBox(width: 12), // アイコン同士の隙間
                    IconButton(
                      icon: const Icon(Icons.send_outlined),
                      onPressed: () {},
                      constraints: const BoxConstraints(),
                      padding: EdgeInsets.zero,
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12), // ヘッダーとボディの間の縦の隙間
            // --- 2. ボディ部分 (画像 + 右側に情報とボタン) ---
            Row(
              // Row（横並び）の中で、パーツを「上端（start）」で揃えます。
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 左側：ショップ画像の箱
                Container(
                  width: 160,
                  height: 160,
                  decoration: BoxDecoration(
                    color: Colors.grey[200], // まだ画像がない時の仮の色
                    borderRadius: BorderRadius.circular(12), // 画像の角も丸くする
                  ),
                  child: const Center(
                    child: Text(
                      'shop image',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                ),
                const SizedBox(width: 12), // 画像とボタンの間の横の隙間
                // 右側：説明テキストとボタンを縦に並べるエリア
                // Expanded を使うことで、画像の横の「残りのスペース」を全部使い切ります。
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start, // 縦の並びは上から
                    crossAxisAlignment:
                        CrossAxisAlignment.end, // 横の並びは「右端(end)」に揃える
                    children: [
                      const Text(
                        'イタリアン/大人数可/要予約',
                        style: TextStyle(fontSize: 10, color: Colors.black54),
                        textAlign: TextAlign.right, // テキスト自体も右寄せに
                      ),
                      const SizedBox(height: 16), // テキストとボタンの隙間
                      // 共通パーツを使ってボタンを3つ並べる
                      _buildStandardButton('ここに行く'),
                      _buildStandardButton('詳細'),
                      _buildGoogleMapButton(),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // --- 共通パーツ：通常のアクションボタンを作る「型」 ---
  Widget _buildStandardButton(String label) {
    return Container(
      width: double.infinity, // 右側のエリアの横幅いっぱいに広げる
      height: 32, // ボタンの高さ
      margin: const EdgeInsets.only(bottom: 6), // ボタン同士の縦の隙間
      child: OutlinedButton(
        onPressed: () {},
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Colors.black, width: 1), // 黒い枠線
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
          ), // 少しだけ角を丸く
          padding: EdgeInsets.zero, // 文字を真ん中に置くために余白を消す
        ),
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  // --- 共通パーツ：Googleマップボタン専用の「型」 ---
  Widget _buildGoogleMapButton() {
    return SizedBox(
      width: double.infinity,
      height: 32,
      child: OutlinedButton(
        onPressed: () {},
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Colors.black, width: 1),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
          padding: const EdgeInsets.symmetric(horizontal: 4),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center, // アイコンと文字を中央寄せ
          children: [
            const Icon(Icons.location_on, color: Colors.red, size: 14), // 赤いピン
            const SizedBox(width: 4),
            const Text(
              'Googleマップを開く',
              style: TextStyle(
                color: Colors.black,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
