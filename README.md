# coreml-test
CoreML Test on watchOS

This repo does two things:

1. Trains an activity classifier CoreML model on synthetic data using Turicreate.
2. Tests the CoreML model's predictions on a fixed data set (csv) within a watchOS app.

This was built with Xcode 10 and the default target I've tested on in the simluator is `iPhone XS Max + Apple Watch Series 4 - 44mm (watch OS 5.0)`.

I also recommend testing on `iPhone X + Apple Watch Series 3 - 42mm (watchOS 4.2)`. This can be accomplished by doing the following:

1. Click "CoreML Test WatchKit App" as your build target.
2. Navigate to the right arrow to bring up the device list.
3. Click on "Add Additional Simulators...".
4. Under "Simulators" click on "iPhone X".
5. Click the "+" button to add a 42mm Apple Watch Series 3 on watchOS 4.2.
