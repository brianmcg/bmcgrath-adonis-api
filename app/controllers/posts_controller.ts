import type { HttpContext } from '@adonisjs/core/http'
import Post from '#models/post'
import { createPostValidator, updatePostValidator } from '#validators/post'

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

    const payload = await request.validateUsing(createPostValidator)

    const post = await Post.create(payload)

    return response.status(201).json(post)
  }

  /**
   * Handle form submission for the edit action
   */
  async update({ logger, params, request, response }: HttpContext) {
    logger.info('Fetching post by id %s', params.id)

    const post = await Post.find(params.id)

    if (post) {
      const payload = await request.validateUsing(updatePostValidator)

      post.name = payload.name
      post.address = payload.address
      post.message = payload.message

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
