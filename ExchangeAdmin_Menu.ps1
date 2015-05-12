[int]$xMenuChoiceA = 0
while ( $xMenuChoiceA -lt 1 -or $xMenuChoiceA -gt 2 ){
Write-host "1. Exchange Management Shell (Custom Profile)"
Write-host "2. Windows PowerShell"
#Write-host "3. Shared mailbox tasks"
#Write-host "4. Quit and exit"
[Int]$xMenuChoiceA = read-host "Please choose an option..." }
Switch( $xMenuChoiceA ){
  1{invoke-expression -Command ($profile)}
  2{<#run an action or call a function here #>}
# 3{<#run an action or call a function here #>}
default{<#run a default action or call a function here #>}
}