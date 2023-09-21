# Nimble Badge

Hi! This fork of [@yglukhov](https://github.com/yglukhov)'s [nimble-tag repository](https://github.com/yglukhov/nimble-tag) extends the original graphical design by Amy Shaw (in [this PR](https://github.com/yglukhov/nimble-tag/pull/1)) by adding versioning to the tag.

<img src="nimble.svg" height="24"/>

## Manual Deploy
You can change it to whatever you desire by opening the _raw_ SVG at this repository root with a text editor and replacing the `v1.11.11` with your version. Or whatever else you want! You can also replace it with your package name to attach it to some larger project badges indicating nim was used. Then simply include it in your HTML (or HTML in Markdown)

        <img src="nimble.svg" height="24"/>


## Automatic Versioning Deployment
I played a bit with automating the process for people relying on a small script written in, obviously, Nim, utilized in GitHub Actions. I got to the point where it seems both pretty usable and stable. In short, during the workflow, `nim-lang/packages` submodule is updated, and its `packages.json` is parsed to obtain links to all Nimble repositories. Then I iterate to (1) get `name` version string from latest _tag_ of each repository, (2) adjust the version string in SVG, (3) adjust its position, (4) store the result in `/badges` under `<<name>>.svg`. Git is then used to automatically detect diff (changes) and commit new/updated badges.

>Note: The release version is obtained with a call to GitHub API, which has an hourly rate limit (free version), so the script is running with windows of 500. It runs twice a day (1-6 am/pm UTC) on the first 3,000 Nimble packages (there are 2,264 as of September 2023), but can be quickly extended to 6,000.

To use it simply replace below `<<name>>` with your Nimble package name

        <img src="https://raw.githubusercontent.com/amkrajewski/nimble-badge/master/badges/<<name>>.svg" height="24"/>
