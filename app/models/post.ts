import { DateTime } from 'luxon'
import { BaseModel, column, afterCreate } from '@adonisjs/lucid/orm'
import logger from '@adonisjs/core/services/logger'
import mail from '@adonisjs/mail/services/main'
import env from '#start/env'

const sender = env.get('MAILTRAP_SENDER', '')
const recipient = env.get('EMAIL_RECIPIENT', '')

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
  public static async hashPassword(post: Post) {
    logger.info('Sending mail to %s', recipient)

    const title = `Message from ${post.name}`
    const reply = `Reply to ${post.address}`
    const paragraphs = post.message.split('\n').filter(Boolean)

    mail.send((message) => {
      message
        .to(recipient)
        .from(`"Mailtrap 📧" <${sender}>`)
        .subject(`Mailtrap message from ${post.name}`)
        .textView('emails/post_email_text', { title, paragraphs, reply })
        .htmlView('emails/post_email_html', { title, paragraphs, reply })
    })
  }
}
