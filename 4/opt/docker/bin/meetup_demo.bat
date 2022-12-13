@REM meetup_demo launcher script
@REM
@REM Environment:
@REM JAVA_HOME - location of a JDK home dir (optional if java on path)
@REM CFG_OPTS  - JVM options (optional)
@REM Configuration:
@REM MEETUP_DEMO_config.txt found in the MEETUP_DEMO_HOME.
@setlocal enabledelayedexpansion
@setlocal enableextensions

@echo off


if "%MEETUP_DEMO_HOME%"=="" (
  set "APP_HOME=%~dp0\\.."

  rem Also set the old env name for backwards compatibility
  set "MEETUP_DEMO_HOME=%~dp0\\.."
) else (
  set "APP_HOME=%MEETUP_DEMO_HOME%"
)

set "APP_LIB_DIR=%APP_HOME%\lib\"

rem Detect if we were double clicked, although theoretically A user could
rem manually run cmd /c
for %%x in (!cmdcmdline!) do if %%~x==/c set DOUBLECLICKED=1

rem FIRST we load the config file of extra options.
set "CFG_FILE=%APP_HOME%\MEETUP_DEMO_config.txt"
set CFG_OPTS=
call :parse_config "%CFG_FILE%" CFG_OPTS

rem We use the value of the JAVA_OPTS environment variable if defined, rather than the config.
set _JAVA_OPTS=%JAVA_OPTS%
if "!_JAVA_OPTS!"=="" set _JAVA_OPTS=!CFG_OPTS!

rem We keep in _JAVA_PARAMS all -J-prefixed and -D-prefixed arguments
rem "-J" is stripped, "-D" is left as is, and everything is appended to JAVA_OPTS
set _JAVA_PARAMS=
set _APP_ARGS=

set "APP_CLASSPATH=%APP_LIB_DIR%\meetup_demo.meetup_demo-0.1.0-SNAPSHOT.jar;%APP_LIB_DIR%\org.scala-lang.scala3-library_3-3.2.1.jar;%APP_LIB_DIR%\ru.tinkoff.muffin-sttp-http-interop_3-0.2.1.jar;%APP_LIB_DIR%\ru.tinkoff.muffin-circe-json-interop_3-0.2.1.jar;%APP_LIB_DIR%\ru.tinkoff.muffin-http4s-http-interop_3-0.2.1.jar;%APP_LIB_DIR%\com.softwaremill.sttp.client3.armeria-backend-cats_3-3.8.5.jar;%APP_LIB_DIR%\org.tpolecat.doobie-core_3-1.0.0-RC2.jar;%APP_LIB_DIR%\org.tpolecat.doobie-postgres_3-1.0.0-RC2.jar;%APP_LIB_DIR%\com.github.pureconfig.pureconfig-core_3-0.17.2.jar;%APP_LIB_DIR%\org.http4s.http4s-ember-server_3-1.0.0-M37.jar;%APP_LIB_DIR%\org.scala-lang.scala-library-2.13.10.jar;%APP_LIB_DIR%\ru.tinkoff.muffin-core_3-0.2.1.jar;%APP_LIB_DIR%\com.softwaremill.sttp.client3.core_3-3.8.5.jar;%APP_LIB_DIR%\io.circe.circe-core_3-0.15.0-M1.jar;%APP_LIB_DIR%\io.circe.circe-parser_3-0.15.0-M1.jar;%APP_LIB_DIR%\org.http4s.http4s-core_3-1.0.0-M37.jar;%APP_LIB_DIR%\org.http4s.http4s-dsl_3-1.0.0-M37.jar;%APP_LIB_DIR%\com.softwaremill.sttp.client3.armeria-backend_3-3.8.5.jar;%APP_LIB_DIR%\com.softwaremill.sttp.client3.cats_3-3.8.5.jar;%APP_LIB_DIR%\org.tpolecat.doobie-free_3-1.0.0-RC2.jar;%APP_LIB_DIR%\org.scala-lang.modules.scala-collection-compat_3-2.6.0.jar;%APP_LIB_DIR%\org.tpolecat.typename_3-1.0.0.jar;%APP_LIB_DIR%\co.fs2.fs2-io_3-3.3.0.jar;%APP_LIB_DIR%\org.postgresql.postgresql-42.3.1.jar;%APP_LIB_DIR%\com.typesafe.config-1.4.2.jar;%APP_LIB_DIR%\org.http4s.http4s-ember-core_3-1.0.0-M37.jar;%APP_LIB_DIR%\org.http4s.http4s-server_3-1.0.0-M37.jar;%APP_LIB_DIR%\org.typelevel.log4cats-slf4j_3-2.5.0.jar;%APP_LIB_DIR%\co.fs2.fs2-core_3-3.3.0.jar;%APP_LIB_DIR%\org.typelevel.cats-core_3-2.9.0.jar;%APP_LIB_DIR%\org.typelevel.cats-effect_3-3.3.14.jar;%APP_LIB_DIR%\com.softwaremill.sttp.model.core_3-1.5.3.jar;%APP_LIB_DIR%\com.softwaremill.sttp.shared.core_3-1.3.10.jar;%APP_LIB_DIR%\com.softwaremill.sttp.shared.ws_3-1.3.10.jar;%APP_LIB_DIR%\io.circe.circe-numbers_3-0.15.0-M1.jar;%APP_LIB_DIR%\io.circe.circe-jawn_3-0.15.0-M1.jar;%APP_LIB_DIR%\org.typelevel.case-insensitive_3-1.3.0.jar;%APP_LIB_DIR%\org.typelevel.cats-effect-std_3-3.4.2.jar;%APP_LIB_DIR%\org.typelevel.cats-parse_3-0.3.8.jar;%APP_LIB_DIR%\com.comcast.ip4s-core_3-3.2.0.jar;%APP_LIB_DIR%\org.typelevel.literally_3-1.1.0.jar;%APP_LIB_DIR%\org.scodec.scodec-bits_3-1.1.34.jar;%APP_LIB_DIR%\org.typelevel.vault_3-3.3.0.jar;%APP_LIB_DIR%\org.log4s.log4s_3-1.10.0.jar;%APP_LIB_DIR%\com.linecorp.armeria.armeria-1.20.3.jar;%APP_LIB_DIR%\org.typelevel.cats-effect-kernel_3-3.4.2.jar;%APP_LIB_DIR%\org.typelevel.cats-free_3-2.7.0.jar;%APP_LIB_DIR%\org.checkerframework.checker-qual-3.5.0.jar;%APP_LIB_DIR%\org.typelevel.log4cats-core_3-2.5.0.jar;%APP_LIB_DIR%\com.twitter.hpack-1.0.2.jar;%APP_LIB_DIR%\org.http4s.http4s-crypto_3-0.2.4.jar;%APP_LIB_DIR%\org.slf4j.slf4j-api-1.7.36.jar;%APP_LIB_DIR%\org.typelevel.cats-kernel_3-2.9.0.jar;%APP_LIB_DIR%\org.typelevel.jawn-parser_3-1.2.0.jar;%APP_LIB_DIR%\com.fasterxml.jackson.core.jackson-core-2.13.4.jar;%APP_LIB_DIR%\com.fasterxml.jackson.core.jackson-annotations-2.13.4.jar;%APP_LIB_DIR%\com.fasterxml.jackson.core.jackson-databind-2.13.4.jar;%APP_LIB_DIR%\com.fasterxml.jackson.datatype.jackson-datatype-jdk8-2.13.4.jar;%APP_LIB_DIR%\com.fasterxml.jackson.datatype.jackson-datatype-jsr310-2.13.4.jar;%APP_LIB_DIR%\io.micrometer.micrometer-core-1.9.4.jar;%APP_LIB_DIR%\io.netty.netty-transport-4.1.82.Final.jar;%APP_LIB_DIR%\io.netty.netty-codec-haproxy-4.1.82.Final.jar;%APP_LIB_DIR%\io.netty.netty-codec-http2-4.1.82.Final.jar;%APP_LIB_DIR%\io.netty.netty-resolver-dns-4.1.82.Final.jar;%APP_LIB_DIR%\org.reactivestreams.reactive-streams-1.0.4.jar;%APP_LIB_DIR%\com.google.code.findbugs.jsr305-3.0.2.jar;%APP_LIB_DIR%\io.netty.netty-transport-native-unix-common-4.1.82.Final-linux-x86_64.jar;%APP_LIB_DIR%\io.netty.netty-transport-native-epoll-4.1.82.Final-linux-x86_64.jar;%APP_LIB_DIR%\io.netty.netty-resolver-dns-native-macos-4.1.82.Final-osx-x86_64.jar;%APP_LIB_DIR%\io.netty.netty-resolver-dns-native-macos-4.1.82.Final-osx-aarch_64.jar;%APP_LIB_DIR%\io.netty.netty-tcnative-boringssl-static-2.0.54.Final-linux-x86_64.jar;%APP_LIB_DIR%\io.netty.netty-tcnative-boringssl-static-2.0.54.Final-linux-aarch_64.jar;%APP_LIB_DIR%\io.netty.netty-tcnative-boringssl-static-2.0.54.Final-osx-x86_64.jar;%APP_LIB_DIR%\io.netty.netty-tcnative-boringssl-static-2.0.54.Final-osx-aarch_64.jar;%APP_LIB_DIR%\io.netty.netty-tcnative-boringssl-static-2.0.54.Final-windows-x86_64.jar;%APP_LIB_DIR%\io.netty.netty-handler-proxy-4.1.82.Final.jar;%APP_LIB_DIR%\com.aayushatharva.brotli4j.brotli4j-1.8.0.jar;%APP_LIB_DIR%\org.typelevel.simulacrum-scalafix-annotations_3-0.5.4.jar;%APP_LIB_DIR%\org.hdrhistogram.HdrHistogram-2.1.12.jar;%APP_LIB_DIR%\org.latencyutils.LatencyUtils-2.0.3.jar;%APP_LIB_DIR%\io.netty.netty-common-4.1.82.Final.jar;%APP_LIB_DIR%\io.netty.netty-buffer-4.1.82.Final.jar;%APP_LIB_DIR%\io.netty.netty-resolver-4.1.82.Final.jar;%APP_LIB_DIR%\io.netty.netty-codec-4.1.82.Final.jar;%APP_LIB_DIR%\io.netty.netty-handler-4.1.82.Final.jar;%APP_LIB_DIR%\io.netty.netty-codec-http-4.1.82.Final.jar;%APP_LIB_DIR%\io.netty.netty-codec-dns-4.1.82.Final.jar;%APP_LIB_DIR%\io.netty.netty-transport-native-unix-common-4.1.82.Final.jar;%APP_LIB_DIR%\io.netty.netty-transport-classes-epoll-4.1.82.Final.jar;%APP_LIB_DIR%\io.netty.netty-resolver-dns-classes-macos-4.1.82.Final.jar;%APP_LIB_DIR%\io.netty.netty-tcnative-classes-2.0.54.Final.jar;%APP_LIB_DIR%\io.netty.netty-codec-socks-4.1.82.Final.jar;%APP_LIB_DIR%\com.aayushatharva.brotli4j.native-osx-x86_64-1.8.0.jar"
set "APP_MAIN_CLASS=md.Application"
set "SCRIPT_CONF_FILE=%APP_HOME%\conf\application.ini"

rem Bundled JRE has priority over standard environment variables
if defined BUNDLED_JVM (
  set "_JAVACMD=%BUNDLED_JVM%\bin\java.exe"
) else (
  if "%JAVACMD%" neq "" (
    set "_JAVACMD=%JAVACMD%"
  ) else (
    if "%JAVA_HOME%" neq "" (
      if exist "%JAVA_HOME%\bin\java.exe" set "_JAVACMD=%JAVA_HOME%\bin\java.exe"
    )
  )
)

if "%_JAVACMD%"=="" set _JAVACMD=java

rem Detect if this java is ok to use.
for /F %%j in ('"%_JAVACMD%" -version  2^>^&1') do (
  if %%~j==java set JAVAINSTALLED=1
  if %%~j==openjdk set JAVAINSTALLED=1
)

rem BAT has no logical or, so we do it OLD SCHOOL! Oppan Redmond Style
set JAVAOK=true
if not defined JAVAINSTALLED set JAVAOK=false

if "%JAVAOK%"=="false" (
  echo.
  echo A Java JDK is not installed or can't be found.
  if not "%JAVA_HOME%"=="" (
    echo JAVA_HOME = "%JAVA_HOME%"
  )
  echo.
  echo Please go to
  echo   http://www.oracle.com/technetwork/java/javase/downloads/index.html
  echo and download a valid Java JDK and install before running meetup_demo.
  echo.
  echo If you think this message is in error, please check
  echo your environment variables to see if "java.exe" and "javac.exe" are
  echo available via JAVA_HOME or PATH.
  echo.
  if defined DOUBLECLICKED pause
  exit /B 1
)

rem if configuration files exist, prepend their contents to the script arguments so it can be processed by this runner
call :parse_config "%SCRIPT_CONF_FILE%" SCRIPT_CONF_ARGS

call :process_args %SCRIPT_CONF_ARGS% %%*

set _JAVA_OPTS=!_JAVA_OPTS! !_JAVA_PARAMS!

if defined CUSTOM_MAIN_CLASS (
    set MAIN_CLASS=!CUSTOM_MAIN_CLASS!
) else (
    set MAIN_CLASS=!APP_MAIN_CLASS!
)

rem Call the application and pass all arguments unchanged.
"%_JAVACMD%" !_JAVA_OPTS! !MEETUP_DEMO_OPTS! -cp "%APP_CLASSPATH%" %MAIN_CLASS% !_APP_ARGS!

@endlocal

exit /B %ERRORLEVEL%


rem Loads a configuration file full of default command line options for this script.
rem First argument is the path to the config file.
rem Second argument is the name of the environment variable to write to.
:parse_config
  set _PARSE_FILE=%~1
  set _PARSE_OUT=
  if exist "%_PARSE_FILE%" (
    FOR /F "tokens=* eol=# usebackq delims=" %%i IN ("%_PARSE_FILE%") DO (
      set _PARSE_OUT=!_PARSE_OUT! %%i
    )
  )
  set %2=!_PARSE_OUT!
exit /B 0


:add_java
  set _JAVA_PARAMS=!_JAVA_PARAMS! %*
exit /B 0


:add_app
  set _APP_ARGS=!_APP_ARGS! %*
exit /B 0


rem Processes incoming arguments and places them in appropriate global variables
:process_args
  :param_loop
  call set _PARAM1=%%1
  set "_TEST_PARAM=%~1"

  if ["!_PARAM1!"]==[""] goto param_afterloop


  rem ignore arguments that do not start with '-'
  if "%_TEST_PARAM:~0,1%"=="-" goto param_java_check
  set _APP_ARGS=!_APP_ARGS! !_PARAM1!
  shift
  goto param_loop

  :param_java_check
  if "!_TEST_PARAM:~0,2!"=="-J" (
    rem strip -J prefix
    set _JAVA_PARAMS=!_JAVA_PARAMS! !_TEST_PARAM:~2!
    shift
    goto param_loop
  )

  if "!_TEST_PARAM:~0,2!"=="-D" (
    rem test if this was double-quoted property "-Dprop=42"
    for /F "delims== tokens=1,*" %%G in ("!_TEST_PARAM!") DO (
      if not ["%%H"] == [""] (
        set _JAVA_PARAMS=!_JAVA_PARAMS! !_PARAM1!
      ) else if [%2] neq [] (
        rem it was a normal property: -Dprop=42 or -Drop="42"
        call set _PARAM1=%%1=%%2
        set _JAVA_PARAMS=!_JAVA_PARAMS! !_PARAM1!
        shift
      )
    )
  ) else (
    if "!_TEST_PARAM!"=="-main" (
      call set CUSTOM_MAIN_CLASS=%%2
      shift
    ) else (
      set _APP_ARGS=!_APP_ARGS! !_PARAM1!
    )
  )
  shift
  goto param_loop
  :param_afterloop

exit /B 0
