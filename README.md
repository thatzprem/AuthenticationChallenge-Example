AuthenticationChallenge-Example
===============================

### What are the features explained with this example project?

1.	Creating a NSURLProtectionSpace for basicAuthentication
2.	Creating NSURLCredential and store it in NSURLProtectionSpace
3.	Adding created credentials to corresponding protection space
4.	Remove all the credentials from stored
5.	In-validate authentication if failureCount is more than 5 times
6.	Cancel authentication challenge if authentication failure exceeds 5 retries.

### How to use the application?

##### Valid credentials: 
      username: user1 
      password: user1

##### Invalid Credentails:
    username: user10
    password: user10

### Credits:
Greg Stein - for his WebDAV Testing Server (http://test.webdav.org/)



