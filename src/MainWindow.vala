/*
* Copyright (c) 2020 Marco Betschart (https://marco.betschart.name)
*
* This program is free software; you can redistribute it and/or
* modify it under the terms of the GNU General Public
* License as published by the Free Software Foundation; either
* version 2 of the License, or (at your option) any later version.
*
* This program is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
* General Public License for more details.
*
* You should have received a copy of the GNU General Public
* License along with this program; if not, write to the
* Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
* Boston, MA 02110-1301 USA
*
* Authored by: Marco Betschart <time-limit@marco.betschart.name
*/

public class Timer.MainWindow : Gtk.ApplicationWindow {

    public signal void send_notification (Notification notification);

    public MainWindow (Gtk.Application application) {
        Object (
            application: application,
            icon_name: "com.github.marbetschar.time-limit",
            resizable: false,
            default_height: 200,
            default_width: 200
        );
    }

    construct {
        var main_window_provider = new Gtk.CssProvider ();
        main_window_provider.load_from_resource ("com/github/marbetschar/time-limit/Main.css");

        weak Gtk.IconTheme default_theme = Gtk.IconTheme.get_default ();
        default_theme.add_resource_path ("/com/github/marbetschar/time-limit/");

        var header = new Gtk.HeaderBar ();
        header.decoration_layout = "close:";
        header.has_subtitle = false;
        header.show_close_button = true;

        unowned Gtk.StyleContext header_context = header.get_style_context ();
        header_context.add_class ("titlebar");
        header_context.add_class ("default-decoration");
        header_context.add_class ("main-background");
        header_context.add_class (Gtk.STYLE_CLASS_FLAT);
        header_context.add_provider (main_window_provider, Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION);

        var clock = new Timer.Widgets.Clock ();
        add (clock);

        set_titlebar (header);

        var main_window_context = get_style_context ();
        main_window_context.add_class ("rounded");
        main_window_context.add_class ("main-background");
        main_window_context.add_class (Gtk.STYLE_CLASS_FLAT);
        main_window_context.add_class ("main");
        main_window_context.add_provider (main_window_provider, Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION);

        key_release_event.connect ((event) => {
            switch (event.keyval) {
                case Gdk.Key.space:
                    clock.pause = !clock.pause;
                    break;

                case Gdk.Key.Escape:
                    clock.pause = false;
                    clock.seconds = 0;
                    break;
            }
        });
    }
}
