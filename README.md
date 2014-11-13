# Recipe Web

# Development

## Getting set up

### Software Prerequisites

This software must be installed:

1. JDK 1.7.0+ [\\bell\engineering\bootstrap\install\java-jdk](file://bell/illuminate/Engineering/Bootstrap/install/java-jdk/jdk-7u67-windows-x64.exe)
2. Leiningen [Windows Installer](http://leiningen-win-installer.djpowell.net/)
3. Lein-simpleton - [static file server](https://github.com/tailrecursion/lein-simpleton) (Optional) (open `%userprofile%\.lein\profile.clj`)
3. Node.js & NPM

Leiningen downloads project dependencies with the `lein deps` command.

NPM downloads project dependencies with the `npm install` command.

### Additional steps

To run the program while debugging the IntellispaceCrawler windows service, run `symlink-content.cmd` from the IntellispaceCrawler's output directory, for example:

    c:\ws\clinical.intellispace.connect\IntellispaceCrawler\bin\Debug>symlink-content.cmd

## Developing with ClojureScript

There are two builds profiles defined in [project.clj](project.clj), dev and release.  The are rather drastically different, both in terms of build time and in the built artifacts.  Building release takes about a minute, while building dev is a tiny fragment of the time.  This is made even faster by leaving lein up and running, watching the disk for changes to the source code, and automatically rebuilding.

#### Cleaning the project (clean)

    lein clean, cljsbuild clean

#### Building the dev profile only (once)

    lein cljsbuild once dev

#### Serving the dev files

Use this command to build the dev profile whenever a .cljs file changes (auto).  This command continues running until you end it (ctrl+C).

    start lein cljsbuild auto dev

Remember, if you change project.clj, you'll need to restart leiningen.

Ths command runs a static file server on the specified port.  This command continues running until you end it (ctrl+C).

    start lein simpleton 17655
    explorer http://localhost:17655/public/index-dev.html

Now, with these programs running, when you make a cljs code change, the `lein cljsbuild auto` command will re-build it nearly instantly.  Then, you can refresh the browser to get the latest code.  All of this without restarting the Crawler!


#### Building the release profile

    lein deps, clean, cljsbuild clean, cljsbuild once release

## Developing with Om/React/ClojureScript

### Libraries in play

* [Om](https://github.com/swannodette/om) - A [ClojureScript](https://github.com/clojure/clojurescript) interface to Facebook's [React](http://facebook.github.io/react/).  Why Om?  Om takes react and makes it more awesome by using perisistent data structures to make things fast and a sensible approach to managing state changes.

* [React](http://facebook.github.io/react/) - Build the UI from the data and when the data changes, the UI does automagically, without messy object watchers or explicit management of state.  When the UI is built virtually, React efficiently compares the new version to the old version and only updates the necessary DOM.

* [ClojureScript](https://github.com/clojure/clojurescript) - A LISP dialect that transpiles to JavaScript (well, the ugly kind of JavaScript that the Google Closure Compiler can turn into amazingly fast JavaScript that runs on many different browsers).  This avoids the idiosyncracies (and bad parts) of JavaScript by using a consistent language.

* [Om-Tools](https://github.com/Prismatic/om-tools) - More friendly OM DOM and componenents.

