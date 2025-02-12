function Get-DbaOleDbProvider {
    <#
    .SYNOPSIS
        This command gets a list of all ole db providers available on a server.

    .DESCRIPTION
        This command gets a list of all ole db providers available on a server.

    .PARAMETER SqlInstance
        The target SQL Server instance or instances.

    .PARAMETER SqlCredential
        Login to the target instance using alternative credentials. Accepts PowerShell credentials (Get-Credential).

        Windows Authentication, SQL Server Authentication, Active Directory - Password, and Active Directory - Integrated are all supported.

        For MFA support, please use Connect-DbaInstance.

    .PARAMETER Provider
        The name of the ole db provider.

    .PARAMETER EnableException
        By default, when something goes wrong we try to catch it, interpret it and give you a friendly warning message.
        This avoids overwhelming you with "sea of red" exceptions, but is inconvenient because it basically disables advanced scripting.
        Using this switch turns this "nice by default" feature off and enables you to catch exceptions with your own try/catch.

    .NOTES
        Tags: OLEDB
        Author: Chrissy LeMaire (@cl)

        Website: https://dbatools.io
        Copyright: (c) 2021 by dbatools, licensed under MIT
        License: MIT https://opensource.org/licenses/MIT

    .LINK
        https://dbatools.io/Get-DbaOleDbProvider

    .EXAMPLE
        PS C:\> Get-DbaOleDbProvider -SqlInstance SqlBox1\Instance2

        Returns a list of all OleDb providers on SqlBox1\Instance2

    .EXAMPLE
        PS C:\> Get-DbaOleDbProvider -SqlInstance SqlBox1\Instance2 -Provider SSISOLEDB

        Returns the SSISOLEDB provider on SqlBox1\Instance2
    #>
    [CmdletBinding(DefaultParameterSetName = "Default")]
    param (
        [parameter(Mandatory, ValueFromPipeline)]
        [DbaInstanceParameter[]]$SqlInstance,
        [PSCredential]$SqlCredential,
        [string[]]$Provider,
        [switch]$EnableException
    )
    process {
        foreach ($instance in $SqlInstance) {
            try {
                $server = Connect-DbaInstance -SqlInstance $instance -SqlCredential $SqlCredential
            } catch {
                Stop-Function -Message "Failure" -Category ConnectionError -ErrorRecord $_ -Target $instance -Continue
            }
            Write-Message -Level Verbose -Message "Getting startup procedures for $servername"

            $providers = $server.Settings.OleDbProviderSettings

            if ($Provider) {
                $providers = $providers | Where-Object Name -in $Provider
            }

            foreach ($oledbprovider in $providers) {
                Add-Member -Force -InputObject $oledbprovider -MemberType NoteProperty -Name ComputerName -value $server.ComputerName
                Add-Member -Force -InputObject $oledbprovider -MemberType NoteProperty -Name InstanceName -value $server.ServiceName
                Add-Member -Force -InputObject $oledbprovider -MemberType NoteProperty -Name SqlInstance -value $server.DomainInstanceName

                Select-DefaultView -InputObject $oledbprovider -Property 'ComputerName', 'InstanceName', 'SqlInstance', 'Name', 'Description', 'AllowInProcess', 'DisallowAdHocAccess', 'DynamicParameters', 'IndexAsAccessPath', 'LevelZeroOnly', 'NestedQueries', 'NonTransactedUpdates'
            }
        }
    }
}