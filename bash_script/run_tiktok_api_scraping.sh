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
#   20210401 https://www.m3tech.blog/entry/2018/08/21/bash-scripting
###########################################################################################

# bashのスイッチ
set -euC

# 外部スクリプトのsource
#source ./setting.inc

# グローバル定数
readonly SCRIPT_DIR=$(cd $(dirname $0); pwd)

# グローバル変数
PYTHON_V_DIR="/Users/tosh/work_system/pywork/venv_tikapi"
INPUT_FILE=
OUTPUT_FILE=
FLAG_A=0

ARG=A
COUNT=500
OFFSET=0



TIMESTAMP=$(date +%Y%m%d_%H%M%S)
OUTPUT_DIR="output/"
TREND_USER_LIST=$OUTPUT_DIR"trend_user_list.txt"
LIVER_LIST=$OUTPUT_DIR"liver_list.txt"
LIVER_LIST_TXT="liver_list.txt"
SNS_USER_LIST=$OUTPUT_DIR"sns_user_list_$TIMESTAMP.csv"
TARGET_USER_LIST=$OUTPUT_DIR"target_user_list.txt"


# 後処理
function cleanup() {
  # do something
  true
}
trap cleanup EXIT

#
# 関数定義
#

function usage() {
  cat <<EOS >&2
  Usage: sh $(basename "$0") [OPTIONS] <input_file>
  DESCRIPTION
    {DESCRIPTION}
  OPTIONS
    -o output_file  Output in the file
    -a              Do something
    -h              Show this help
    -v              Execute with debug mode
  EXAMPLE
    Show content of \`README.md\` in stdout
      $ sh $(basename "$0") README.md
    Show this help
      $ sh $(basename "$0") -h
EOS
}

function show_content() {
  local input_file="$1"
  local output_file="$2"
  local flag_a="$3"

  if [[ "$output_file" != "" ]] && [[ $flag_a -eq 1 ]]; then
    cat <<EOS
    cat "$input_file |>> $output_file"
EOS
  elif [[ "$output_file" != "" ]]; then
    cat <<EOS
    cat "$input_file |> $output_file"
EOS
  else
    cat <<EOS
    cat "$input_file"
EOS
  fi
}


#
# 引数parse処理
#
function parse_args() {
  while getopts "o:vah" opt; do
    case $opt in
      v) set -x ;;
      o) OUTPUT_FILE=$OPTARG ;;
      a) FLAG_A=1 ;;
      h) usage; exit 0 ;;
      *) usage; exit 1 ;;
    esac
  done

  shift $((OPTIND - 1))

  INPUT_FILE=${1:-}
  if [[ "$INPUT_FILE" == "" ]]; then
    usage
    exit 1
  fi
}

# curl によりTikTokへアクセスし、SNSリンク取得処理
# インスタグラムリンクをもつユーザを出力する
function curl_tiktok() {
    echo "[DEBUG] start: curl SNS get acount"
    while read line;
    do
        echo $line
        set +e

        curl -fsSL "https://www.tiktok.com/@$line" |
            tr '\n\r' '\t' |
            sed -e 's/\t//g' |
            ggrep -oP '<a target=.*?instagram.*?>' | 
            sed -re 's_</?p>_\n_g' | 
            grep -vE '/>' >> $SNS_USER_LIST
    done < $LIVER_LIST_TXT
}

# Python モジュールを実行し対象ユーザを取得する
# 取得したユーザはcurl処理でさらに抽出する
function py_main_build() {
  local MODE="$1"
  local SEARCH_K="$2"

  # python（TikApi）によるTikTokユーザ取得処理（リストに出力）
  echo "[DEBUG] start: python get userlist "
  echo "[DEBUG] show params: $MODE $SEARCH_K "
  cd $PYTHON_V_DIR
  rm -fv $TREND_USER_LIST
  . bin/activate
  python src/Main.py $ARG $COUNT $OFFSET $MODE $SEARCH_K
  deactivate

    #show_content "$input_file" "$output_file" "$flag_a"
}



# エントリー処理
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    echo "[DEBUG] show param: $1 $2 $3"

    # parse_args "$@"
    # python scraping処理実行
    echo "[DEBUG] py_scraping shell start."
    py_main_build "$2" "$3"
    
    echo "[DEBUG] get_tikuuser shell end."

fi
