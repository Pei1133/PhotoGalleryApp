# Photo Gallery

## Feature
  - PhotoViewController
    - Use SegmentedControl to change photo view style to list or grid layout.
    - Infinite scroll: Retrieve next page photos when scroll down to the end of view.(maximum page number is 5)
    - Apply animation block to make transition effect between layouts.
    - Show correct image on cells, prevent images changing suddenly, and even a few different cells from the same image.

  - PhotoViewModel
    - Get cell size information according to list or grid layout. 
    - Search photos from https://api.imgur.com/.
    
  - ImageLoader
    - Use NSCache to store downloaded image, and re-download them if no cache.
    - When cell is used again, cancel the downloading operation.
  
## Design Pattern
  - MVVM