# 公開ステータスページの静的配信

公開ページは Rails から直接応答せず、`<slug>.example.com` を CloudFront 経由で配信します。
Rails は管理画面と HTML の生成だけを担当します。

```text
Rails + Solid Queue -> private S3 bucket <- CloudFront (OAC) <- *.example.com
```

## アプリケーション設定

本番環境では次を設定します。

```sh
STATUS_PAGE_BASE_DOMAIN=example.com
STATUS_PAGE_S3_BUCKET=solid-status-public-pages
STATUS_PAGE_S3_PREFIX=status-pages # 任意。既定値は status-pages
```

AWS SDK は IAM ロールまたは標準の AWS 認証情報チェーンを使用します。
`STATUS_PAGE_S3_BUCKET` が本番で未設定の場合、公開ジョブは失敗します。開発・テスト環境では `tmp/public_status_pages/` に同じオブジェクト構成で出力されます。

HTML は `status-pages/<slug>/index.html` に保存されます。インシデント、更新履歴、またはページ本体がコミットされると `PublishStatusPageJob` が再生成します。アップロードに失敗しても、S3 上の直前の正常版は削除されません。S3 の一時的なエラーは最大 5 回再試行します。ページを削除すると `UnpublishStatusPageJob` がオブジェクトを削除します。

## AWS / DNS の構築

1. S3 バケットを作成し、**Block Public Access を有効**にする。
2. CloudFront ディストリビューションを作成し、S3 をオリジンに指定する。Origin Access Control (OAC) を作成し、バケットポリシーでそのディストリビューションだけに `s3:GetObject` を許可する。
3. ACM の `us-east-1` で `*.example.com` の DNS 検証済み証明書を発行し、CloudFront の Alternate domain name に設定する。
4. DNS に `*.example.com` を CloudFront ディストリビューションへ向けるレコードを作成する。
5. `config/cloudfront/status_page_request.js` の `baseDomain` を実ドメインに置換し、CloudFront Function として Viewer Request に関連付ける。キャッシュポリシーの最小 TTL は `0`、最大 TTL は少なくとも `86400` 秒にして、オリジンの `Cache-Control` を尊重する。
6. Rails 実行環境へ S3 への `PutObject` と `DeleteObject` だけを許可する IAM ロールを付与し、上記環境変数を設定する。

CloudFront Function は Host ヘッダーの slug を S3 のオブジェクトキーへ変換します。たとえば `api.example.com/anything` は `status-pages/api/index.html` を返します。ワイルドカードは 1 階層だけを対象とするため、`a.b.example.com` は公開対象にしません。

公開 HTML は `Cache-Control: public, max-age=60, s-maxage=60, stale-while-revalidate=60, stale-if-error=86400` で保存されます。通常は60秒で新しい公開版を再検証し、その間は最大60秒間、直前の公開版を返します。S3 が一時的に到達不能または 5xx を返した場合は、CloudFront が直前の公開版を最大24時間返します。CloudFront の cache policy は最小 TTL を `0`、最大 TTL を少なくとも `86400` 秒に設定してください。CloudFront の明示的な invalidation は不要です。

## 初回リリースの境界

対象はプラットフォームが管理する `*.example.com` のみです。顧客が所有する任意のドメインは、DNS 所有確認・証明書ライフサイクル・設定失敗時の運用を含む別機能として扱います。
