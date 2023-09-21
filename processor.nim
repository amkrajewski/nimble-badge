import std/strutils
import std/os
import std/httpclient
import std/json

let rootSVG = readFile("nimble.svg")

proc adjustVersion(v: string): string =
    let displacement: float = 145 + ((v.len.float - 8.0) * 23)
    result = rootSVG.replace("v1.11.11", v).replace("154.131839", $displacement)

proc echoHelp() = echo """
To use form command line, plase provide parameters. Currently supported usage:

--deployBadges N    | -db N    --> Deploy badges for 500 packages in the nimble packages repo starting 
                                   from Nth 500 (N<=9 for now). This is to avoid rate limiting. This 
                                   parameter must be first if multiple are provided.
--versionLengthTest | -vlt     --> Test how version length affects text placement
--verbose           | -vrb     --> A bit more verbose output

"""

when isMainModule:
    let args = commandLineParams()
    if args.len == 0:
        echoHelp()

    let verbose: bool = "--verbose" in args or "-vrb" in args

    if "--versionLengthTest" in args or "-vlt" in args:
        echo "Testing how version length affects text placement"
        writeFile("testFiles/somenimbleV1.svg", adjustVersion("v1"))
        writeFile("testFiles/somenimbleV11.svg", adjustVersion("v1.1"))
        writeFile("testFiles/somenimbleV111.svg", adjustVersion("v1.1.1"))
        writeFile("testFiles/somenimbleV1111.svg", adjustVersion("v1.1.11"))
        writeFile("testFiles/somenimbleV11111.svg", adjustVersion("v1.11.11"))
        writeFile("testFiles/somenimbleV111111.svg", adjustVersion("v11.11.11"))
        writeFile("testFiles/somenimbleV2.svg", adjustVersion("v2"))
        writeFile("testFiles/somenimbleV22.svg", adjustVersion("v2.2"))
        writeFile("testFiles/somenimbleV222.svg", adjustVersion("v2.2.2"))
        writeFile("testFiles/somenimbleV2222.svg", adjustVersion("v2.2.22"))
        writeFile("testFiles/somenimbleV22222.svg", adjustVersion("v2.22.22"))
        writeFile("testFiles/somenimbleV222222.svg", adjustVersion("v22.22.22"))

    if "--deployBadges" in args or "-db" in args:
        if args.len < 2 or not args[1][0].isDigit:
            echo "Please provide a number after --deployBadges or -db"
            quit(1)
        
        let packagesJSON = parseFile("packages/packages.json")
        echo "Total packages: " & $packagesJSON.len

        var client = newHttpClient()
        client.headers = newHttpHeaders({"authorization": "Bearer " & os.getEnv("GITHUB_TOKEN")})

        var updatedN: int = 0
        let min = (args[1].parseInt - 1) * 500
        let max = args[1].parseInt * 500
        echo "Updating badges from " & $min & " to " & $max
        
        for i in min .. max:
            if i >= packagesJSON.len:
                echo "Reached end of packages"
                break
            let package = packagesJSON[i]
            let name = package["name"].getStr()
            if i == 0:
                echo "First package JSON:", $package
            if isNil package{"alias"}:
                let url = package{"url"}
                if not isNil url:
                    let query = "https://api.github.com/repos/" & url.getStr().replace("https://github.com/", "").replace(".git", "") & "/tags"
                    if verbose: 
                        echo query
                    let clinetResponse = client.get(query)
                    if verbose: 
                        echo clinetResponse.status
                    if clinetResponse.status == "404 Not Found":
                        echo "-> 404 - could not resolve URL: " & name
                        continue
                    if clinetResponse.status == "200 OK":
                        let githubTagJSON = parseJSON(clinetResponse.body)
                        if githubTagJSON.len == 0:
                            echo "-> 200 - but no tags for: " & name
                            continue
                        let version = githubTagJSON[0]{"name"}
                        if isNil version:
                            echo "-> 200 - but cannot obtain version for: " & name
                            continue
                        else:
                            let versionstring = version.getStr()
                            echo "-> 200 - " & name & " - " & versionstring
                            writeFile("badges/" & name & ".svg", adjustVersion(versionstring))
                            updatedN += 1
                else:
                    echo "-> Skipping package without URL: " & name
            else:
                echo "-> Skipping alias package: " & name
        echo "Updated " & $updatedN & " badges"




