import std/strutils
import std/os

let entireFile = readFile("nimble.svg")

proc adjustVersion(v: string): string =
    let badgeTemp = entireFile.replace("v1.11.11", v)
    let displacement: float = 145 + ((v.len.float - 8.0) * 23)
    result = badgeTemp.replace("154.131839", $displacement)


proc echoHelp() = echo """
To use form command line, provide parameters. Currently supported usage:

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
