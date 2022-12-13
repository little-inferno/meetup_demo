package md

import cats.syntax.all.given
import cats.effect.{ExitCode, IO, IOApp}
import com.comcast.ip4s.{ipv4, port}
import doobie.util.transactor.Transactor
import io.circe.{Decoder, Encoder}
import muffin.api.{ApiClient, ClientConfig}
import muffin.interop.http.sttp.SttpClient
import sttp.client3.armeria.cats.ArmeriaCatsBackend
import muffin.interop.json.circe.codec
import muffin.interop.json.circe.codec.given
import muffin.interop.http.http4s.Http4sRoute
import muffin.dsl.*

import java.time.ZoneId
import org.http4s.ember.server.*
import org.http4s.server.Router
import pureconfig.*
import pureconfig.ConfigReader
import pureconfig.generic.derivation.default.*
import com.comcast.ip4s.Port
import muffin.model.ChannelId

case class DatabaseConfig(
  url: String,
  user: String,
  password: String
) derives ConfigReader

case class AppConfig(
  database: DatabaseConfig,
  mattermost: ClientConfig,
  port: Int
) derives ConfigReader

object Application extends IOApp.Simple {
  override def run: IO[Unit] =
    for {
      config <- IO.delay(ConfigSource.default.at("demo").loadOrThrow[AppConfig])

      _ = println("ASDASDASDNASOFNASOFAOSFMAOSFNAOSFNASSF")

      httpClient <- SttpClient[IO, IO, Encoder, Decoder](ArmeriaCatsBackend[IO](), codec)
      given ZoneId = ZoneId.systemDefault()
      apiClient    = ApiClient[IO, Encoder, Decoder](httpClient, config.mattermost)(codec)

      transactor = Transactor.fromDriverManager[IO]("", config.database.url, config.database.user, config.database.password)

      repository = StatisticRepo.Live[IO](transactor)
      handler = SlashComand.Live[IO](apiClient, repository)

      _ <- apiClient.postToChannel(ChannelId("dj8iazhshfdjinibqg1w5pbena"), Some("super kek"))

      router <- handle(handler, "handler")
        .command(_.menu)
        .in[IO, IO]()

      _ <- EmberServerBuilder
        .default[IO]
        .withHost(ipv4"0.0.0.0")
        .withPort(Port.fromInt(config.port).get)
        .withHttpApp(Router("/" -> Http4sRoute.routes[IO, Encoder, Decoder](router, codec)).orNotFound)
        .build
        .use(_ => IO.never)
        .as(ExitCode.Success)
    } yield ()
}
