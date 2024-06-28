import { BaseSeeder } from '@adonisjs/lucid/seeders'
import User from '#models/user'
import env from '#start/env'

export default class extends BaseSeeder {
  async run() {
    const user = await User.findBy('username', env.get('API_USERNAME'))

    if (!user) {
      await User.create({
        username: env.get('API_USERNAME'),
        password: env.get('API_PASSWORD'),
      })
    }
  }
}
