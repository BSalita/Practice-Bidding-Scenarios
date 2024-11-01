param (
    [string]$WildCardScenarioSpec,
    [string[]]$OperationList
)

# Function to perform actions on the file
function Perform-Actions {
    param (
        [string]$File
    )
    echo "Performing actions on $File"
    Perform-Action -Operation "dlr" -File $File
    Perform-Action -Operation "pbn" -File $File
    Perform-Action -Operation "commentStats" -File $File
    Perform-Action -Operation "rotate" -File $File
    Perform-Action -Operation "bba" -File $File
    Perform-Action -Operation "bbaSummary" -File $File
    Perform-Action -Operation "title" -File $File
    Perform-Action -Operation "filter" -File $File
    Perform-Action -Operation "filterStats" -File $File
    Perform-Action -Operation "biddingSheet" -File $File
}

# Function to perform a specific action on the file
function Perform-Action {
    param (
        [string]$Operation,
        [string]$File
    )

    $Scenario = Split-Path -Path $File -Leaf

    switch ($Operation) {
        "dlr" {
            echo "--- Creating dlr\$Scenario from pbs\$Scenario"
            & python3 P:\py\OneExtract.py --scenario $Scenario
        }
        "pbn" {
            echo "--- Creating pbn\$Scenario.pbn from dlr\$Scenario.dlr"
            & P:\build-scripts\makeOnePBN.cmd $Scenario
        }
        "commentStats" {
            echo "--- Comment Stats for pbn\$Scenario.pbn"
            & python3 P:\py\oneComment.py --scenario $Scenario
        }
        "rotate" {
            echo "--- creating pbn-rotated-for-4-players and lin-rotated-for-4-players\$Scenario from pbn\$Scenario"
            & P:\build-scripts\makeOneRotated.cmd $Scenario
        }
        "bba" {
            echo "--- Creating bba\$Scenario.pbn from pbn\$Scenario.pbn"
            & P:\build-scripts\makeOneBBA.cmd $Scenario
        }
        "bbaSummary" {
            echo "--- Creating bbaSummary of bba\$Scenario.bba"
            & Python P:\py\oneSummary.py --scenario $Scenario
        }
        "title" {
            echo "--- Setting title for pbn\$Scenario.pbn"
            & P:\build-scripts\setOneTitle.ps1 $Scenario
        }
        "filter" {
            echo "--- Creating bba-filtered\ and bba-filtered-out from bba\$Scenario.pbn"
            & P:\build-scripts\filterOneScenario.cmd $Scenario
        }
        "filterStats" {
			if ($WildCardScenarioSpec -ne "*") {
				echo "--- Counting hands in bba-filtered\$Scenario.pbn"
				& P:\build-scripts\CountPattern.ps1 -FileSpec "P:\bba-filtered\$Scenario.pbn" -Pattern "\[Board"
			}
        }
        "biddingSheet" {
            echo "--- Creating bidding-sheets\$Scenario.pbn and bba\$Scenario.pdf from bba\$Scenario.pbn"
            & P:\build-scripts\makeOneBiddingSheet.cmd $Scenario
        }
        default {
            echo "--- Unknown operation: $Operation"
        }
    }
}
# Main script execution
if (-not $WildcardScenarioSpec -or -not $OperationList) {
    echo "Usage: .\OneScriptToRuleThemAll.ps1 [wildcard_file_specification] [operation]"
	echo "Operations:"
	echo "   dlr"
	echo "   pbn"
	echo "   commentStats"
	echo "   rotate"
	echo "   bba"
	echo "   bbaSummary"
	echo "   title"
	echo "   filter"
	echo "   filterStats"
	echo "   biddingSheet"
    exit 1
}

# If the operation is specified as a single entry ending with +, we will do all operations from
# the one specified through the end:
if (($OperationList.count -eq 1 ) -and ($OperationList[0][-1] -eq "+")) {

	switch ($OperationList) {
        "dlr+" {
            $OperationList = "dlr,pbn,commentStats,rotate,bba,bbaSummary,title,filter,filterStats,biddingSheet" -split ","
        }
        "pbn+" {
            $OperationList = "pbn,commentStats,rotate,bba,bbaSummary,title,filter,filterStats,biddingSheet" -split ","
        }
        "commentStats+" {
            $OperationList = "commentStats,rotate,bba,bbaSummary,title,filter,filterStats,biddingSheet" -split ","
        }
        "rotate+" {
            $OperationList = "rotate,bba,bbaSummary,title,filter,filterStats,biddingSheet" -split ","
        }
        "bba+" {
            $OperationList = "bba,bbaSummary,title,filter,filterStats,biddingSheet" -split ","
        }
        "bbaSummary+" {
            # bbaSummary has no downstream impact
            #$OperationList = "bbaSummary,filter,filterStats,makeBiddingSheet" -split ","
            $OperationList = "bbaSummary,title,filter,filterStats,biddingSheet" -split ","
        }
        "title+" {
            $OperationList = "title,filter,filterStats,biddingSheet" -split ","
        }
        "filter+" {
            $OperationList = "filter,filterStats,biddingSheet" -split ","
        }
        "filterStats+" {
            $OperationList = "filterStats,biddingSheet" -split ","
        }
        "biddingSheet+" {
            $OperationList = "biddingSheet" -split ","
        }
        default {
            echo "Unknown operation+: $OperationList"
        }
	}
}

# Check to see if we are going to filter all files:
$filterAll = (($OperationList -eq "filterStats") -or ($OperationList -eq "*")) -and ($WildCardScenarioSpec -eq "*")

# Check to see if we are only going to filter all files:
$onlyFilterAll = ($OperationList.count -eq 0) -and ($OperationList -eq "filterStats") -and $WildCardScenarioSpec -eq "*"

# Get files matching the wildcard specification
$files = Get-ChildItem -Path p:\pbs -Recurse -File | Where-Object { $_.Name -like $WildcardScenarioSpec } | Sort-Object Name

foreach ($file in $files) {
	if (-not $onlyFilterAll) {
		echo "Processing file: $file"

		if ($OperationList -eq "*") {
			Perform-Actions -File $file.FullName
		} else {
			# Loop through each item in the array and perform an action
			foreach ($Operation in $OperationList) {
				Write-Output "Processing Operation: $Operation"
				Perform-Action -Operation $Operation -File $file.FullName
			}		
		}
	}
}

# Finally, if we're performing all operations on all files, or filterStats on all files, run the Stats

# generator that will save the results to a single filter.csv file:
if ($filterAll) {
	echo "Writing all filter stats to P:\build-scripts\filterStats.csv . . ."
	& P:\build-scripts\getFilterStats.ps1
}

