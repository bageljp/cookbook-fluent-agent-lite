What's ?
===============
chef で使用する fluent-agent-lite の cookbook です。
なお fluent-agent-lite の機能とほぼ同等のものが td-agent 2系 には備わっているので、使う前にまず td-agent 2系 を検討することを推奨。

Usage
-----
cookbook なので berkshelf で取ってきて使いましょう。

* Berksfile
```ruby
source "https://supermarket.chef.io"

cookbook "fluent-agent-lite", git: "https://github.com/bageljp/cookbook-fluent-agent-lite.git"
```

```
berks vendor
```

#### Role and Environment attributes

* sample_role.rb
```ruby
override_attributes(
  "fluent-agent-lite" => {
    "rpm" => {
      "url" => "https://s3-ap-northeast-1.amazonaws.com/archive/chef/fluent-agent-lite-1.0-original.x86_64.rpm"
    },
    "conf" => {
      "server" => "172.31.0.101",
      "logs" => {
        "os.syslog" => "/var/log/messages",
        "os.mail" => "/var/log/maillog",
        "os.wtmp" => "/var/log/wtmp",
        "os.btmp" => "/var/log/btmp",
        "os.secure" => "/var/log/secure",
        "nginx.access" => "/var/log/nginx/access.log",
        "nginx.error" => "/var/log/nginx/error.log",
        "mysql.error" => "/var/lib/mysql/mysqld.log",
        "mysql.slow" => "/var/lib/mysql/slow.log"
      }
    },
    "rpmbuild" => {
      "home_dir" => "/home/user_name",
      "user" => "user_name",
      "group" => "group_name",
      "s3" => {
        "upload" => true,
        "url" => "s3://archive/chef/"
      }
    }
  }
)
```

Recipes
----------

#### fluent-agent-lite::default
fluent-agent-lite のインストールと設定。

#### fluent-agent-lite::rpmbuild
fluent-agent-lite の rpm をrpmbuildで作成する。

Attributes
----------

主要なやつのみ。

#### fluent-agent-lite::default
<table>
  <tr>
    <th>Key</th>
    <th>Type</th>
    <th>Description</th>
  </tr>
  <tr>
    <td><tt>['fluent-agent-lite']['rpm']['url']</tt></td>
    <td>string</td>
    <td>rpmでインストールする場合にrpmが置いてあるURL。rpmbuildしたものをs3とかに置いておくといいかも。</td>
  </tr>
  <tr>
    <td><tt>['fluent-agent-lite']['rpmbuild']['s3']['upload']</tt></td>
    <td>boolean</td>
    <td>rpmbuildで作成したrpmファイルをS3にアップロードするかどうか。</td>
  </tr>
  <tr>
    <td><tt>['fluent-agent-lite']['rpmbuild']['s3']['url']</tt></td>
    <td>string</td>
    <td>rpmbuildで作成したrpmファイルのアップロード先S3。</td>
  </tr>
  <tr>
    <td><tt>['fluent-agent-lite']['conf']['logs']</tt></td>
    <td>array string</td>
    <td>fluent-agent-lite 管理にするログファイルをタグ名をつけて配列形式で指定。</td>
  </tr>
</table>

