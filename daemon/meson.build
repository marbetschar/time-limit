daemon_deps = [
    gio_dep,
    glib_dep,
    granite_dep,
    m_dep
]

executable(
    meson.project_name()+'-daemon',
    [
        'Daemon.vala',
        'DBusService.vala'
    ],
    dependencies: daemon_deps,
    install: true,
    install_dir: join_paths(get_option('prefix'), get_option('libexecdir'))
)