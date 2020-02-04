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

# Add math library (-lm) portably
compiler = meson.get_compiler('c')
math_lib = compiler.find_library('m', required : false)

# Create a new executable, list the files we want to compile,
# list the dependencies we need, and install
executable(
    meson.project_name(),
    gresource,
    'src/Application.vala',
    'src/MainWindow.vala',
    'src/Util.vala',
    'src/Widgets/Clock.vala',
    'src/Widgets/Face.vala',
    'src/Widgets/Labels.vala',
    'src/Widgets/ProgressIndicator.vala',
    'src/Widgets/ProgressArrow.vala',
    'src/Widgets/ProgressBar.vala',
    dependencies: [
        dependency('glib-2.0'),
        dependency('gtk+-3.0'),
        math_lib
    ],
    install: true
)

subdir('data')
subdir('po')

meson.add_install_script('meson/post_install.py')
