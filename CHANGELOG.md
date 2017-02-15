## Unreleased

## 2016-09-04 2.4.2
 - Fixes for OpenBSD package names

## 2016-09-04 2.4.1
This release contains data to support OpenBSD 6.0.

## 2016-09-04 2.4.0
This release contains test fixes for FreeBSD and changes to package
installation on FreeBSD.

### Features
 - Fix testing for FreeBSD
 - Installing virtualenv uses the package now in place of pip on FreeBSD
 - Pip is no longer a requirement for installing pip on FreeBSD

## 2016-08-29 2.3.1
This release contains a fix for 2.3.0 incorrectly handling resource dependencies.

## 2016-08-29 2.3.0
This release replaces the pip installation on FreeBSD for python3 versions.

### Features
 - Installation of pip3 on FreeBSD no longer uses an exec resource
 - Include more Puppet versions in testing

## 2016-07-20 2.2.1
This release contains updates to the hierarchy.

#### Features
  - Drop using os.release.minor from the hierarchy for more portability

## 2016-05-31 2.2.0
This release contains updates to virtualenv and pip handling under python3 on
certain platforms.

#### Features
 - Drop support for Debian oldstable

#### Fixes
 - Installation of pip3 on CentOS now uses get-pip.py from the pypa.io
 - Installation of virtualenv under python3 now requires pip when required
 - Package names on several platforms are updated for accuracy for virtualenv
 - Improvements to testing for pip + virtualenv


## 2016-05-29 2.1.0
### Summary
This release contains updates to support OpenBSD 5.9 and some testing improvements.

#### Features
 - OpenBSD 5.9 support
 - Testing improvements for python3 package name

## 2016-05-22 2.0.2
### Summary
This release contains minor ordering issues provisioning a new FreeBSD host.

#### Fixes
 - Fix ordering on pip and virtualenv installation

## 2016-05-19 2.0.1
### Summary
This release contains minor lint fixes and some class documentation updates.

#### Fixes
 - Lint for quoting errors
 - Convert more class documentation to puppet strings format

## 2016-05-18 2.0.0
### Summary
This release contains a near rewrite of the module.

#### Notable changes
 - Native puppet4
 - drop support for Gunicorn
 - Add OpenBSD support
 - Add FreeBSD support
 - Add CentOS7 Support
 - Drop support for SCL
 - Add changelog

