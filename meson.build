project('com.github.marbetschar.time-limit', 'vala', 'c')

gnome = import('gnome')
i18n = import('i18n')

add_project_arguments([
        '-DGETTEXT_PACKAGE="@0@"'.format(meson.project_name()),
        '-DHANDY_USE_UNSTABLE_API'
    ],
    language: 'c'
)

asresources = gnome.compile_resources(
    'as-resources',
    'data/' + meson.project_name() + '.gresource.xml',
    source_dir: 'data',
    c_name: 'as'
)

dependencies = [
    dependency('glib-2.0'),
    dependency('gtk+-3.0'),
    dependency('granite', version: '>=0.5'),
    dependency('libhandy-1', version: '>=0.83.0'),
    meson.get_compiler('c').find_library('m', required : false)
]

subdir('src')

executable(
    meson.project_name(),
    asresources,
    sources,
    dependencies: dependencies,
    install: true
)

subdir('data')
subdir('po')

meson.add_install_script('meson/post_install.py')
