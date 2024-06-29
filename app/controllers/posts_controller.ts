import type { HttpContext } from '@adonisjs/core/http'
import mail from '@adonisjs/mail/services/main'
import env from '#start/env'
import Post from '#models/post'

const sender = env.get('MAILTRAP_SENDER', '')
const recipient = env.get('EMAIL_RECIPIENT', '')

export default class PostsController {
  /**
   * Display a list of resource
   */
  async index({ logger, response }: HttpContext) {
    logger.info('Fetching all posts')

    const posts = await Post.all()

    return response.status(200).json(posts)
  }

  /**
   * Show individual record
   */
  async show({ logger, params, response }: HttpContext) {
    logger.info('Fetching post by id %s', params.id)

    const post = await Post.find(params.id)

    if (post) {
      return response.status(200).json(post)
    }

    return response.status(404).json({ message: 'Not found!' })
  }

  /**
   * Handle form submission for the create action
   */
  async store({ logger, request, response }: HttpContext) {
    logger.info('Creating new post')

    const { name, address, message } = request.body()

    const post = await Post.create({ name, address, message })

    const title = `Message from ${name}`
    const reply = `Reply to ${address}`
    const paragraphs = message.split('\n').filter(Boolean)

    logger.info('Sending mail to %s', recipient)

    mail.send((message) => {
      message
        .to(recipient)
        .from(`"Mailtrap 📧" <${sender}>`)
        .subject(`Mailtrap message from ${name}`)
        .textView('emails/post_email_text', { title, paragraphs, reply })
        .htmlView('emails/post_email_html', { title, paragraphs, reply })
    })

    return response.status(201).json(post)
  }

  /**
   * Handle form submission for the edit action
   */
  async update({ logger, params, request, response }: HttpContext) {
    logger.info('Fetching post by id %s', params.id)

    const post = await Post.find(params.id)

    if (post) {
      const { name, address, message } = request.body()

      post.name = name
      post.address = address
      post.message = message

      await post.save()

      return response.status(200).json(post)
    }

    return response.status(404).json({ message: 'Not found!' })
  }

  /**
   * Delete record
   */
  async destroy({ logger, params, response }: HttpContext) {
    logger.info('Deleting post by id %s', params.id)

    const post = await Post.find(params.id)

    if (post) {
      await post.delete()

      return response.status(204).json(null)
    }

    return response.status(404).json({ message: 'Not found!' })
  }
}
