## Interactive Custom Transitions Demo in Swift

--

This is an demonstration of a Custom Transitions. 

The idea was to illustrate a custom "presentation" transition from the root scene to a navigation controller. The goal was to allow interactive gestures to swipe between three different scenes, A, B, and C underneath the navigation controller to illustrate custom "push" and "pop" transitions between the navigation controller's scenes. The goal was also to allow the user to swipe back to the root view controller, too.

To implement this, the suggestion was to implement a custom subclass of the navigation controller that would instantiate the custom animation controllers and interaction controllers as necessary:

<img src="http://i.stack.imgur.com/TCYGC.png" \>

The heart of this is entirely in the custom navigation controller which:

- Adds gesture recognizers to its view

 - If the gesture is right to left (i.e. push), this looks to see if the source controller conforms to `CustomNavigationControllerDelegate` protocol, namely a method `pushToNextScene` that will initiate the transition to the next scene.

 - If the gesture is left to right, this looks to see if there is more than one view controller in the stack, and if so, initiates a pop. If not, we're at the top level and it initiates a dismiss back to the root.

- This also sets the `transitioningDelegate` to yield the custom animation as you transition from the root scene to the navigation controller scene (and back):

- This sets the navigation controller's `delegate` 

- The `transitioningDelegate` and `UINavigationControllerDelegate` will also return the interaction controller (which will only exist while the gesture recognizer is in progress), yielding interactive transition during gesture and non-interactive transition if you dismiss outside of the context of the gesture.

See http://stackoverflow.com/questions/26680311/interactive-delegate-methods-never-called/26683223.

This is for illustrative purposes only.

Developed in Xcode 6.1 for iOS 8.0+, also tested on Xcode 6.0 Beta.

## License

Copyright &copy; 2014 Robert Ryan. All rights reserved.

<a rel="license" href="http://creativecommons.org/licenses/by-sa/4.0/"><img alt="Creative Commons License" style="border-width:0" src="http://i.creativecommons.org/l/by-sa/4.0/88x31.png" /></a><br />This work is licensed under a <a rel="license" href="http://creativecommons.org/licenses/by-sa/4.0/">Creative Commons Attribution-ShareAlike 4.0 International License</a>.

--

31 October 2014
