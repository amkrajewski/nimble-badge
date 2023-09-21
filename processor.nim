import std/strutils
import std/os
import std/httpclient
import std/json
import std/times

let entireFile = readFile("nimble.svg")

proc adjustVersion(v: string): string =
    let badgeTemp = entireFile.replace("v1.11.11", v)
    let displacement: float = 145 + ((v.len.float - 8.0) * 23)
    result = badgeTemp.replace("154.131839", $displacement)


proc echoHelp() = echo """
To use form command line, provide parameters. Currently supported usage:

--deployBadges N    | -db N    --> Deploy badges for 500 packages in the nimble packages repo
                                   starting from Nth thousand. This is to avoid rate limiting.
--versionLengthTest | -vlt     --> Test how version length affects text placement


"""

when isMainModule:
    let args = commandLineParams()
    if args.len == 0:
        echoHelp()

    if "--versionLengthTest" in args or "-vlt" in args:

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
        let min = (args[1].parseInt - 1) * 500
        let max = args[1].parseInt * 500
        var client = newHttpClient()
        let packagesJSON = parseJSON(client.get("http://raw.githubusercontent.com/nim-lang/packages/master/packages.json").body)

        for i in min .. max:
            if i >= packagesJSON.len:
                echo "Reached end of packages"
                break
            let package = packagesJSON[i]
            if isNil package{"alias"}:
                let url = package{"url"}
                if not isNil url:
                    let clinetResponse = client.get("https://api.github.com/repos/" & url.getStr().replace("https://github.com/", "") & "/releases/latest")
                    echo clinetResponse.status
                    if clinetResponse.status == "404 Not Found":
                        echo "No Releases"
                        continue
                    if clinetResponse.status == "200 OK":
                        let githubRelease = parseJSON(clinetResponse.body)
                        let version = githubRelease{"tag_name"}
                        if isNil version:
                            continue
                        else:
                            writeFile("badges/" & package["name"].getStr() & ".svg", adjustVersion(version.getStr()))




