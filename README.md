Paper [![Build Status](https://destroystokyo.com/ci/job/Paper/badge/icon)](https://destroystokyo.com/ci/job/Paper/)
===========

High performance Spigot fork that aims to fix gameplay and mechanics inconsistencies.

[IRC Support and Project Discussion](http://irc.spi.gt/iris/?channels=paper)

[Discord](https://discord.gg/jETyjUw)


Documentation
------
Access the Paper docs here: [paper.readthedocs.io](https://paper.readthedocs.io/)  
Access the Paper API javadocs here: [destroystokyo.com/javadocs](https://destroystokyo.com/javadocs/)

How To (Server Admins)
------
Paperclip is a jar file that you can download and run just like a normal jar file.

Download a copy of paperclip.jar from [our build server, here](https://destroystokyo.com/ci/job/PaperSpigot/).

Run the Paperclip jar directly from your server. Just like old times

Paper requires [**Java 8**](http://www.oracle.com/technetwork/java/javase/downloads/jdk8-downloads-2133151.html) or above.

How To (Compiling Jar From Source)
------
To compile Paper, you need JDK 8 and an internet connection. Gradle and Maven
wrappers are included, so no system-wide Gradle or Maven installation is needed.

On Windows:

```bat
gradlew.bat applyPatches
gradlew.bat build
gradlew.bat runServer
```

On Linux/macOS, use the same tasks through `./gradlew`.

`runServer` builds the API and server before launching it. The test server lives
in `work/test-server` and uses port `25566` by default. Optional environment
variables are `PAPER_JAVA_HOME`, `PAPER_TEST_MEMORY`, `PAPER_TEST_PORT`,
`PAPER_TEST_DIR`, and `PAPER_DEBUG_PORT`.
Run `gradlew.bat paperTasks` (or `./gradlew paperTasks`) for all Paper-specific
tasks.

How To (Pull Request)
------
See [Contributing](CONTRIBUTING.md)

Special Thanks To:
-------------

![YourKit-Logo](https://www.yourkit.com/images/yklogo.png)

[YourKit](http://www.yourkit.com/), makers of the outstanding java profiler, support open source projects of all kinds with their full featured [Java](https://www.yourkit.com/java/profiler/index.jsp) and [.NET](https://www.yourkit.com/.net/profiler/index.jsp) application profilers. We thank them for granting Paper an OSS license so that we can make our software the best it can be.
