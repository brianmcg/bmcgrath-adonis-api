import type { HttpContext } from '@adonisjs/core/http'
import Post from '#models/post'

export default class PostsController {
	/**
	 * Display a list of resource
	 */
	async index({ response }: HttpContext) {
		const posts = await Post.all()
		return response.status(200).json(posts)
	}

	/**
	 * Show individual record
	 */
	async show({ params, response }: HttpContext) {
		const post = await Post.find(params.id)

		if (post) {
			return response.status(200).json(post)
		}

		return response.status(404).json({ message: 'Not found!' })
	}

	/**
	 * Handle form submission for the create action
	 */
	async store({ request, response }: HttpContext) {
		const { name, address, message } = request.body()
		const post = await Post.create({ name, address, message })
		return response.status(201).json(post)
	}

	/**
	 * Handle form submission for the edit action
	 */
	async update({ params, request, response }: HttpContext) {
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
	async destroy({ params, response }: HttpContext) {
		const post = await Post.find(params.id)

		if (post) {
			await post.delete()
			return response.status(204).json(null)
		}

		return response.status(404).json({ message: 'Not found!' })
	}
}
