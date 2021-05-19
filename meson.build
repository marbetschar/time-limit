project('com.github.marbetschar.time-limit', 'vala', 'c')

gnome = import('gnome')
i18n = import('i18n')

add_project_arguments([
        '-DGETTEXT_PACKAGE="@0@"'.format(meson.project_name()),
        '-DHANDY_USE_UNSTABLE_API'
    ],
    language: 'c'
)

libexecdir = join_paths(get_option('prefix'), get_option('libexecdir'), meson.project_name())

asresources = gnome.compile_resources(
    'as-resources',
    'data/' + meson.project_name() + '.gresource.xml',
    source_dir: 'data',
    c_name: 'as'
)

gio_dep = dependency('gio-2.0')
glib_dep = dependency('glib-2.0')
granite_dep = dependency('granite', version: '>=0.5')
m_dep = meson.get_compiler('c').find_library('m', required : false)

dependencies = [
    gio_dep,
    glib_dep,
    granite_dep,
    dependency('gtk+-3.0'),
    dependency('libhandy-1', version: '>=0.83.0'),
    m_dep
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
subdir('daemon')
subdir('po')

meson.add_install_script('meson/post_install.py')
