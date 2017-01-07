C:\Ruby%RUBY_VERSION%\bin\ruby C:\Ruby%RUBY_VERSION%\bin\gem update --system
C:\Ruby%RUBY_VERSION%\bin\ruby C:\Ruby%RUBY_VERSION%\bin\gem install bundler
cd C:\projects\openstudio-server\
C:\Ruby%RUBY_VERSION%\bin\ruby C:\RUBY%RUBY_VERSION%\bin\bundle install --with default development test
C:\Ruby%RUBY_VERSION%\bin\ruby C:\RUBY%RUBY_VERSION%\bin\bundle exec C:\projects\openstudio-server\ci\build_os_release_scripts.rb
C:\projects\openstudio-server\ci\sets.cmd
mkdir c:\projects\openstudio
IF /I %OPENSTUDIO_VERSION%=="ONE_ITERATION" (
    curl -SLO https://s3.amazonaws.com/openstudio-builds/%OPENSTUDIO_ONE_ITERATION%-Win64.exe
    7z x %OPENSTUDIO_ONE_ITERATION%-Win64.exe -oc:\projects\openstudio
)
IF /I %OPENSTUDIO_VERSION%=="TWO_ITERATION" (
    curl -SLO https://s3.amazonaws.com/openstudio-builds/%OPENSTUDIO_TWO_ITERATION%-Win64.exe
    7z x %OPENSTUDIO_TWO_ITERATION%-Win64.exe -oc:\projects\openstudio
)
IF /I %OPENSTUDIO_VERSION%=="ONE_RELEASE" (
    curl -SLO https://s3.amazonaws.com/openstudio-builds/%OPENSTUDIO_ONE_RELEASE%-Win64.exe
    7z x %OPENSTUDIO_ONE_RELEASE%-Win64.exe -oc:\projects\openstudio
)
IF /I %OPENSTUDIO_VERSION%=="TWO_RELEASE" (
    curl -SLO https://s3.amazonaws.com/openstudio-builds/%OPENSTUDIO_TWO_RELEASE%-Win64.exe
    7z x %OPENSTUDIO_TWO_RELEASE%-Win64.exe -oc:\projects\openstudio
)
set RUBYLIB=C:\projects\openstudio\Ruby
set PATH=C:\Ruby%RUBY_VERSION%\bin;C:\Mongodb\bin;%PATH%
C:\Ruby%RUBY_VERSION%\bin\ruby C:\projects\openstudio-server\bin\openstudio_meta install_gems --with_test_develop --debug --verbose
C:\Ruby%RUBY_VERSION%\bin\bundle install --gemfile=C:\projects\openstudio-server\Gemfile
