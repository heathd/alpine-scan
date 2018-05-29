## Alpine scan

A simple tool to compare a given docker image against the
[alpine-secdb](https://git.alpinelinux.org/cgit/alpine-secdb/) which is Alpine's official source of security updates.

## Dependencies

- ruby
- bundler
- git (used to clone alpine-secdb)
- an internet connection (used to clone alpine-secdb)

## Usage

```
$ bundle install

$ docker pull library/alpine:3.1
latest: Pulling from library/alpine
b56ae66c2937: Pulling fs layer
...

$ ./bin/scan library/alpine:3.1
Scanning 'myrepo/myimage:mytag'
musl (currently 1.1.16-r10)
  1.1.16-r14 fixes CVE-2017-15650
libtasn1 (currently 4.10-r1)
  4.10-r2 fixes CVE-2017-10790
Scanning complete: 50 packages of which 2 need updating
$ echo $? # exit status is 1 if vulnerabilities found
1
```

Exit status is 0 if no vulnerabilities found:

```
~/gds/pay/alpine-scan(master)$ ./bin/scan library/alpine
Scanning 'library/alpine'
Scanning complete: 11 packages of which 0 need updating
~/gds/pay/alpine-scan(master)$ echo $?
0
```
