# Reso Mobile App

Flutter モバイルアプリです。  
`Add Spot` 画面は `--dart-define` で API キー/設定を渡さないと警告が表示されます。

## 前提

- Flutter SDK（FVM利用でも可）
- Xcode / Android Studio など実行対象に必要な環境

## セットアップ

```bash
cd apps/mobile
flutter pub get
```

## 起動方法（必須 `dart-define` 付き）

`Add Spot` を正常動作させるには、以下 3 つを指定して起動してください。

- `GOOGLE_PLACES_API_KEY`
- `CLOUDINARY_CLOUD_NAME`
- `CLOUDINARY_UNSIGNED_UPLOAD_PRESET`

```bash
cd apps/mobile
flutter run \
  --dart-define=GOOGLE_PLACES_API_KEY=YOUR_KEY \
  --dart-define=CLOUDINARY_CLOUD_NAME=YOUR_CLOUD_NAME \
  --dart-define=CLOUDINARY_UNSIGNED_UPLOAD_PRESET=YOUR_PRESET
```

投稿 API まで使う場合は、認証トークンも追加してください。

```bash
--dart-define=TRAPIZZINO_AUTH_TOKEN=YOUR_TOKEN
```

`TRAPIZZINO_API_BASE_URL` は未指定時に `https://api.sandbox-kc.uk` が使われます。  
必要なら上書きしてください。

```bash
--dart-define=TRAPIZZINO_API_BASE_URL=https://your-api.example.com
```

## VS Code で毎回入力しない設定（任意）

`.vscode/launch.json` の `toolArgs` に固定しておくと便利です。

```json
{
  "version": "0.2.0",
  "configurations": [
    {
      "name": "mobile",
      "request": "launch",
      "type": "dart",
      "program": "apps/mobile/lib/main.dart",
      "toolArgs": [
        "--dart-define=GOOGLE_PLACES_API_KEY=YOUR_KEY",
        "--dart-define=CLOUDINARY_CLOUD_NAME=YOUR_CLOUD_NAME",
        "--dart-define=CLOUDINARY_UNSIGNED_UPLOAD_PRESET=YOUR_PRESET",
        "--dart-define=TRAPIZZINO_AUTH_TOKEN=YOUR_TOKEN"
      ]
    }
  ]
}
```

## よくあるハマりどころ

- `Target of URI doesn't exist` が出る: `flutter pub get` を実行
- `dart-define` を追加したのに反映されない: アプリを完全停止して再起動（Hot Reload では反映されない）
