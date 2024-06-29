import { DateTime } from 'luxon'
import { BaseModel, column, afterCreate } from '@adonisjs/lucid/orm'
import mail from '@adonisjs/mail/services/main'
import PostNotification from '#mails/post_notification'

export default class Post extends BaseModel {
  @column({ isPrimary: true })
  declare id: number

  @column()
  declare name: string

  @column()
  declare address: string

  @column()
  declare message: string

  @column.dateTime({ autoCreate: true })
  declare createdAt: DateTime

  @column.dateTime({ autoCreate: true, autoUpdate: true })
  declare updatedAt: DateTime

  @afterCreate()
  public static sendMail(post: Post) {
    mail.send(new PostNotification(post))
  }
}
