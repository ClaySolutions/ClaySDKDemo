# ClaySDK Demo Application

This is a sample app that shows how to obtain a token for the SaltoKS's APIs 
and activate an iOS device to be used to unlock a Salto lock via Mobile Key.

By [Salto KS](https://saltoks.com/).

## Getting Started

These instructions will get you a copy of the project up and running on your local machine for development and testing purposes. 

### Prerequisites

Obtain SaltoJustINMobileSDK.xcframework from dropbox folder shared with you.
In order to be able to login to our APIs an integrator is supposed to receive an OpenId client configuration.
This configuration will be specific and unique for any different integrator.


### Installing

A step by step series of examples that tell you how to get a development env running

Put SaltoJustINMobileSDK.xcframework inside /Demo folder

Install CocoaPods by running:

```
pod install
```

Open Demo.xcworkspace as your starting point

### Configuration.plist

This file is used to configure settings specific for your client.

Some of the fields will be already populated with Acceptance enviroment information.

Put missing values for redirectLogin, redirectLogout and clientId provided by SaltoKS

```
<key>apiUrl</key>
<string>https://clp-accept-user.my-clay.com/v1.1</string>
<key>apiPublicKey</key>
<string>MFkwEwYHKoZIzj0CAQYIKoZIzj0DAQcDQgAEFYDlLVhKz+qNQIBASs322cib/iwnnuSWczXSvU8GGYB6pgZgaCroCywHMPclFRehVsB+jYRJd6n4zkhDSGd5bQ==</string>
<key>redirectLogout</key>
<string></string>
<key>redirectLogin</key>
<string></string>
<key>clientId</key>
<string></string>
<key>issuer</key>
<string>https://clp-accept-identityserver.my-clay.com</string>
```
After you have everything ready you can run application.


## Author

* [ClaySolutions](https://github.com/ClaySolutions) ([Jakov](https://github.com/jakov-clay))

## License

This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details


