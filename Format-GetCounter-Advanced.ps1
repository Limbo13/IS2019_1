Function Format-GetCounter{
    [CmdletBinding()]
    Param([Parameter(ValueFromPipeline)]$CounterList)
    process{
        $MyPSObject = [PSCustomObject]@{
            Path = $CounterList.CounterSamples.Path
            CookedValue = $CounterList.CounterSamples.CookedValue
        }

        $CounterArray = @()
        $DateStamp = Get-Date -Format "MM/dd/yyyy hh:mm:ss tt"
        $RowCountRaw = $MyPSObject.Path | Measure
        [int]$RowCount = [math]::Round($RowCountRaw.Count)
        [int]$CurrRow = 0

        $MyPSObject | %{
            Do{
            $CurrPath = $_.Path[$CurrRow]
            $CurrValue = $_.CookedValue[$CurrRow]

            $FirstSlashes = $CurrPath.IndexOf("\\")
            $SecondSlash = $CurrPath.IndexOf("\",3)
            $ThirdSlash = $CurrPath.IndexOf("\",$SecondSlash+2)
            $PathLen = ($CurrPath).Length
            $CompName = $CurrPath.Substring(2,$SecondSlash-$FirstSlashes-2)
            if ($CurrPath.Substring($SecondSlash+1,1) -eq "\")
            {
                $CSet = $CurrPath.Substring($SecondSlash+2,$ThirdSlash-$SecondSlash-2)
            }
            else {
                $CSet = $CurrPath.Substring($SecondSlash+1,$ThirdSlash-$SecondSlash-1)
            }
            $CType = $CurrPath.Substring($ThirdSlash+1,$PathLen-$ThirdSlash-1)

            $CounterInfo = New-Object -TypeName psobject
            $CounterInfo | Add-Member -Type NoteProperty -Name Computername -Value $CompName
            $CounterInfo | Add-Member -Type NoteProperty -Name Counterset -Value $CSet
            $CounterInfo | Add-Member -Type NoteProperty -Name Counter -Value $CType
            $CounterInfo | Add-Member -Type NoteProperty -Name CounterValue -Value $CurrValue

            $CounterArray += $CounterInfo

            $CurrRow++

            Write-Output $CurrPath
            } Until ($CurrRow -eq $RowCount)
        }

        Write-Output " "
        Write-Output "Timestamp: $DateStamp"
        Write-Output $CounterArray
    }
}
