/*
|--------------------------------------------------------------------------
| Routes file
|--------------------------------------------------------------------------
|
| The routes file is used for defining the HTTP routes.
|
*/

import router from '@adonisjs/core/services/router'
import PostsController from '#controllers/posts_controller'
import { middleware } from '#start/kernel'

router.get('up', () => 'Server is up!')

router
  .group(() => {
    router
      .group(() => {
        router.get('posts', [PostsController, 'index'])
        router.get('posts/:id', [PostsController, 'show'])
        router.post('posts', [PostsController, 'store'])
      })
      .prefix('/v1')
  })
  .prefix('/api')
  .use(middleware.auth({ guards: ['basicAuth'] }))
