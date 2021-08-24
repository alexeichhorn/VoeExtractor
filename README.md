# VoeExtractor

Extracts raw video urls from any voe.sx video.

## Usage
Get video path from voe url:
```
let url = URL(string: "https://voe.sx/e/8vi96tm5uufc")!
VoeExtractor.extract(fromURL: url) { videoURL in
    // do stuff with retrieved videoURL
}
```

