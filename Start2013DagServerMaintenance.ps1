<#
.NOTES
Written by Justin Beeden
V2.0 11.16.2013
    2.0 Added logic to confirm DAG File Share Witness is operational to maintain quorum
        Added logic to confirm QueueTargetFQDN is a FQDN, will attempt to resolve to FQDN if hostname is entered
        Added logic to confirm mail queues have been moved to QueueTargetFQDN
        Added logic to confirm all active database copies have been moved to another DAG member
    1.1 Corrected Spelling error in one of the parameters
    1.0 Initial 
.SYNOPSIS
Puts Exchange 2013 DAG nodes into maintenance mode.
.DESCRIPTION
Puts Exchange 2013 DAG nodes into maintenance mode.
http://technet.microsoft.com/en-us/library/dd298065%28v=exchg.150%29.aspx#Pm
.PARAMETER Server
Specifies the DAG node Server name to be put into maintenance mode.
.PARAMETER QueueTargetFQDN
Specifies the target Exchange 2013 mailbox server FQDN to move the mail queue to from the Server to be put into maintenance mode.
.EXAMPLE
PS> .\Start2013DagServerMaintenance.ps1 -Server Server1 -QueueTargetFQDN Server2.contoso.com
Puts Server1 into maintenace mode and moves all queued mail to Server2 for delivery
#>

#Requires -version 3.0

[CmdletBinding()]
Param(
    [Parameter(Position=0, Mandatory = $true,
    HelpMessage="Enter the name of the DAG Server to put into Maintenance mode.")]
    [string]$Server,

    [Parameter(Position=1, Mandatory = $true,
    HelpMessage="Enter FQDN of server to move mail queue to.")]
    [string]$QueueTargetFQDN
)
Begin
{
    try{
        #If QueueTargetFQDN is not enterend as a FQDN will attempt to resolve it to a FQDN
        $TargetServer = ([System.Net.Dns]::GetHostByName($QueueTargetFQDN)).Hostname
       }
   catch{
        #If above does not resolve to a valid FQDN script will throw error and quit script
        Throw "Could not resolve ServerFQDN: $QueueTargetFQDN hostname needs to be resolvable FQDN."}
        }
Process
{
    #Function to check all transport queues except Poison and Shadow queues are empty 
    function CheckQueues(){
        $MessageCount = Get-Queue -Server $Server | Where {$_.Identity -notlike "*\Poison" -and $_.Identity -notlike"*\Shadow\*"} |
        Select MessageCount | Where {$_.MessageCount -ne 0}
            if($MessageCount){
                Write-Host "$Server still has messages in transport queue, will check again in 30 seconds..." -ForegroundColor Yellow
                Start-Sleep -s 30
                CheckQueues
            }
            else{
                Write-Host "Transport queues are empty." -ForegroundColor Green
                }
            }
    
    #Function to check all active database copies have been moved to another member of the DAG    
    function CheckActiveDatabase(){
        $ActiveDatabase = Get-MailboxDatabaseCopyStatus -Server $Server | Where {$_.Status -eq 'Mounted'}
               if($ActiveDatabase){
                    Write-Host "$Server is still hosting active database copies, will check again in 30 seconds..." -ForegroundColor Yellow
                    Start-Sleep -s 30
                    CheckActiveDatabase
                }
                else{
                    Write-Host "All active database copies have been moved." -ForegroundColor Green
                    }
        }

    #Function to check on DAGs File Share Witness if needed by DAG
    function CheckFSW(){
        $FSW = Get-DatabaseAvailabilityGroup -Identity $Server.DatabaseAvailabilityGroup -Status | Where {$_.WitnessShareInUse -eq 'InvalidConfiguration'}
             if($FSW){
                   Throw "There is an issue with this DAGs File Share Witness, fix BEFORE doing node maintenance."
                }
                else{
                    Write-Host "DAG File Share Witness OK or not in use." -ForegroundColor Green
                    }
        }

    Write-Verbose "Checking DAG File Share Witness"
    CheckFSW

    Write-Verbose "Begining the process of draining the transport queues"
    Set-ServerComponentState $Server -Component HubTransport -State Draining -Requester Maintenance 

    Write-verbose "Begining the process of draining all Unified Messaging calls"
    Set-ServerComponentState $Server -Component UMCallRouter –State Draining –Requester Maintenance

    Write-Verbose "Redirecting messages pending delivery in the local queues to $QueueTargetFQDN"
    Redirect-Message -Server $Server -Target $TargetServer -Confirm:$false

    Write-Verbose "Pausing the cluster node, which prevents the node from being and becoming the PrimaryActiveManager"
    Suspend-ClusterNode $Server

    Write-Verbose "Moving all active databases currently hosted on $Server to other DAG members"
    Set-MailboxServer $Server -DatabaseCopyActivationDisabledAndMoveNow $True

    Write-Verbose "Preventing $Server from hosting active database copies"
    Set-MailboxServer $Server -DatabaseCopyAutoActivationPolicy Blocked

    Write-Verbose "Placing $Server into maintenance mode"
    Set-ServerComponentState $Server -Component ServerWideOffline -State Inactive -Requester Maintenance
    }
End
{   
    CheckQueues

    CheckActiveDatabase

    Write-Host "$Server is fully in maintenance mode and ready for maintenance." -ForegroundColor Green
    }