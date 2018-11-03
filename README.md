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
[MIT][1]

[1]:	https://choosealicense.com/licenses/mit/