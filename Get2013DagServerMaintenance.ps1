<#
.NOTES
Written by Justin Beeden
V1.3 12.05.2013
.SYNOPSIS
Checks Exchange 2013 DAG nodes maintenance mode settings.
.DESCRIPTION
Checks Exchange 2013 DAG nodes maintenance mode settings.
http://technet.microsoft.com/en-us/library/dd298065%28v=exchg.150%29.aspx#Pm
.PARAMETER Server
Specifies the DAG node Server name to checked for maintenance mode settings.
.EXAMPLE
PS> .\Get2013DagServerMaintenance.ps1 -Server Server1
.EXAMPLE
PS> .\Get2013DagServerMaintenance.ps1 Server1
#>

#Requires -version 3.0

[CmdletBinding()]
Param(
    [Parameter(Position=0, Mandatory = $true,
    HelpMessage="Enter the name of DAG Server to check for Maintenance mode.")]
    [string]$Server
)

#Shows if the server has been placed into maintenance mode
Get-ServerComponentState $Server | Where {$_.Component -ne "Monitoring" -and $_.Component -ne "RecoveryActionsEnabled"} | ft Component,State -Autosize

#Shows if the server is not hosting any active database copies
Get-MailboxServer $Server | ft DatabaseCopy* -Autosize

#Shows if that the cluster node is paused
Get-ClusterNode $Server | fl

#Shows that all transport queues have been drained
Get-Queue -Server $Server
