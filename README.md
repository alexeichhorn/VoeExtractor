# VoeExtractor

Extracts raw video urls from any voe.sx video.

## Usage
Get video path from voe url:
```swift
let url = URL(string: "https://voe.sx/e/8vi96tm5uufc")!
VoeExtractor.extract(fromURL: url) { result in
    // do stuff with retrieved videoURL
}
```
or using async/await:
```swift
let videoURL = try await VoeExtractor.extract(fromURL: url)
```
