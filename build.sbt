ThisBuild / version := "0.1.0-SNAPSHOT"

ThisBuild / scalaVersion := "3.2.1"

lazy val root = (project in file("."))
  .settings(
    name := "meetup_demo",
    libraryDependencies += "ru.tinkoff" %% "muffin-sttp-http-interop" % "0.2.1",
    libraryDependencies += "ru.tinkoff" %% "muffin-circe-json-interop" % "0.2.1",
    libraryDependencies += "ru.tinkoff" %% "muffin-http4s-http-interop" % "0.2.1",
    libraryDependencies += "com.softwaremill.sttp.client3" %% "armeria-backend-cats" % "3.8.5",
    libraryDependencies += "org.tpolecat" %% "doobie-core" % "1.0.0-RC2",
    libraryDependencies += "org.tpolecat" %% "doobie-postgres" % "1.0.0-RC2",
    libraryDependencies += "com.github.pureconfig" %% "pureconfig-core" % "0.17.2",
    libraryDependencies += "org.http4s" %% "http4s-ember-server" % "1.0.0-M37"
  )
  .enablePlugins(JavaAppPackaging, DockerPlugin)
