# project name and programming language
project('name.betschart.marco.timer', 'vala', 'c')

gnome = import('gnome')
i18n = import('i18n')

# Set our translation domain
add_global_arguments('-DGETTEXT_PACKAGE="@0@"'.format (meson.project_name()), language:'c')

gresource = gnome.compile_resources(
    'gresource',
    join_paths('data', 'gresource.xml'),
    source_dir: 'data'
)

# Create a new executable, list the files we want to compile,
# list the dependencies we need, and install
executable(
    meson.project_name(),
    gresource,
    'src/Application.vala',
    'src/MainWindow.vala',
    'src/Widgets/Clock.vala',
    'src/Widgets/Face.vala',
    'src/Widgets/Labels.vala',
    dependencies: [
        dependency('gtk+-3.0')
    ],
    install: true
)

subdir('data')
subdir('po')

meson.add_install_script('meson/post_install.py')
