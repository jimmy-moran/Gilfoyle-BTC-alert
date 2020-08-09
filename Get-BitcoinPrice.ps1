function Get-BitcoinPrice  
{ 
 <# 
        .SYNOPSIS 
            Gets the current price of bitcoin in a given currency 
 
        .DESCRIPTION 
            Uses the web api from Coindesk.com to retrieve the current 
            price in the specified currency. 
                         
        .PARAMETER Currency 
            The currency to get the bitcoin price in as denoted by the  
            three letter ISO 4217 currency code 
         
        .EXAMPLE 
            #Get the price in three different currencies 
            "Eur","gbp","USD" | Get-BitcoinPrice 
         
        .NOTES 
            Author: Tim Bertalot 
         
        .LINK 
            http://www.coindesk.com/api/ 
            http://gallery.technet.microsoft.com/site/search?query=lanatmwan&f%5B0%5D.Value=lanatmwan&f%5B0%5D.Type=SearchText&ac=4 
    #>  
     
    [CmdletBinding(   
        RemotingCapability        = "PowerShell", 
        SupportsShouldProcess   = $false, 
        ConfirmImpact           = "None", 
        DefaultParameterSetName = "" 
    )] 
          
    param 
    ( 
        [Parameter( 
            HelpMessage            = "Enter the currency to get the bitcoin value in", 
            Position            = 0, 
            ValueFromPipeline    = $true 
        )] 
        [ValidateNotNullOrEmpty()] 
        [ValidateSet("USD","EUR","GBP")] #exhaustive list of supported currencies: http://api.coindesk.com/v1/bpi/supported-currencies.json 
        [String[]] 
        $Currency = "USD" 
    ) 
     
    process 
    { 

        foreach ($item in $currency)  
        { 
            Invoke-WebRequest -Uri "http://api.coindesk.com/v1/bpi/currentprice/$Currency.json" | 
                Select-Object -ExpandProperty Content | 
                ConvertFrom-Json | 
                Foreach-Object  { 
                   
                   <# this is to get the timestamp if you want to save a ledger onto disk/storage#> 
                    filter timestamp {"$(Get-Date -Format G): $_"}
                   
                   <# this grabs the price only and disregards all other data that is not price in usd#>
                    $price = $_.bpi.$Currency | Select-Object -Unique "rate" 
                    
                    <# this is to store price data with YOUR computer timestamp "not coindesk time", you can block $addfile out if you do not want anything stored, otherwise change the location in "add-content" to specific .txt file location you want data saved to #>
                    $addfile = $price.rate | timestamp | Add-Content "D:\datafile.txt" 
                    $rounded = $price.rate -replace ",","" 
                    <# this only grabs the first 5-digits in the price output (no decimals, or ",",  it's not even rounded, but nobody needs that precision in price unless you have billions $ invested, in which case...help me#>
                    $final = $rounded.Substring(0,5) 
                    $final  # this prints the current price to console.  Not needed, but fun to watch
                    $target = 11600  #change this to target you want(formula is (target - 40)  you can replace "40" but also look at the "39" in the 'if' statement below to alerted when goes above this number    
                         if ($final -ge $target - 40) {
                    <# Im using windows10 with wmplay (windows media player) you need to download napalm-death 'you suffer' if you want to be just like gilfoyle's code, then use the exact location and replace ""C:\Users\18157\Music\You Suffer.mp3"" with your location.  Also, be sure wmplayer is already setup and opened previously to test. #>
                      & 'C:\Program Files (x86)\Windows Media Player\wmplayer' --qt-start-minimized --play-and-exit --qt-notification=0 "C:\Users\18157\Music\You Suffer.mp3"
                      start-sleep 4
                       while ($final -ge $target - 38) {Get-BitcoinPrice2}  # this calls the other function (2nd price target in Get-BitcoinPrice2)
                      }

            } <# the 'start-sleep' are put in place so the coindesk doesn't get unecessary queries and waste any disk space by cutting down the return also the possiblility to let that short ass song play #> 
 start-sleep 3
 Get-BitcoinPrice       
        } 
    } 
} 

