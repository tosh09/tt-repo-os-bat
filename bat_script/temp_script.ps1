###########################################################################################
# TITLE:
#   Power shell sample Script
#
# USAGE:
#   sh temp_script.ps1 *params*
#     params1:keyword, params2:counts, params3:offset
#
# REMARKS:
#   20230401 http://www.math.kobe-u.ac.jp/HOME/kodama/tips-powershell-grammar.html
#
###########################################################################################

function main() {
 $a = ($arg1 + $arg2)
 $b = ([int]$arg1 + [int]$arg2)
 write-output "string : $arg1 + $arg2 = $a"
 write-output "integer : $arg1 + $arg2 = $b"
}

$err=0
$ErrorActionPreference = "stop"
try {
  $log = main
} catch [Exception] {
  $err=1
  $log = $_
}

write-output $log
exit $err
