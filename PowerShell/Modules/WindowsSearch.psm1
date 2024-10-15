using namespace Microsoft.Search.Interop

#-------------------------------------------------------------------------------

function Assert-WindowsSearchLocation {
    <#
        .SYNOPSIS
            Ensures the specified file path is
            included in the Windows Search index.

        .PARAMETER Path
            The path to the directory to be included in the index.
    #>

    [CmdletBinding()]
    param(
        [Parameter(Position = 0, Mandatory, ValueFromPipeline)]
        [string] $Path
    )

    process {
        # Load the assembly containing the Windows Search API
        Add-Type -Path "$PSScriptRoot\..\..\Resources\Microsoft.Search.Interop.dll"

        # Provides methods that make changes across all catalogs.
        # https://learn.microsoft.com/en-us/windows/win32/search/-search-3x-wds-mngidx-searchmanager
        $searchManager = New-Object CSearchManagerClass

        # Provides mesthods that make changes to a single catalog.
        # (Currently, this is the only catalog Windows Search uses.)
        # https://learn.microsoft.com/en-us/windows/win32/search/-search-3x-wds-mngidx-catalog-manager
        $catalogManager = $searchManager.GetCatalog('SystemIndex')

        # Provides methods to inform the Windows Search engine about containers to crawl
        # and items under those containers to include or exclude in the catalog.
        # https://learn.microsoft.com/en-us/windows/win32/search/-search-3x-wds-extidx-csm
        $crawlScopeManager = $catalogManager.GetCrawlScopeManager()

        # Add the specified path to the index
        Write-Host "Ensuring '$Path' is registered with indexer ..."
        $crawlScopeManager.AddUserScopeRule("file:///$Path", $true, $false, $null)
        $crawlScopeManager.SaveAll()
    }
}

#-------------------------------------------------------------------------------

Export-ModuleMember -Function Assert-WindowsSearchLocation
