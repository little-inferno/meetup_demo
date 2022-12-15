package md

import cats.syntax.all.given
import cats.effect.kernel.Sync
import doobie.Transactor
import doobie.syntax.all.{*, given}
import doobie.postgres.syntax.{*, given}

case class Answer(id: Long, value: String, count: Long)
case class Question(id: Long, content: String, answers: List[Answer])

trait StatisticRepo[F[_]] {
  def vote(questionId: Long): F[Unit]

  def getQuestions: F[List[Question]]
}

object StatisticRepo {
  class Live[F[_]: Sync](xa: Transactor[F]) extends StatisticRepo[F] {
    def vote(questionId: Long): F[Unit] =
      for {
        count <- sql"select cc from answer where id=$questionId"
          .query[Int]
          .unique
          .transact(xa)
        _ <-
          sql"update answer set cc=${count + 1} where id=$questionId".update.run
            .transact(xa)
      } yield ()

    def getQuestions: F[List[Question]] = {
      (for {
        questionContents <- sql"select id, content from question"
          .query[(Long, String)]
          .to[List]

        questions <- questionContents.traverse { (id, content) =>
          sql"select id, value, cc from answer where question_id=$id"
            .query[Answer]
            .to[List]
            .map(Question(id, content, _))
        }
      } yield questions).transact(xa)
    }
  }
}
