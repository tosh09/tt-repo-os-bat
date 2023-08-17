###########################################################################################
#!/bin/bash
#
# TITLE:
#   TikTok Api を利用したスクレイピング処理
#
# USAGE:
#   sh get_tikuser.sh *params*
#     params1:keyword, params2:counts, params3:offset
#
# REMARKS:
#   20230801 https://www.m3tech.blog/entry/2018/08/21/bash-scripting
###########################################################################################

# bashのスイッチ
#set -euC

# 外部スクリプトのsource
#source ./setting.inc

# グローバル定数
Set-Variable -name PYTHON_V_DIR -value "任意のディレクトリ" -Option Constant
Set-Variable -name INPUT_FILE -value "任意のファイル名" -Option Constant
Set-Variable -name OUTPUT_FILE -value "任意のファイル名" -Option Constant
Set-Variable -name FLAG_A -value "任意のフラグパラメータ" -Option Constant

Set-Variable -name ARG -value "a" -Option Constant
Set-Variable -name COUNT -value 100 -Option Constant
Set-Variable -name OFFSET -value 0 -Option Constant
Set-Variable -name MODE -value "2" -Option Constant


# 後処理
function cleanup() {
  # do something
  true
}
trap cleanup EXIT


# メイン処理
# 
function main() {
    local input_file="$1"
    local output_file="$2"
    local flag_a="$3"

    # python（TikApi）によるTikTokユーザ取得処理（リストに出力）
    Write-Host  "[DEBUG] start: python get userlist"
    cd $PYTHON_V_DIR
    Remove-Item -Recurse -Force user_list.txt
    Start-Process 'bin\activate.bat'
    python 'src\Main.py' $ARG $COUNT $OFFSET $MODE
    Start-Process 'bin\deactivate.bat'

    # curl によりTikTokへアクセスし、SNSリンク取得処理
    Write-Host  "[DEBUG] start: curl SNS get acount"
    Remove-Item -Recurse -Force curllog.txt
    Remove-Item -Recurse -Force user_sns_list.txt
    # Pythonモジュールにより取得したユーザリスト分curlを実行し、結果をlistテキストファイルに出力する
    foreach ($line in Get-Content trend_user_list.txt) {
        Write-Host $line >> user_sns_list.txt
        curl -fsSL "https://www.tiktok.com/@$line" |
            tr '\n\r' '\t' |
            sed -e 's/\t//g' |
            ggrep -oP '<a target=.*?instagram.*?>' | 
            sed -re 's_</?p>_\n_g' | 
            grep -vE '/>' >> user_sns_list.txt
    }
    
}


# エントリー処理
script_path = Split-Path $MyInvocation.MyCommand.Path
if ($script_path -eq Get-Location) {
    Write-Host  "[DEBUG] start: run_tiktok_api_scraping ! "
    #parse_args $@
    main $INPUT_FILE $OUTPUT_FILE $FLAG_A

    Write-Host  "[DEBUG] end: run_tiktok_api_scraping ! "
}

