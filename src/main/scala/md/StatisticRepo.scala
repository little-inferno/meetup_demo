package md

import cats.effect.kernel.Sync
import doobie.Transactor
import doobie.syntax.all.{*, given}

case class Question(name:String, answers:List[String])

trait StatisticRepo[F[_]] {

  //  def vote(): F[Unit]
  //
  //
  //  def getVotes:List[Int]

  def getQuestions: F[List[Question]]
}

object StatisticRepo {
  class Live[F[_]: Sync](xa:Transactor[F]) extends StatisticRepo[F] {
    def getQuestions: F[List[Question]] = {
      sql"select text, answers from questions"
        .query[Question]
        .to[List]
        .transact(xa)
    }
  }
}