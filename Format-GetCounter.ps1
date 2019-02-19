Function Format-GetCounter{
    [CmdletBinding()]
    Param([Parameter(ValueFromPipeline)]$CounterList)
    process{
        $MyPSObject = [PSCustomObject]@{
            Path = $CounterList.CounterSamples.Path
            CookedValue = $CounterList.CounterSamples.CookedValue
        }

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
            $CSet = $CurrPath.Substring($SecondSlash+2,$ThirdSlash-$SecondSlash-2)
            $CType = $CurrPath.Substring($ThirdSlash+1,$PathLen-$ThirdSlash-1)

            Write-Output "Datetime    : $DateStamp"
            Write-Output "Computername: $CompName"
            Write-Output "Counterset  : $CSet"
            Write-Output "Counter     : $CType"
            Write-Output "Value       : $CurrValue"
            Write-Output " "

            $CurrRow++
            } Until ($CurrRow -eq $RowCount)
        }
    }
}
