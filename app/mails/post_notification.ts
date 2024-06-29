import { BaseMail } from '@adonisjs/mail'
import env from '#start/env'
import Post from '#models/post'
import logger from '@adonisjs/core/services/logger'

export default class PostNotification extends BaseMail {
  post
  sender = env.get('MAILTRAP_SENDER', '')
  recipient = env.get('EMAIL_RECIPIENT', '')

  constructor(post: Post) {
    super()
    this.post = post
  }

  prepare() {
    logger.info('Sending mail to %s', this.recipient)

    const title = `Message from ${this.post.name}`
    const reply = `Reply to ${this.post.address}`
    const paragraphs = this.post.message.split('\n').filter(Boolean)

    this.message
      .to(this.recipient)
      .replyTo(this.post.address)
      .from(`"Mailtrap 📧" <${this.sender}>`)
      .subject(`Mailtrap message from ${this.post.name}`)
      .textView('emails/post_email_text', { title, paragraphs, reply })
      .htmlView('emails/post_email_html', { title, paragraphs, reply })
  }
}
