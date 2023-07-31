# pesign-116-2 on Fedora 38 in client-server mode with SoftHSM

And how to make it work. Perform these steps in order:

- install pesign-116-2
- initialize a system-wide SoftHSM token and with the name *HSM*
- make the `/var/lib/softhsm` directory accessible by anyone with `chmod -R 777`
- reinstall pesign-116-2
- if the *pesign* service is not running, start it
- unlock a token with `pesign-client --unlock --token HSM`

These need to be verified:

- [x] do we need to enable debug mode in `cms_common.h` and `daemon.h`? No.
- [ ] does my user account need to be in the `pesign` Unix group?
- [ ] does SELinux need to be disabled?
- [ ] what's the relation of all these to the entries in `/etc/pesign/users` and `/etc/pesign/groups` and what happens once the files and `/usr/libexec/pesign/pesign-authorize` are finally deprecated?
- [ ] what happens after the reinstallation that makes all this work fine?
