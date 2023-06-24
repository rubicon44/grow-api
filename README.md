# 概要
Growは、転職用ポートフォリオとして制作したタスク管理SNSサービスです。

## URL
https://grow-by-rubicon44.com/

## サービスの目的/コンセプト
Growは、様々な人のタスク管理方法を学べるタスク管理SNSサービスです。
SNS風にすることで、個人のタスク管理を閲覧できるようにしています。

## 環境/使用技術
- M1 Mac: Memory 16GB
- Docker Desktop: 4.19.0
- Docker
  - Dockerクライアント: 23.0.5
  - Dockerエンジン: 23.0.5
  - API: 1.42
- Docker Compose: 2.17.3

- 言語/フレームワーク
  - フロントエンド
    - Node.js: 18.13.0
    - Yarn: 1.22.19
    - React: 18.2.0
  - バックエンド
    - Ruby: 2.7.7
    - Ruby on Rails: 7.0.5
- スタイリング: Material-UI、styled-components
- 認証: Firebase Authentication、JWT
- Linter/Formatter
  - ESLint、Prettier
  - Rubocop
- テスト
  - API: Rspec、FactoryBot
  ~~- E2E: Jest、puppeteer~~
- インフラ
  - SPA: Vercel
  - API: ECS + ECR + RDS
- CI/CD: GitHub Actions

## DB設計図（Cacoo使用）
https://github.com/rubicon44/grow-api/assets/47108632/ce5ad1a2-a04d-49cc-a9e9-dfb9b2b2e0c3

## AWS構成図（Cacoo使用）
https://github.com/rubicon44/rubicon44-techblog/assets/47108632/88c03705-2f58-47c7-82a0-ef0b90a4b4fa

## 機能一覧
- ログイン機能/ユーザー登録機能

- タスク管理機能
  - 登録（title, content, status, startData, endDateの5つを登録可能）
  - 一覧表示
    - 全体表示(最新順) ※今後は、その人の興味のあるカテゴリごとに上位表示する仕組みを実装予定。
    - フォローしているユーザーのみ
  - 詳細表示
  - 編集
  - 削除

- ガントチャート機能
  - 1年分を表示

- いいね機能
  - 作成
  - 削除

- ユーザー機能
  - 詳細表示
  - 編集
  ~~- 削除~~ : 未実装

- フォロー機能
  - 作成(フォロー)
  - 削除(アンフォロー)
  - 一覧表示
    - フォロー中
    - フォロワー

- 通知機能
  - いいね通知
  - フォロー通知

- 検索機能
  - ユーザー検索
  - タスク検索

## 今回実装していないこと
- コメント機能、チャット機能はmustな要件でないため未実装
- プロバイダー認証とemail/password認証のアカウント統合
- validatorクラス
  - サービス規模が大きくなく、ロジックも複雑でないため、Modelにそのまま定義。
  - バリデーションを一括で定義することにより、Modelを見やすくし、今後カスタムバリデータへの分割を想定し、バリデーションをカスタムメソッドとして定義。

## 実装予定の機能
- 管理者機能
  - ユーザー管理
  - タスク管理
  - 通知
- ブロック機能
- ミュート機能
- React QueryやRedisを用いたパフォーマンス改善

## アピールポイント
### フロントエンド
- Atomic Designを適用し、基本的なコンポーネント分割を行っている
- コンポーネントにfeatureフォルダーを適用し、Atomic Designをより使いやすくカスタマイズ
- コンポーネントにPresentational/Containerパターンを適用し、Hooksの呼び出し位置を制限することで、可読性とメンテナンス性を向上
- カスタムHooksを使用し、API通信用のロジックをコンポーネントから分離
- API通信時には、try-catch文を用いて基本的なエラーハンドリングを行っている
- 「eslint-config-airbnb」を適用し、厳格な静的解析を行なっている
  - 一部カスタマイズあり(アロー関数の許容など)
- Cookieを使用し、基本的なCSRF対策を行っている
- ★自前でガントチャートを作成している

### バックエンド
- 「active_model_serializers」を用い、JSONの出力を適切に行っている
- Fat Controllerにならないよう、ロジックをModelに移行している
- Strong Parameterやバリデーション、Cookieを使用して、基本的なセキュリティ対策を行っている
- Rspec/FactoryBotを用い、わかりやすいAPIテストを十分に書いている

- ★JWT認証機能を実装している

### 共通
- Docker/Docker Compose環境を構築し開発を行なっている
- Formatter/Linterを用いコード整形を行っている
- GitHubブランチをmainとdevelopに分け、実践的なコード管理をしている
- CI/CDが実装できている

# 今回の開発を終えての所感/今後に向けて
今回は1人で初めて、フロントエンドとバックエンドを分離したWebサービスを作成しました。
特に注力したのは「ガントチャートのロジック作成」と「コンポーネント分割」、「JWT認証の実装」です。

今回のガントチャートの作成を通じて、UIライブラリの作成に興味を持ったので、ガントチャートをライブラリとして作成し公開したいと思います。

「コンポーネント分割」に関しては様々な手法があるので、より多くのコンポーネント分割/設計手法を学び、メンテナンスしやすいコンポーネントを素早く実装できるようになりたいです。

バックエンドに関しては、1つの環境に複数のAPIを生やすだけでなく、APIを分離したり、さらにAPIを追加したりし、それらをまとめるBFFを作成したいと思いました。