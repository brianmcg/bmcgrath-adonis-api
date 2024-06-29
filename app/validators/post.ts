import vine from '@vinejs/vine'

/**
 * Validates the post's creation action
 */
export const createPostValidator = vine.compile(
  vine.object({
    name: vine.string().trim().escape(),
    address: vine.string().trim().escape(),
    message: vine.string().trim().escape(),
  })
)

/**
 * Validates the post's update action
 */
export const updatePostValidator = vine.compile(
  vine.object({
    name: vine.string().trim().escape(),
    address: vine.string().trim().escape(),
    message: vine.string().trim().escape(),
  })
)
