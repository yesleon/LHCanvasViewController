# LHSketchKit

LHSketchKit is a swift framework for building drawing apps.

## Installation

1. Use the Open in Xcode button to import the framework into you project/workspace.
2. Add the framework to your project’s Embedded Binaries.

## Usage

```swift
import LHSketchKit

class MyViewController: UIViewController {

    func presentCanvasViewController() {
        let canvasVC = LHCanvasViewController(image: nil)
        canvasVC.delegate = self
        present(canvasVC, animated: true)
    }

}

extension MyViewController: LHCanvasViewControllerDelegate {

    func canvasViewController(_ canvasVC: LHCanvasViewController, didSave image: UIImage) {
        self.imageView.image = image
        dismiss(animated: true)
    }

    func canvasViewControllerDidCancel(_ canvasVC: LHCanvasViewController) {
        dismiss(animated: true)
    }

}
```

## Contributing
Pull requests are welcomed. For major changes, please open an issue first to discuss what you would like to change.

Please make sure to update tests as appropriate.

## License

MIT License

Copyright (c) 2018 Li-Heng Hsu

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
