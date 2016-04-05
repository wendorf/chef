<!---
This file is reset every time a new release is done. This file describes changes that have not yet been released.

Example Doc Change:
### Headline for the required change
Description of the required change.
-->

## Doc changes for Chef 12.9

### New timeout option added to `knife ssh`

When doing a `knife ssh` call, if a connection to a host is not able
to succeed due to host unreachable or down, the entire call can hang. In
order to prevent this from happening, a new timeout option has been added
to allow a connection timeout to be passed to the underlying SSH call
(see ConnectTimeout setting in http://linux.die.net/man/5/ssh_config)

The timeout setting can be passed in via a command line parameter
(`-t` or `--ssh-timeout`) or via a knife config
(`Chef::Config[:knife][:ssh_timeout]`).  The value of the timeout is set
in seconds.

### Windows alternate user identity execute support

The `execute` resource and simliar resources such as `script`, `batch`, and `powershell_script`
now support the specification of credentials on Windows so that the resulting process
is created with the security identity that corresponds to those credentials.

#### Properties

The following properties are new or updated for the `execute`, `script`, `batch`, and
`powershell_script` resources and any resources derived from them:

*   `user`</br>
    **Ruby types:** String</br>
    The user name of the user identity with which to launch the new process.
    Default value: `nil`. The user name may optionally be specifed
    with a domain, i.e. `domain\user` or `user@my.dns.domain.com` via Universal Principal Name (UPN)
    format. It can also be specified without a domain simply as `user` if the domain is
    instead specified using the `domain` attribute. On Windows only, if this property is specified, the `password`
    property **must** be specified.

*   `password`</br>
    **Ruby types** String</br>
    *Windows only:* The password of the user specified by the `user` property.
    Default value: `nil`. This property is mandatory if `user` is specified on Windows and may only
    be specified if `user` is specified. The `sensitive` property for this resource will
    automatically be set to `true` if `password` is specified.

*   `domain`</br>
    **Ruby types** String</br>
    *Windows only:* The domain of the user user specified by the `user` property.
    Default value: `nil`. If not specified, the user name and password specified
    by the `user` and `password` properties will be used to resolve
    that user against the domain in which the system running Chef client
    is joined, or if that system is not joined to a domain it will resolve the user
    as a local account on that system. An alternative way to specify the domain is to leave
    this property unspecified and specify the domain as part of the `user` property.
