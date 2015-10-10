MATLAB-kv-interop
=================

MATLABで記述した常微分方程式からkvのプログラムを生成したり
生成したプログラムをMATLABから呼び出したりできるやつ

ファイル一覧
----------

* `+compilers`  
  コンパイラをラップした関数を集めたディレクトリ  
  いずれもソースファイルのセル配列と出力ファイル名を受け取って終了ステータスと出力を返す  
  コンパイラは事前にインストールしておく
  * `clang.m`  
    Clangをラップした関数
  * `msvc.m`  
    Visual C++をラップした関数
* `+tools`  
  MATLABからC++のプログラムを実行するために使う関数を集めたディレクトリ
* `include`  
  C++のプログラムのコンパイルに必要なヘッダ群
* `tools`  
  C++のプログラムを生成するために必要なプログラムを集めたディレクトリ
* `build_tools.m`  
  `tools`ディレクトリ内のツールをコンパイルする関数  
  `prepare`が呼び出す
* `get_last_result.m`  
  生成したプログラムの最新の実行結果を得る
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
* `prepare.m`  
  プログラムの生成に必要なツールやライブラリを用意するためのプログラム  
  `make_kv_maffine2`と`make_kv_qr_lohner`が中で呼び出すようになってる
