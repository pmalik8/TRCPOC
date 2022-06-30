param(
    [string]$passwordStr,
    [string]$serverUrl,
    [string]$username,
    [string]$orgName,
    [string]$solutionName,
    [string]$outputPath
)
Set-ExecutionPolicy Unrestricted -Scope CurrentUser
$scriptPath = split-path -parent $MyInvocation.MyCommand.Definition
Write-Host "Script Path: $scriptPath"
$crmCIToolkit = $scriptPath + "\Lib\Microsoft.Xrm.Data.Powershell.dll"
$xrmCIToolkit = $scriptPath + "\Lib\Xrm.Framework.CI.PowerShell.Cmdlets.dll"
Write-Host "Importing crmCIToolkit: $crmCIToolkit" 
Import-Module $crmCIToolkit

Write-Host "Imported CIToolkit"
Import-Module $xrmCIToolkit

$password = ConvertTo-SecureString $passwordStr -AsPlainText -Force
$Cred = New-Object System.Management.Automation.PSCredential ($username, $password)

$CRMSourceConn = Get-CrmConnection -ServerUrl  $serverUrl -Credential $Cred -OrganizationName $orgName

$fetchsolution = @"
             <fetch version="1.0" output-format="xml-platform" mapping="logical" distinct="true" no-lock="true">
               <entity name="solution">
                 <attribute name="solutionid"/>
                    <attribute name="uniquename" />
            <attribute name="version" />
            <filter type="and">     
                           <condition attribute="uniquename" operator="eq" value="$solutionName" />
                  </filter> 
               </entity>
             </fetch>
"@

    if($CRMSourceConn.IsReady)
            {
                Write-Host "Connected"
            }else{
                Write-Host "Not Connected"
            }

            $solution = Get-CrmRecordsByFetch -conn $CRMSourceConn -Fetch $fetchsolution
            $solution.Count
            $solutionversion = $solution.CrmRecords[0].version
            #$solutionid = $solution.CrmRecords[0].solutionid
            Write-Host "Current " $solutionName " Version is :::$solutionversion"
            $SolutionZipFileName1 = $solutionName+"_UnManaged_Dev_"+$fileNameDateFormat+".zip"
            Export-CrmSolution -conn $CRMSourceConn -SolutionName $solutionName -SolutionFilePath $unmanagedsolutionPath -SolutionZipFileName $SolutionZipFileName1 -ExportAutoNumberingSettings -ExportCalendarSettings -ExportCustomizationSettings -ExportEmailTrackingSettings -ExportGeneralSettings -ExportMarketingSettings -ExportOutlookSynchronizationSettings -ExportRelationshipRoles -ExportSales #-ErrorAction Stop
            $exportUnmanagedFile = Export-XrmSolution -ConnectionString "$CrmConnectionString" -UniqueSolutionName $SolutionName -OutputFolder "$outputPath" -Managed $false
            Write-Host "UnManaged Solution Exported $ExportSolutionOutputPath\$exportUnmanagedFile"
