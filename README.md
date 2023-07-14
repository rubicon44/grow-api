# 概要
Growは、転職用ポートフォリオとして制作したタスク管理SNSサービスです。

## URL
https://grow-by-rubicon44.com/

## サービスの目的/コンセプト
Growは、様々な人のタスク管理方法を学べるタスク管理SNSサービスです。
SNS風にすることで、個人のタスク管理を閲覧できるようにしています。

## アピールポイント
### バックエンド
- ★Firebase Auth + JWT認証機能を実装している
- 「aws-sdk-s3」を用いて、ユーザー画像のアップロードを行っている
- 「active_model_serializers」を用いて、JSONの出力を適切に行っている
- Fat Controllerにならないよう、ロジックをModelに移行している
- バリデーションを一括で定義することにより、Modelを見やすくし、今後カスタムバリデータへの分割を想定し、バリデーションをカスタムメソッドとして定義している
- Strong Parameterやバリデーション、Cookieを使用して、基本的なセキュリティ対策を行っている
- Rspec/FactoryBotを用い、わかりやすいAPIテストを十分に書いている

### フロントエンド
- ★ガントチャート機能を自前で実装している
- Atomic Designを適用し、基本的なコンポーネント分割を行っている
- コンポーネントにfeatureフォルダーを適用し、Atomic Designをより使いやすくカスタマイズしている
- コンポーネントにPresentational/Containerパターンを適用し、Hooksの呼び出し位置を制限することで、可読性とメンテナンス性を向上している
- カスタムHooksを使用し、API通信用のロジックをコンポーネントから分離している
- API通信時には、try-catch文を用いて基本的なエラーハンドリングを行っている
- 「eslint-config-airbnb」を適用し、厳格な静的解析を行なっている
  - 一部カスタマイズあり(アロー関数の許容など)
- Cookieを使用し、基本的なCSRF対策を行っている

### インフラ
- ★ECS + ECR + RDSのインフラ環境を構築している
- IAMを用いて、rootユーザーと開発ユーザーを分けている
- Route 53を用いて、独自ドメイン設定とHTTPS化を行っている

### 共通
- ★Docker/Docker Compose環境を構築し開発を行なっている
- GitHub Actionsによる自動デプロイを実装できている
- GitHubブランチをmainとdevelopに分け、実践的なコード管理をしている
- フロントエンドとバックエンドを分けて開発している
- Formatter/Linterを用いコード整形を行っている

## インフラ構成図（Cacoo使用）
https://github.com/rubicon44/grow-api/assets/47108632/6e365fb9-7b0e-4e3b-959f-316886497eb0

## DB設計図（Cacoo使用）
https://github.com/rubicon44/grow-api/assets/47108632/ce5ad1a2-a04d-49cc-a9e9-dfb9b2b2e0c3

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

## 機能一覧
- ログイン機能/ユーザー登録機能
  - email/password認証
  - プロバイダー認証
    - Google
    - GitHub

- タスク管理機能
  - 登録（title、content、status、startData、endDateの5つを登録可能）
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
  - 画像アップロード
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

※検索機能の結果は10件表示、それ以外の無限スクロールは3件ずつの表示になっています。

## 実装予定の機能
- タスクのcontent内のチェックボックス永続化
- 管理者機能
  - ユーザー管理
  - タスク管理
  - 通知
- ブロック機能
- ミュート機能
- React QueryやRedisを用いたパフォーマンス改善

## 今回実装していないこと
- コメント機能、チャット機能はmustな要件でないため未実装
- プロバイダー認証とemail/password認証のアカウント統合
- validatorクラス
  - サービス規模が大きくなく、ロジックも複雑でないため、Modelにそのまま定義

# 今回の開発を終えての所感/今後に向けて
今回は1人で初めて、フロントエンドとバックエンドを分離したWebサービスを作成しました。
特に注力したのは「JWT認証の実装」と「Fat Controllerの解消」、「ガントチャートのロジック作成」と「コンポーネント分割」です。

バックエンドに関しては、1つのエンドポイントだけでなく、機能ごとにAPIを分離したり、それらをまとめるBFFを作成したいと思いました。

また、Clean Architectureやマイクロサービスにも興味が湧いたので、現在「Next.js、TypeScript、Express API、Prisma、Clean Architecture」を用いてアプリケーション開発を行なっています。

「コンポーネント分割」に関しては様々な手法があるので、より多くのコンポーネント分割/設計手法を学び、メンテナンスしやすいコンポーネントを素早く実装できるようになりたいです。

また、ガントチャートの作成を通じて、UIライブラリの作成に興味を持ったので、ガントチャートをライブラリとして作成し公開したいと思います。