# Sigma6

CIJoe is a Real American Hero ... Sigma6 continues the battle against Pyth^WCobra

## Synopsis

    > cat sigma6.ini
    [server]
    smoker_command = /Users/perigrin/dev/perigrin/sigma-6/bin/smoke.pl
    smoker_config = sigma6.ini

    [build]
    target        = git@github.com:perigrin/sigma-6.git
    dir           = /tmp/sigma6
    deps_command  = dzil listdeps | cpanm -L perl5 
    build_command = dzil smoke --automated
        
    > plackup app.psgi

## Description

Sigma6 is a Continuous Integration application originally based upon
[CIJoe][1]. It should be self-hosting now but that hasn't really been pushed.
Additionally the tests are woefully lacking, and you're reading all of the
documentation there is. That said, it's 315 lines of code, you should
just read that.

[1]: https://github.com/defunkt/cijoe
