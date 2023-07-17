@ECHO OFF
REM ******************************************************************
REM 処理内容：サーバリソース・パラメータ取得用バッチ
REM 作成日：2021/08/01
REM 作成者：tanaka.toshihisa
REM 更新日：
REM 更新者：
REM 更新内容：
REM   20210801 初版作成
REM 
REM ******************************************************************
SETLOCAL ENABLEEXTENSIONS ENABLEDELAYEDEXPANSION

REM ローカル変数定義
REM 環境変数の定義
SET INIFILE_PATH=TEST.ini
SET DATE_VALUE=%DATE:~0,4%%DATE:~5,2%%DATE:~8,2%

REM メイン処理
:MAIN
    REM ファイルがあるフォルダに移動
    PUSHD %~DP0

    REM 初期処理
    CALL :INIT
    IF %ERRORLEVEL% NEQ 0 GOTO:FINAL

    REM メイン処理
    ECHO INI_SERVER=%SERVER%
    ECHO INI_USER=%USER%

    REM PAUSE
    
    CALL :CPU_COUNT
    
    CALL :TASKLIST_OUT
    

GOTO :FINAL



REM **********************************************
REM サブルーチン定義
REM **********************************************
REM 初期処理
:INIT
    
    REM 引数の取得　複数ある場合は%1, %2 と数字を増やす
    SET ARG1=%1
    ECHO %ARG1%

    REM 初期設定ファイル
    FOR %%I IN (%INIFILE_PATH%) DO (
        CALL :READ_INIFILE %%I
        IF !ERRORLEVEL! NEQ 0 EXIT /B
    )
EXIT /B

REM INIファイル読み込み処理
:READ_INIFILE
    IF EXIST %1 (
        FOR /F "TOKENS=1,2* DELIMS==" %%I IN (%1) DO (
            IF NOT %%I == # (
                SET %%I=%%J
            )
        )
    ) ELSE (
        ECHO INIファイルが存在しません。
        EXIT /B
    )
EXIT /B


REM CPU使用率カウンタ
:CPU_COUNT
ECHO "START CPU_COUNT"

    TYPEPERF -sc 10 -si 1 "\processor(_Total)\%% Processor Time" | find ":" >> CPU_log_%DATE_VALUE%.csv

EXIT /B

REM MEM利用率高いタスクリスト出力
:TASKLIST_OUT
ECHO "START TASKLIST OUT"

    TASKLIST /fi "memusage gt 100000" >> TASK_LIST.log

EXIT /B


REM 終了処理
:FINAL
    POPD
    ENDLOCAL
    ECHO 終了
EXIT /B
