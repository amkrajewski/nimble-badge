import std/strutils
import std/os
import std/httpclient
import std/json
import std/times

let rootSVG = readFile("nimble.svg")

proc adjustVersion(v: string, rootSVG: string = rootSVG): string =
    if v.len < 10:
        let displacement: float = 145 + ((v.len.float - 8.0) * 23)
        result = rootSVG.replace("v1.11.11", v).replace("154.131839", $displacement)
    else:
        let newFont: float = 63 * (8.75 / v.len.float)
        let centering: float = 382 - newFont.float * 0.5
        result = rootSVG.replace("v1.11.11", v)
                        .replace("154.131839", "165")
                        .replace("350.01234", $centering)
                        .replace("63.01234", $newFont)

proc echoHelp() = echo """
To use form command line, plase provide parameters. Currently supported usage:

--deployBadges N    | -db N    --> Deploy badges for 500 packages in the nimble packages repo starting 
                                   from Nth 500 (N<=9 for now). This is to avoid rate limiting. This 
                                   parameter must be first if multiple are provided.
--deploy V          | -d V     --> Deploy one badge for a specific version V and save it to versionedBadge.svg
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
        for version in ["v1", "v1.1", "v1.1.1", "v1.1.11", "v1.11.11", "v11.11.11", 
                        "v2", "v2.2", "v2.2.2", "v2.2.22", "v2.22.22", "v22.22.22",
                        "2023.1.1", "2023.11.1", "2023.11.11", "v2023.11.11", "v2023.11.11.post2"]:
            writeFile("testFiles/somenimble" & version.replace(".", "").replace("v", "V") & ".svg", adjustVersion(version))

    if "--deployBadges" in args or "-db" in args:
        if args.len < 2 or not args[1][0].isDigit:
            echo "Please provide a number after --deployBadges or -db"
            quit(1)
        
        let packagesJSON = parseFile("packages/packages.json")
        echo "Total packages: " & $packagesJSON.len

        var client = newHttpClient(timeout=10000)
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
                    let urlString = url.getStr()
                    var query: string
                    if "github" in urlString:
                        query = "https://api.github.com/repos/" & 
                                urlString
                                .replace("https://github.com/", "")
                                .replace(".git", "") & 
                                "/tags"
                        query = query.replace("//", "/").replace(":/", "://")
                        client.headers = newHttpHeaders({"authorization": "Bearer " & os.getEnv("GITHUB_TOKEN")})
                    elif "gitlab" in urlString:
                        query = "https://gitlab.com/api/v4/projects/" & 
                                urlString
                                .replace("https://gitlab.com/", "")
                                .replace(".git", "")
                                .replace("/", "%2F")  & 
                                "/repository/tags"
                        query = query.replace("//", "/").replace(":/", "://")
                        client = newHttpClient(timeout=10000)
                    else:
                        echo "-> API not implemented: " & name
                        continue
                    if verbose: 
                        echo query
                    sleep(100)
                    let clinetResponse = client.get(query)
                    if verbose: 
                        echo clinetResponse.status
                    if clinetResponse.status == "404 Not Found":
                        echo "-> 404 - could not resolve URL: " & name
                        continue
                    if clinetResponse.status == "200 OK":
                        let githubTagJSON = parseJSON(clinetResponse.body)
                        if githubTagJSON.kind != JArray:
                            echo "-> OK - but not JArray of tags: " & name
                            continue
                        if githubTagJSON.len == 0:
                            echo "-> OK - but no tags for: " & name
                            continue
                        let version = githubTagJSON[0]{"name"}
                        if isNil version:
                            echo "-> OK - but cannot obtain version for: " & name
                            continue
                        else:
                            let versionstring = version.getStr()
                            echo "-> OK - " & name & " - " & versionstring
                            writeFile("badges/" & name & ".svg",
                                      adjustVersion(versionstring)
                                      .replace("https://github.com/amkrajewski/nimble-badge", urlString))
                            updatedN += 1
                else:
                    echo "-> Skipping package without a URL: " & name
            else:
                echo "-> Skipping alias package: " & name
        echo "Updated " & $updatedN & " badges"
    
    if "--deploy" in args or "-d" in args:
        if args.len < 2:
            echo "Please provide a version after --deploy or -d"
            quit(1)
        let version = args[1]
        echo "Deploying badge for version: " & version
        writeFile("versionedBadge.svg", adjustVersion(version))
        echo "Done!"




