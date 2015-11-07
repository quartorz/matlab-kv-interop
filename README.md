# MATLAB-kv-interop

## インストールとアンインストール

MATLABからこのディレクトリを開けば使うことができる。
アンインストールも単にこのディレクトリを削除するだけで良い。

## 使い方

`sample_`で始まるファイルがサンプルプログラムである。
サンプルプログラムの内ファイル名に`make`が入っている方を先に実行してから
`calc`が入っている方を実行すれば結果を見ることができる。
`maffine2`が付くものは`kv::ode_maffine2`を使うプログラムを生成し、
`qr_lohner`が付くものは`kv::odelong_qr_lohner`を使うプログラムを生成する。

サンプルプログラムのうち`nosyms`で終わるものはSymbolic Math Toolboxに依存しない。

## ファイル一覧

あまり重要でないファイル以外は`html`ディレクトリ以下に詳しい説明がある。

* `+compilers`  
  コンパイラをラップした関数を集めたディレクトリ  
  いずれもソースファイルのセル配列と出力ファイル名を受け取って終了ステータスと出力を返す  
  コンパイラは事前にインストールしておく
  * `clang.m`  
    Clangをラップした関数
  * `gcc.m`  
    GCCをラップした関数
  * `msvc.m`  
    Visual C++をラップした関数
* `+tools`  
  MATLABからC++のプログラムを実行するために必要な関数を集めたディレクトリ
  * `build_tools.m`  
    `tools`以下にあるツールをビルドする関数
  * `detect_compiler.m`  
    コンパイラを探して、見つけたコンパイラに対応する`+compilers`ディレクトリ内の関数を返す
  * `get_last_affine.m`  
    最終的な計算結果を表すAffine多項式を得る関数
  * `get_latest_result.m`  
    生成したプログラムの最新の実行結果を得る関数
  * `plot_affine.m`  
    Affine多項式をプロットする関数  
    2次元でも3次元でも
  * `prepare.m`  
    `make_kv_*`がプログラムをコンパイルするための準備を行う関数
* `include`  
  C++のプログラムのコンパイルに必要なヘッダ群
* `tools`  
  C++のプログラムを生成するために必要なプログラムを集めたディレクトリ
* `kv_maffine2.m`  
  `make_kv_maffine2`で生成したプログラムを実行して計算結果を返す
* `kv_qr_lohner.m`  
  `make_kv_qr_lohner`で生成したプログラムを実行して計算結果を返す
* `make_kv_maffine2.m`  
  `kv::ode_maffine2`を使って計算するプログラムを生成する  
  `t`の分割数を指定できる
* `make_kv_qr_lohner.m`  
  `kv::odelong_qr_lohner`を使って計算するプログラムを生成する  
  `t`の分割数は指定できない
* `Status.m`  
  計算ができたかどうかを表す列挙型
