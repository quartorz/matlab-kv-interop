classdef Status < int32
    %%
    % 生成したプログラムの実行結果を表す
    enumeration
        Succeeded(0)  % t_lastまで計算できた
        Failed(1)     % 計算をはじめられなかった
                      % ・コマンドライン引数がおかしい
                      % ・出力用のファイルを開けなかった
        Incomplete(2) % 途中までしか計算できなかった
    end
end

