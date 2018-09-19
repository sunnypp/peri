# Peri

Peri is a Perl Package that enables Perl Monks to write automated unit tests and integration tests in a Jasmine-like (specification based) style (with describe, it, and expect).

# "Peri"? Why this name?

From Mocha, Chai, to Jasmine, every of them is a name of a tea, with Jasmine for JavaScript (both starts with `Ja`).

When thinking about the name of this package, I searched for words that starts with `Per` so as to correspond to `Perl`.  

Peri was found to be a "superhuman being" that somehow is shown as a fairy.  

Maybe just take this but I want it to be a Camel.  More "Perl-like".

# Usage

Put `MonkeyPatch.pm` and `Peri.pm` anywhere as you like -- just ensure that you have that path in your library when you need to call them.

Write a test case.  Use `prove` (perhaps with the `-v` flag) or just `perl abc.t` to run the test case.

Clone this repository and try `prove -v Peri.t`.  `Peri.t` should have examples of all usable functions.

# TO-DO

1. Remove dependency to MonkeyPatch package.
2. More documentation, though working code is the best documentation. (Sometimes)
3. Allow shuffling of order when using `using()`.  (the `sort` was added for testing purposes)
4. Or, allow `using()` to accept Arrayref parameter.
