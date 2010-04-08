/* -*- mode: java; c-basic-offset: 2; indent-tabs-mode: nil -*- */
/**
 * Interfaces
 */

/**
 * Interface elements that can be pressed should implement the
 * Pressable interface.
 */
interface Pressable {
  /**
   * Invoke press when this Pressable is pressed.
   */
  void press();
}

/**
 * Interface elements that can be drawn should implement the Drawable
 * interface
 */
interface Drawable {
  /**
   * Invoke draw to draw a Drawable object.
   */
  void draw();
}
