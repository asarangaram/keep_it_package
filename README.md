
# KeepIt

KeepIt, a straightforward app for managing your photos and videos, developed with 'Keep It Simple, Stupid!' principle. 

## Features

You can capture moments with its camera, import media from your device, share from other apps, or drag and drop files from your computer. It prevents importing the same media twice and stores everything locally on your device for privacy and easy access. It's designed to make organizing and accessing your media hassle-free.

KeepIt offers basic image editing and video trimming features, allowing users to make simple adjustments to their photos and videos directly within the app.

The app includes a backup feature to protect against data loss by securely zipping all media and annotations. This allows users to easily export and import their photos and videos, preserving them with notes for future use. Users can also encrypt these backups for added security when storing them in the cloud, ensuring their privacy and protection from unauthorized access.

Each labeled collection in the app can be exported in two formats based on user choice: a zip file containing all media and annotations, optionally encrypted for added security when stored in the cloud or locally, or a PDF that organizes images according to user preferences, providing a structured format for easy viewing and sharing.

# What problem this application tries to solve

1. Privacy:
    Most gallery applications attempt to connect to and send content to various cloud services. Many of these applications do not use end-to-end encryption, leaving the content vulnerable to unauthorized access, sometimes even by the app developers themselves. As a result, their privacy policies may not be entirely trustworthy.
2. Lack of Organization
    Most apps encourage users to upload all their photos without classification. While albums can help organize them, they primarily focus on grouping photos by timeline. However, users often prefer to see only the photos they are searching for, rather than viewing all of them.
3. Writing Annotation 
    The feature of writing notes in many apps is often underutilized and not prominently featured, leading many users to be unaware of its existence and potential usefulness. This lack of visibility can result in missed opportunities for users to effectively organize and annotate their photos or other content.

There are few other use cases not addressed by the gallery applications

4. Preserve on Phone
    Sometimes, users want to preserve certain media for future reference under specific labels or categories. These photos should not be visible in their general gallery view. Users prefer to access them only when needed, without these photos appearing during casual browsing through their gallery.

5. 
    
    


## What this app is about?
    This app facilitates the collection of images and videos from multiple sources through various methods, catering to various preferences for gathering and managing media content.

    *Sharing via Share Intent*: Users can share media from any app that supports the Share Intent feature on iOS and Android platforms. This allows seamless integration of media from various apps into the collection.

    Importing from File System: Users can import media directly from their device's file system, enabling them to add existing photos and videos stored locally.

    Capture with Built-in Camera: The app includes a built-in camera feature for capturing new photos and videos directly within the app. This provides convenience for users who want to add fresh content to their collection.

    Drag and Drop on Desktop: Users can drag and drop media files directly onto the app's interface from desktop computers or other file management systems, simplifying the process of adding content from external sources.



    When importing media, this app prevents duplicate imports, ensuring that the same media is not added more than once. Additionally, all media is stored locally on the device itself, providing users with control over their content and ensuring privacy and accessibility without relying on external servers or cloud storage.



* media refers to either a image or video
## Pending Tasks
Issue 1: Preview
    Facing problem with Preview module. This needs to be relooked.
    One apprach is that we create the preview when we create the file, instead of waiting 
    till the preview is requested. 
    What will happen if the cache is cleared? we still need a provider that works with isolate
    to generate preview if it is missed. Need couple of days effort on this.

Issue2: Audio replay
    Now and then, the audio Notes don't play immediately after a audio recording. The root cause 
    is unknown. Need some investigation to understand the issue. The issue could be due to some 
    state variable getting affected when recording or may be the package we use has a bug or limitation.

Issue 3: Pin on Desktop
    Instead of Pinning to the photo gallery, we can simply implement pin that shows only in the Pinned media.
    Some tweaking will make it as an useful feature. May be we can call it as Favorites.

Issue 4: Audio recoding on Desktop
    Audio recording is working correctly on mobile application, but the package don't support desktop platforms.

Issue 5: Camera on Desktop
    Not a priority, but nice to have feature.

Issue 6: Camera preferences
    Need to have Camera preferences in settings.



## Test Requirements

| Feature |  status | Comments |
| --- | --- | --- |
| **image and video input** | | |
|   Accepts images and videos from any app | Ready ||
|   Able to browse the Gallery and add any number of images and videos | Ready ||
|   Able to take photo and video using Camera | Ready ||
|   Able to download image from a link | Pending ||
| **Collections View** |||
|   Shows all collections except empty collection |Ready||
|   Allows to insert images from gallery | Ready ||
|   Allows to take photo using camera | Ready||
|   Item Popup: Able to edit individual collection for name and description | Ready ||
|   Item Popup: Able to delete individual collection | Ready ||
|   Option to show empty collection | Pending ||
|   Able to refresh the list | Ready? ||
| **Collections View** |||
|   Allows to insert images from gallery | Ready ||
|   Allows to take photo using camera | Ready||
|   Item Popup: Able to move a single media  to any other gallery | Ready | |
|   Item Popup: Able to delete individual item | Ready | |
|   Item Popup: Able to share item to other apps | Ready ||
|   Item Popup: Able to edit an item | Ready |  |
|   Select: Able to select multiple items with 'Select All' in the timeline view | Ready ||
|   Select: Able to select all item of a group in  the timeline view | Ready ||
|   Select: Able to delete selected items | Ready ||
|   Select: Able to move selected items  to another collection | Ready ||
|   Select: Able to share selected items to another app | Ready ||
|   on Tap, open the item in item View |Ready||
|   Option to show deleted media | Pending ||
| **Item View** |||
|   Is possible to move to other items in the collection by swipe left and right | Ready ||
|   Edit icon is present and redirect to editor | In Progress | not available for video |
| **Error View** |||
|   Ensure error view is clean, and have a mechanism to return to previous page as well to home page | Pending ||
| **Loading View** |||
|   There must be a mechanism to abort the process and return to previous page as well to home page | Pending ||



* ImageViewService should accept media!
