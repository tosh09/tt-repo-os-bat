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

ARG=a
COUNT=100
OFFSET=0
MODE=2

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


#
# メイン処理
#
function main() {
  local input_file="$1"
  local output_file="$2"
  local flag_a="$3"

  # python（TikApi）によるTikTokユーザ取得処理（リストに出力）
  echo "[DEBUG] start: python get userlist"
  cd $PYTHON_V_DIR
  rm -fv user_list.txt
  . bin/activate
  python src/get_tiktok_users.py $ARG $COUNT $OFFSET $MODE
  deactivate

  # curl によりTikTokへアクセスし、SNSリンク取得処理
  echo "[DEBUG] start: curl SNS get acount"
  rm -fv /var/tmp/curllog.txt
  rm -fv user_sns_list.txt
  while read line; do
    set +e
    echo "$line" >> user_sns_list.txt
    curl -fsSL "https://www.tiktok.com/@$line" |
      tr '\n\r' '\t' |
      sed -e 's/\t//g' |
      ggrep -oP '<a target=.*?instagram.*?>' | 
      sed -re 's_</?p>_\n_g' | 
      grep -vE '/>' >> user_sns_list.txt
    set -euC
  done < user_list.txt

  show_content "$input_file" "$output_file" "$flag_a"

}

# エントリー処理
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  #parse_args "$@"
  main "$INPUT_FILE" "$OUTPUT_FILE" "$FLAG_A"
fi
