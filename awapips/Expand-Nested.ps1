function Expand-NestedProperty {
    [CmdletBinding()]
    param (
        [Parameter( Position=0,
                    Mandatory=$true,
                    ValueFromPipeline=$true,
                    ValueFromPipelineByPropertyName=$true,
                    ValueFromRemainingArguments=$false,
                    HelpMessage='Object required...' )]
        $InputObject
    )
    begin {
        function ExpandNestedProperty {
            [CmdletBinding()]
            param (
                [Parameter( Position=0,
                            Mandatory=$true,
                            ValueFromPipeline=$true,
                            ValueFromPipelineByPropertyName=$true,
                            ValueFromRemainingArguments=$false,
                            HelpMessage='Object required...' )]
                $InputObject,
                [Parameter( Position=1,
                            Mandatory=$false,
                            ValueFromPipeline=$false,
                            ValueFromPipelineByPropertyName=$true,
                            ValueFromRemainingArguments=$false,
                            HelpMessage='String required...' )]
                [string]
                $FullyQualifiedName = ""
            )
            begin {
                $localResults =@()
                $FQN = $FullyQualifiedName
                $nestedProperties = $null
            }
            process {
                foreach ($obj in $InputObject.psobject.Properties) {
                    if ($(try {$obj.Value[0] -is [PSCustomObject]} catch {$false})) { # Catch 'Cannot index into a null array' for null values
                        # Nested properties
                        $FQN = "$($FullyQualifiedName).$($obj.Name)"
                        $nestedProperties = $obj.value | ExpandNestedProperty -FullyQualifiedName $FQN
                    }
                    elseif ($obj.Value -is [array]) {
                        # Array property
                        $FQN = "$($FullyQualifiedName).$($obj.Name)"
                        [psobject]$nestedProperties = @{
                            $FQN = ($obj.Value -join ';')
                        }
                    }
                    # Example of how to deal with generic case. 
                    # This needed for the Get-Process values ([System.Collections.ReadOnlyCollectionBase] and [System.Diagnostics.FileVersionInfo]) that are not [array] collection type.
<#
                    elseif ($obj.Value -is [System.Collections.ICollection]) { 
                        # Nested properties
                        $FQN = "$($FullyQualifiedName).$($obj.Name)"
                        $nestedProperties = $obj.value | ExpandNestedProperty -FullyQualifiedName $FQN
                    }
#>
                    else { # ($obj -is [PSNoteProperty]) for this case, but could be any type
                        $FQN = "$($FullyQualifiedName).$($obj.Name)"
                        [psobject]$nestedProperties = @{
                            $FQN = $obj.Value
                        }
                    }
                    $localResults += $nestedProperties
                } #foreach $obj
            }
            end {
                [pscustomobject]$localResults
            }
        } # function ExpandNestedProperty
        $objectNumber = 0
        $firstObject = @()
        $otherObjects = @()
    }
    process {
        if ($objectNumber -eq 0) {
            $objectNumber++
            $firstObject = $InputObject[0] | ExpandNestedProperty
        }
        else {
            if ($InputObject -is [array]) {
                foreach ($nextInputObject in $InputObject[1..-1]) {
                    $objectNumber++
                    $otherObjects += ,($nextInputObject | ExpandNestedProperty)
                }
            }
            else {
                $objectNumber++
                $otherObjects += ,($InputObject | ExpandNestedProperty)
            }
        }
    }
    end {
        # Output CSV header and a line for each object which was the specific requirement here.  
        # Could create an array of objects using $firstObject + $otherObjects that is then piped to Export-CSV if we want a generic case.
        Write-Output "`"$($firstObject.Keys -join '","')`""
        Write-Output "`"$($firstObject.Values -join '","')`""
        foreach ($otherObject in $otherObjects) {
            Write-Output "`"$($otherObject.Values -join '","')`""
        }
    }
}
