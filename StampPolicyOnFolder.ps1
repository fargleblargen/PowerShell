#find folder
ExchangeService service = new ExchangeService(ExchangeVersion.Exchange2013);

service.AutodiscoverUrl("https://mneexccas01.dev.droot.dmn/");
Mailbox mb = new Mailbox("cortana@obitest.com");

FindFoldersResults findResults = service.FindFolders(
    WellKnownFolderName.MsgFolderRoot,
    new FolderView(int.MaxValue));

foreach (Folder folder in findResults.Folders)
{
    Console.WriteLine(folder.DisplayName);
}








$getRTResp=$service.GetUserRetentionPolicyTags();

foreach ($rtTagin$getRTResp.RetentionPolicyTags) {
    if ($rtTag.DisplayName-eq"1 Month Delete")
    {
              $NewFolder=new-objectMicrosoft.Exchange.WebServices.Data.Folder($service)  
              $NewFolder.DisplayName="My New Folder12345"  
              $NewFolder.FolderClass="IPF.Note"
              $NewFolder.PolicyTag=New-Object

Microsoft.Exchange.WebServices.Data.PolicyTag($true,$rtTag.RetentionId)
              
			  $NewFolder.Save($folderid)  
    }  
}




    
Add-Type -Path "C:\Program Files\Microsoft\Exchange Server\V15\Bin\Microsoft.Exchange.WebServices.dll" 

$global:exchangeService = New-Object Microsoft.Exchange.WebServices.Data.ExchangeService([Microsoft.Exchange.WebServices.Data.ExchangeVersion]::Exchange2013) 
$exchangeService.Credentials = New-Object Microsoft.Exchange.WebServices.Data.WebCredentials -ArgumentList $creds.UserName, $creds.GetNetworkCredential().password 
$exchangeService.Url = "https://mneexccas01.dev.droot.dmn/EWS/Exchange.asmx" 
