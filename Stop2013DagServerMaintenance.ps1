<#
.NOTES
Written by Justin Beeden
V1.2 11.16.2013
.SYNOPSIS
Removes Exchange 2013 DAG nodes out of maintenance mode.
.DESCRIPTION
Removes Exchange 2013 DAG nodes out of maintenance mode.
http://technet.microsoft.com/en-us/library/dd298065%28v=exchg.150%29.aspx#Pm
.PARAMETER Server
Specifies the DAG node Server name to be removed from maintenance mode.
.EXAMPLE
PS> .\Stop2013DagServerMaintenance.ps1 -Server Server1
#>

#Requires -version 3.0

[CmdletBinding()]
Param(
    [Parameter(Mandatory = $true,
    HelpMessage="Enter the name of DAG Server to remove from Maintenance mode.")]
    [string]$Server
)

#Designates that the server is out of maintenance mode
Write-Verbose "Taking $Server out of maintenance mode"
Set-ServerComponentState $Server -Component ServerWideOffline -State Active -Requester Maintenance

#Allows the server to accept Unified Messaging calls
Write-Verbose "$Server can now accept Unified Messaging calls."
Set-ServerComponentState $Server -Component UMCallRouter –State Active –Requester Maintenance

#Resumes the node in the cluster and enables full cluster functionality for the server
Write-Verbose "Resuming the cluster node and enabling full cluster functionality."
Resume-ClusterNode $Server

#Allows databases to become active on the server
Write-Verbose "$Server can now host active database copies."
Set-MailboxServer $Server -DatabaseCopyActivationDisabledAndMoveNow $False

#Removes the automatic activation blocks
Write-Verbose "$Server can now automatically host active database copies."
Set-MailboxServer $Server -DatabaseCopyAutoActivationPolicy Unrestricted

#Resumes the transport queues and allows the server to accept and process messages
Write-Verbose "Transport Queues on $Server are now active."
Set-ServerComponentState $Server -Component HubTransport -State Active -Requester Maintenance

Write-Host "$Server is now fully out of maintenance mode. You should now redistribute active database copies in the DAG." -ForegroundColor Green

