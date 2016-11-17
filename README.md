# MultiPeerConnectivity Example

The MultiPeerConnectivity (MPC) module offered with iOS allows devices to communicate with each other without using a central server. Instead, devices send data directly to each other using Bluetooth and WiFi. The range on this can be from a couple hundred feet for Bluetooth and WiFi, to an entire building if the devices are connected to the same WiFi network. 

This iOS app demonstrates how the MPC module can be used to create a temporary local social network. Users begin by creating a public profile with an image and some text. As devices discover other devices, they automatically send a request for each device's public profile, which appears on the app's main tab as data is received. From here, users can send text-based messages to each other. Each user's profile is updated as they come into and out of range to let the user know if they are available to receive messages.

## MPC Technical Overview

The MultiPeerConnectivity module is a bare bones module with very little technical documentation. The MCNearbyServiceAdvertiser advertises your device publically, while the MCNearbyServiceBrowser searches for advertised devices. The MCNearbyServiceAdvertiserDelegate responds to incoming connection requests, while the MCNearbyServiceBrowserDelegate responds to discovered/lost devices. The MCPeerID contains a public display-name and a dictionary of additional info that can be attached to the peer (such as a profile). Finally, the MCSessionDelegate responds to incoming data from any peer attached to the session.

## Implementation

Everything MPC related is contained within the custom ServiceManager class. The Advetiser and Browser are located here, as well as all code related to peer discovery, incoming invitations, and sending of data. The ServiceManager also contains the collection of Peer objects. The custom Peer class contains basic information about the peer, and also handles all incoming data from each peer. Each Peer object has its own MCSession to avoid known issues with many peers sharing the same session. All sent and received data has been abstracted into a custom Packet class that encapsulates each type of data (request, message, image) and as such can be easily extended to include many other types of data such as game instructions, sound, video, etc. Finally, each Peer contains a TaskQueue to ensure that the app will continue to attempt to send the data should the peer lose its connection and re-connect at a later time.

## Known Bugs/Limitations

* Data is only persisted while the app is running at this time. 
* MPC by design only works with other iOS devices.
* There is no security implemented to block peers or reject connections.
* There is an issue with the TaskQueue timer in which it fires more times than intended and does not turn off when intended.
* The original code was written for Swift 2.3, and has been automatically updated by XCode to comply with Swift 3.0. The code may not work as originally intended.
* The app needs extensive testing, which was out of the initial scope for the project.
