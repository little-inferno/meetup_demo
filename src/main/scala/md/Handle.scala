package md

import cats.syntax.all.given
import cats.effect.kernel.Sync
import io.circe.{Decoder, Encoder}
import muffin.api.ApiClient
import muffin.model.*
import muffin.dsl.*

import muffin.interop.json.circe.codec.given

trait DemoHandler[F[_]] {
  def vote(ctx: CommandAction): F[AppResponse[Nothing]]

  def stats(ctx: CommandAction): F[AppResponse[Nothing]]

  def dialog(ctx: DialogAction[Unit]): F[AppResponse[Nothing]]
}

object DemoHandler {
  class Live[F[_]: Sync](
      api: ApiClient[F, Encoder, Decoder],
      repo: StatisticRepo[F]
  ) extends DemoHandler[F] {
    def vote(ctx: CommandAction): F[AppResponse[Nothing]] = {
      for {
        questions: List[Question] <- repo.getQuestions
        form = questions.map { q =>
          Element.Select(
            q.content,
            q.id.toString,
            options = q.answers.map(a => SelectOption(a.value, a.id.toString))
          )
        }
        _ <- api.openDialog(
          ctx.triggerId,
          api.dialog("handler/dialog"),
          Dialog("Ответь на пару вопросов", (), elements = form)
        )
      } yield ok
    }.handleError { err =>
      ok
    }

    def stats(ctx: CommandAction): F[AppResponse[Nothing]] = {
      for {
        votes: List[Question] <- repo.getQuestions
        attachments = votes.map { question =>
          Attachment(
            Some(question.content),
            text = Some(question.content),
            fields = question.answers.map(answer =>
              AttachmentField(answer.value, answer.count.toString, true)
            )
          )
        }
        _ <- api.postToChannel[Nothing](
          ctx.channelId,
          Some("Результаты:"),
          Props(attachments)
        )
      } yield ok
    }.handleError { err =>
      ok
    }

    def dialog(ctx: DialogAction[Unit]): F[AppResponse[Nothing]] = {
      ctx.submission.toList
        .traverse((_, value) => repo.vote(value.toInt))
        .as(ok)
    }
  }
}
