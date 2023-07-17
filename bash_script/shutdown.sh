#!/bin/bash
###########################################################################################
#
# TITLE:
#   シャットダウン用スクリプト
#   停止時に仮想マシン等の起動状況を確認して実行する（チェックNGの場合は停止しない）
#
# USAGE:
#   sh {SCRIPT_FILENAME} -h
#
# REMARKS:
#   20210401 https://www.m3tech.blog/entry/2018/08/21/bash-scripting
###########################################################################################

# bashのスイッチ
set -euC

# 外部スクリプトのsource
#source ./setting.inc

# グローバル定数
# readonly SCRIPT_DIR=$(cd $(dirname $0); pwd)

# グローバル変数
VM_COUNT=0
INPUT_FILE=
OUTPUT_FILE=
FLAG_A=0


# 後処理
function cleanup () {
  # do something
  true
}
trap cleanup EXIT


### 関数定義
# function usage() {
#   cat <<EOS >&2
# Usage: sh $(basename "$0") [OPTIONS] <input_file>
#   DESCRIPTION
#     {DESCRIPTION}
#   OPTIONS
#     -o output_file  Output in the file
#     -a              Do something
#     -h              Show this help
#     -v              Execute with debug mode
#   EXAMPLE
#     Show content of \`README.md\` in stdout
#       $ sh $(basename "$0") README.md
#     Show this help
#       $ sh $(basename "$0") -h
# EOS
# }

# # 引数parse処理
# function parse_args() {
#   while getopts "o:vah" opt; do
#     case $opt in
#       v) set -x ;;
#       o) OUTPUT_FILE=$OPTARG ;;
#       a) FLAG_A=1 ;;
#       h) usage; exit 0 ;;
#       *) usage; exit 1 ;;
#     esac
#   done

#   shift $((OPTIND - 1))

#   INPUT_FILE=${1:-}
#   if [[ "$INPUT_FILE" == "" ]]; then
#     usage
#     exit 1
#   fi
# }

# 実行中の仮想マシンをスキャンし、存在すればシャットダウンする
function check_vm () {

  echo "[DEBUG] -- start check_vm"
  for var in `/usr/bin/virsh list --all | egrep 'running$|実行中$' | awk '{print $2}'`
  do 
    echo "[DEBUG] -- virtual machine $var is running"
    /usr/bin/virsh shutdown $var
    # wait
  done

  # VM_COUNT=`virsh list | egrep 'running$|実行中$' `
  echo "[DEBUG] -- end check_vm"

}



### メイン処理
function main() {
  local input_file="$1"
  local output_file="$2"
  local flag_a="$3"

  # 各種チェック処理(VM_COUNTに最終稼働中マシン数を格納、正常なら0)
  check_vm

  # shutdown処理待ち
  sleep 5s
  echo "[DEBUG] -- sleep 解除"

  # 異常なしシャットダウン処理
  for var in `/usr/bin/virsh list --all | egrep 'running$|実行中$' | awk '{print $2}'`
  do 
    echo "[DEBUG] -- virtual machine $var is running"
    echo "[DEBUG] -- vm down error : exit shutdonw.sh"
    exit
    # wait
  done

  echo "[DEBUG] -- 異常なしシャットダウン"
  shutdown

}


# エントリー処理
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  # parse_args "$@"
  main "$INPUT_FILE" "$OUTPUT_FILE" "$FLAG_A"
fi

