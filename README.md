# Nimble Badge

**TLDR:**
Hi! This fork of [@yglukhov](https://github.com/yglukhov)'s [nimble-tag repository](https://github.com/yglukhov/nimble-tag) extends the original graphical design by Amy Shaw (in [this PR](https://github.com/yglukhov/nimble-tag/pull/1)). It (1) adds versioning to the badge, (2) [automates the process](#automatic-versioning-deployment) with a small pure-Nim tool `processor.nim` I wrote, and (3) statically hosts badges for all Nimble packages under [`badges`](https://github.com/amkrajewski/nimble-badge/tree/master/badges) (updated every 12h). Unsolicited feedback, pull requests, and forking are encouraged 😊

<img src="nimble.svg" height="24">

## Manual Deploy
You can change it to whatever you desire by opening the _raw_ SVG at this repository root with a text editor and replacing the `v1.11.11` with your version. Or whatever else you want! You can also replace it with your package name to attach it to some larger project badges indicating Nim was used. Then simply include it in your HTML (or HTML in Markdown)

        <img src="my-nimble.svg" height="24">


## Automatic Versioning Deployment
I played a bit with automating the process for people relying on a small script written in, obviously, Nim, utilized in GitHub Actions. I got to the point where it seems both pretty usable and stable. In short, during the workflow, `nim-lang/packages` submodule is updated, and its `packages.json` is parsed to obtain links to all Nimble repositories. Then I iterate to (1) get `name` version string from the latest _tag_ of each repository, (2) adjust the version string in SVG, (3) adjust its position, (4) store the result in `/badges` under `<<name>>.svg`. Git is then used to automatically detect diff (changes) and commit new/updated badges.

>Note: The tag name/version is obtained with a call to GitHub API, which has an hourly rate limit (on the free tier), so the script runs with a scope of 500. It runs twice a day (1,2,3,4,5,6 am/pm UTC) on the first 3,000 Nimble packages (there are 2,264 as of September 2023), but can be quickly extended to 6,000.

To use it simply replace below `<<name>>` with your Nimble package name

        <img src="https://raw.githubusercontent.com/amkrajewski/nimble-badge/master/badges/<<name>>.svg" height="24">

## Some Examples

- **nim**:&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; <img src="https://raw.githubusercontent.com/amkrajewski/nimble-badge/master/badges/nim.svg" height="24">
- **nimble**: &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<img src="https://raw.githubusercontent.com/amkrajewski/nimble-badge/master/badges/nimble.svg" height="24">
- **inim**: &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<img src="https://raw.githubusercontent.com/amkrajewski/nimble-badge/master/badges/inim.svg" height="24">
- **arraymancer**:&nbsp; <img src="https://raw.githubusercontent.com/amkrajewski/nimble-badge/master/badges/arraymancer.svg" height="24">

## Notes:

- Aliases are skipped and will not show up in badges for conciseness.
- **`.nimble` files are not parsed, and the version stored in them is ignored. This is intended behavior established by nimble [per their contribution requirements](https://github.com/nim-lang/packages/#releasing-a-new-package-version), which requires you to _git tag_ your release.**
- As of September 2023, when iterating over `packages.json`, around half of the packages do not resolve the version using [the procedure described above](#automatic-versioning-deployment). By far, the majority of misses are because _git tags_ are missing from the repo, despite nimble requirements.
- Ocassionally, e.g. [neverwinter.nim](https://github.com/niv/neverwinter.nim), I noticed that the tags returned with GitHub API are behind what the web page returns. No idea why, beyond that, maybe `.` interferes with API, and I would appreciate some insight.
- Packages living in a subdirectory, such as those in [`nim-lang/graveyard`](https://github.com/nim-lang/graveyard) are currently not implemented, as they tend to be deprecated versions or smaller parts of larger tools, but could be if there is a need.
- If you wonder why your badge is missing and this README is not helping, please first go through the last workflow printouts you can find under `Actions > Everyday at Xam pm > <<last run>> > generateBadges > Generate Badges`. The package should be under one of the `X` workers.
- Unsolicited feedback, pull requests, and forking are encouraged 😊