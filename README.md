#Welcome to "What's the MotA? (Meaning of this Acronym)

## Code Setup

A couple of housekeeping notes on project setup.  This project utilizes both AFNetworking and MBProgressHUD.  The Xcode project references these two projects but this respository does not include any of the source code or complied frameworks produced by those projects. These two projects were cloned from GitHub into a shared coded directory with the following structure:

* MotA/
* 3rdParty_Code/AFNetworking/
* 3rdParty_Code/MBProgressHUD/

To eliminate setup and compilation headaches, it is advised to mirror this directory structure on your computer.  If you already have AFNetworking and MBProgressHUD projects stored elsewhere on your computer, you can open the MotA Xcode project file and fix the file references to these two projects. Note that you must also update the Header File Search Paths for both these directories (in the Build Settings) if your project is not set up as noted above.

## Project Notes

The base functionality of the application is there in this single pane app - user enters any text (presumably an actual acronym), the app will put up a progress spinner while on a background thread a query is made to look up possible matches for the submitted acronym.  Once the network operation is complete (success or failed) the progress spinner is hidden - any returned results will be displayed in a list.  Additional searches can then be made.

This application relies on the addition of an Apple Transport Security override in the plist allowing the use of an insecure connection to the acronym service server.  The server does not support https so using the ATS override was necessary (though discouraged by Apple)

The app was built with iPhone and iPad in mind.  The code works fine on both but due to some issues with layout constraints iPad deployment and UI rotation are currently disabled.

Though there is quite a bit that could be done to make the UI more interesting, it would take more time to focus on who the target audience would be for this app.  As such, the user interface is quite plain.  The one mild bit of dynacism included is a somewhat subtly color shifting background.

All code was written new for this project - no past projects or online works were referenced in the creation of this simple code sample.

Enjoy!
