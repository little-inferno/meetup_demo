package md

import cats.syntax.all.given
import cats.effect.kernel.Sync
import io.circe.{Decoder, Encoder}
import muffin.api.ApiClient
import muffin.model.*
import muffin.dsl.*

import muffin.interop.json.circe.codec.given

trait SlashComand[F[_]] {
  def menu(ctx: CommandAction): F[AppResponse[Nothing]]
}

object SlashComand {
  class Live[F[_]: Sync](
      api: ApiClient[F, Encoder, Decoder],
      repo: StatisticRepo[F]
  ) extends SlashComand[F] {
    def menu(ctx: CommandAction): F[AppResponse[Nothing]] = {
      for {
        questions: List[Question] <- repo.getQuestions
        form = questions.foldLeft(dialog("Заполни форму")) { (acc, i) =>
          acc.element(
            Element.Select(
              i.name,
              i.name,
              options = i.answers.map(a => SelectOption(a, a)),
              optional = false
            )
          )
        }

        _ <- api.openDialog(
          ctx.triggerId,
          api.dialog("handler/dialog"),
          form.make
        )
      } yield ok
    }
  }

}
